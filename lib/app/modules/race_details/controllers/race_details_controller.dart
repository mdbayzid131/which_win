import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:which_win/config/constants/storage_constants.dart';
import 'package:which_win/core/services/api_checker.dart';
import 'package:which_win/core/services/sse_service.dart';
import 'package:which_win/core/services/storage_service.dart';
import 'package:which_win/core/utils/helpers.dart';
import 'package:which_win/data/models/race_details_model.dart';
import 'package:which_win/data/models/race_model.dart';
import 'package:which_win/data/models/race_statistics_model.dart';
import 'package:which_win/data/repositories/race_repository.dart';

class RaceDetailsController extends GetxController {
  final RaceRepo _raceRepo = Get.find<RaceRepo>();

  final race = Rxn<RaceModel>();
  final raceDetails = Rxn<RaceDetailsData>();
  final raceStats = Rxn<RaceStatsData>();
  final siblingRaces = <RaceModel>[].obs;

  final isLoading = false.obs;
  final isStatsLoading = false.obs;
  final selectedTab = 0.obs;
  final expandedIndex = (-1).obs;
  final bulletinExpandedIndex = (-1).obs;

  /// Whether the current user has an active premium subscription.
  /// Loaded from local storage immediately on init (no network needed).
  final isPremium = false.obs;

  /// True when the race is LIVE and SSE is actively connected.
  final isLive = false.obs;

  // ── SSE ─────────────────────────────────────────────────────────────────
  final SseService _sseService = SseService();
  StreamSubscription? _sseSub;

  @override
  void onInit() {
    super.onInit();
    _loadPremiumStatus();
    if (Get.arguments is RaceModel) {
      race.value = Get.arguments;
      fetchRaceDetails();
      fetchSiblingRaces();
    }
  }

  @override
  void onClose() {
    _disconnectSse();
    super.onClose();
  }

  // ── PREMIUM STATUS ────────────────────────────────────────────────────────

  Future<void> _loadPremiumStatus() async {
    // Forced to true for design/testing
    isPremium.value = true;
  }

  // ── REST FETCH ────────────────────────────────────────────────────────────

  Future<void> fetchRaceDetails() async {
    if (race.value?.id == null) return;

    isLoading.value = true;
    try {
      final response = await _raceRepo.getRaceDetails(race.value!.id!);
      ApiChecker.checkGetApi(response);

      if (response.statusCode == 200) {
        final raceDetailsResponse = RaceDetailsResponse.fromJson(response.data);
        raceDetails.value = raceDetailsResponse.data;

        // Update isPremium from the server response if available (forced to true for design/testing)
        isPremium.value = true;
        await StorageService.setBool(StorageConstants.isPremium, true);

        // Connect SSE only for LIVE races
        final status = raceDetails.value?.status?.toUpperCase() ?? '';
        if (status == 'LIVE') {
          _connectSse(race.value!.id!);
        }
      }
    } catch (e) {
      // Error handled by ApiChecker
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchSiblingRaces() async {
    if (race.value == null) return;
    try {
      final dateStr = race.value?.date?.split('T').first;
      final response = await _raceRepo.getRaces(
        date: dateStr,
        location: race.value?.location,
      );
      if (response.statusCode == 200) {
        final raceResponse = RacesResponse.fromJson(response.data);
        final list = raceResponse.data ?? [];
        // Sort by time or name so races are in chronological order (KOŞU 1, KOŞU 2...)
        list.sort((a, b) {
          final aTime = a.time ?? '';
          final bTime = b.time ?? '';
          return aTime.compareTo(bTime);
        });
        siblingRaces.assignAll(list);
      }
    } catch (e) {
      debugPrint("Error fetching sibling races: $e");
    }
  }

  void selectSiblingRace(RaceModel newRace) {
    if (newRace.id == race.value?.id) return;
    race.value = newRace;
    raceDetails.value = null;
    raceStats.value = null;
    expandedIndex.value = -1;
    bulletinExpandedIndex.value = -1;
    _disconnectSse();
    fetchRaceDetails();
  }

  Future<void> fetchRaceStatistics() async {
    if (race.value?.id == null) return;
    if (raceStats.value != null) return; // Already fetched

    isStatsLoading.value = true;
    try {
      final response = await _raceRepo.getRaceStatistics(race.value!.id!);
      ApiChecker.checkGetApi(response);

      if (response.statusCode == 200) {
        final statsResponse = RaceStatisticsResponse.fromJson(response.data);
        raceStats.value = statsResponse.data;
      }
    } catch (e) {
      // Handled
    } finally {
      isStatsLoading.value = false;
    }
  }

  // ── SSE ───────────────────────────────────────────────────────────────────

  void _connectSse(String raceId) {
    if (_sseSub != null) return; // Already connected

    isLive.value = true;
    Helpers.info('[RaceDetails] Connecting SSE for race: $raceId');

    _sseSub = _sseService.stream.listen(_onSseEvent);
    _sseService.connect(raceId);
  }

  void _disconnectSse() {
    _sseSub?.cancel();
    _sseSub = null;
    _sseService.dispose();
    isLive.value = false;
  }

  void _onSseEvent(Map<String, dynamic> event) {
    final type = event['type'] as String? ?? '';
    final data = event['data'] as Map<String, dynamic>? ?? {};

    Helpers.debug('[SSE Event] type=$type');

    switch (type) {
      case 'race:snapshot':
      case 'race:update':
        _applyRaceUpdate(data);
        break;
      case 'connected':
        Helpers.info('[SSE] Handshake confirmed for race: ${data['raceId']}');
        break;
    }
  }

  /// Merge the SSE payload into the current raceDetails observable.
  /// Only updates the entries list (and race-level prediction fields) so the
  /// full UI re-renders reactively without a full REST round-trip.
  void _applyRaceUpdate(Map<String, dynamic> data) {
    final current = raceDetails.value;
    if (current == null) return;

    try {
      // Re-parse incoming data as a RaceDetailsData on top of current state.
      // We do a shallow merge: entries list from SSE, everything else stays.
      final rawEntries = data['entries'];
      if (rawEntries is List) {
        final updatedEntries = rawEntries
            .map((e) => RaceEntry.fromJson(Map<String, dynamic>.from(e)))
            .toList();

        // Build a new RaceDetailsData with updated entries
        final updated = RaceDetailsData(
          id: current.id,
          name: current.name,
          date: current.date,
          time: current.time,
          location: current.location,
          country: current.country,
          trackType: current.trackType,
          distance: current.distance,
          prize: current.prize,
          status: data['status']?.toString() ?? current.status,
          tahmin1X: data['tahmin1X']?.toString() ?? current.tahmin1X,
          riskRate: data['riskRate'] as int? ?? current.riskRate,
          predictionMessage:
              data['predictionMessage']?.toString() ?? current.predictionMessage,
          hasPredictions: data['hasPredictions'] as bool? ?? current.hasPredictions,
          entries: updatedEntries,
          results: current.results,
        );

        raceDetails.value = updated;
        Helpers.info('[SSE] Race data updated live — ${updatedEntries.length} entries');
      }

      // If race just went LIVE, flip the indicator
      final newStatus = data['status']?.toString().toUpperCase() ?? '';
      if (newStatus == 'FINISHED') {
        isLive.value = false;
        _disconnectSse();
        Helpers.info('[SSE] Race finished — SSE disconnected');
      }
    } catch (e) {
      Helpers.error('[SSE] Failed to apply race update: $e');
    }
  }

  // ── UI HELPERS ────────────────────────────────────────────────────────────

  void setTab(int index) {
    selectedTab.value = index;
    if (index == 1) {
      fetchRaceStatistics();
    }
  }

  void toggleExpand(int index) {
    if (expandedIndex.value == index) {
      expandedIndex.value = -1;
    } else {
      expandedIndex.value = index;
    }
  }

  void toggleBulletinExpand(int index) {
    if (bulletinExpandedIndex.value == index) {
      bulletinExpandedIndex.value = -1;
    } else {
      bulletinExpandedIndex.value = index;
    }
  }

  final horseDetails = Rxn<HorseModel>();
  final isHorseLoading = false.obs;

  Future<void> fetchHorseProfile(String id) async {
    isHorseLoading.value = true;
    horseDetails.value = null;
    try {
      final response = await _raceRepo.getHorseProfile(id);
      ApiChecker.checkGetApi(response);

      if (response.statusCode == 200) {
        final horseDetailsResponse = HorseDetailsResponse.fromJson(response.data);
        horseDetails.value = horseDetailsResponse.data;
      }
    } catch (e) {
      // Handled
    } finally {
      isHorseLoading.value = false;
    }
  }
}
