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
  
  // Tab Navigation State
  final selectedTab = 0.obs; // Outer tab: 0: STATISTICS, 1: ANALYSIS, 2: PREDICTIONS, 3: RESULTS
  final selectedMainTab = 0.obs; // Inside STATISTICS: 0: Koşu Analizi, 1: Atlar, 2: Jokeyler
  final selectedKosuAnaliziSubTab = 0.obs; // Sub-tab for Koşu Analizi: 0: Atlar Listesi, 1: Galoplar & Sprintler, 2: En İyi Derece, 3: Son Koşular, 4: Birincilikler, 5: Kim Kiminle Koştu, 6: Kim Kimi Geçti
  final selectedAtlarSubTab = 0.obs; // Sub-tab for Atlar (Atlar, Kısraklar, Aygırlar, Kısrak Babaları)
  final selectedJokeylerSubTab = 0.obs; // Sub-tab for Jokeyler (Jokeyler, Aprantiler)
  
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
    final savedPremium = await StorageService.getBool(StorageConstants.isPremium) ?? false;
    isPremium.value = savedPremium;
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

        // Sync premium status from local storage
        final savedPremium = await StorageService.getBool(StorageConstants.isPremium) ?? false;
        isPremium.value = savedPremium;

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
        
        int parseMinutes(String? t) {
          if (t == null || t.isEmpty) return 0;
          final clean = t.trim().replaceAll(RegExp(r'[^\d:]'), '');
          final parts = clean.split(':');
          if (parts.isEmpty) return 0;
          int h = int.tryParse(parts[0]) ?? 0;
          int m = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
          if (h > 0 && h < 7) h += 12; // 4:10 -> 16:10 in horse racing times
          return h * 60 + m;
        }

        // Sort by chronological race time properly
        list.sort((a, b) {
          final aMin = parseMinutes(a.time);
          final bMin = parseMinutes(b.time);
          if (aMin != bMin) return aMin.compareTo(bMin);
          return (a.name ?? '').compareTo(b.name ?? '');
        });

        siblingRaces.assignAll(list);

        // Ensure race.value matches element from siblingRaces
        final currentId = race.value?.id;
        final currentName = race.value?.name;
        if (currentId != null || currentName != null) {
          final matched = list.firstWhereOrNull(
            (r) => (currentId != null && r.id == currentId) ||
                   (currentName != null && r.name == currentName),
          );
          if (matched != null) {
            race.value = matched;
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching sibling races: $e");
    }
  }

  void selectSiblingRace(RaceModel newRace) {
    if ((newRace.id != null && newRace.id == race.value?.id) ||
        (newRace.name != null && newRace.name == race.value?.name)) {
      return;
    }
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
    _sseService.close();
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
    if (index == 1 || index == 2) {
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
    if (id.trim().isEmpty) return;

    isHorseLoading.value = true;
    horseDetails.value = null;
    try {
      final response = await _raceRepo.getHorseProfile(id);
      ApiChecker.checkGetApi(response);

      if (response.statusCode == 200 && response.data != null) {
        final horseDetailsResponse = HorseDetailsResponse.fromJson(response.data);
        horseDetails.value = horseDetailsResponse.data;
      }
    } catch (e) {
      Helpers.error('[RaceDetailsController] Error fetching horse profile: $e');
    } finally {
      isHorseLoading.value = false;
    }
  }
}
