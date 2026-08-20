import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:which_win/app/modules/calendar/controllers/calendar_controller.dart';
import 'package:which_win/core/services/api_checker.dart';
import 'package:which_win/data/models/race_model.dart';
import 'package:which_win/data/models/meeting_model.dart';
import 'package:which_win/data/repositories/race_repository.dart';

class HomeController extends GetxController {
  final RaceRepo _raceRepo = Get.find<RaceRepo>();
  late final CalendarController _calendarController;

  final scrollController = ScrollController();

  final selectedCategory = 'All'.obs;
  final categories = <String>['All'].obs;

  final raceList = <RaceModel>[].obs;
  final meetingsList = <MeetingModel>[].obs;
  final isLoading = false.obs;
  final isLoadMore = false.obs;
  final meta = Rxn<RaceMeta>();
  final searchQuery = ''.obs;

  List<MeetingModel> get filteredMeetings {
    if (selectedCategory.value == 'All') {
      return meetingsList;
    }
    return meetingsList
        .where((m) => m.location == selectedCategory.value)
        .toList();
  }

  DateTime get selectedDate => _calendarController.selectedDate.value;

  String? _getCountryCodeFromRegion(String region) {
    switch (region) {
      case 'UK':
        return 'GB';
      case 'USA':
        return 'USA';
      case 'Europe':
        return 'FR';
      case 'Asia':
        return 'HK';
      case 'Australia':
        return 'AUS';
      default:
        return null;
    }
  }

  @override
  void onInit() {
    super.onInit();
    _calendarController = Get.find<CalendarController>();
    // Listen to calendar date changes and fetch locations & races
    ever(_calendarController.selectedDate, (_) {
      selectedCategory.value = 'All';
      fetchLocations();
      fetchRaces(isRefresh: true);
    });
    fetchLocations();
    fetchRaces();
  }

  Future<void> fetchLocations() async {
    try {
      meetingsList.clear();
      final dateStr = DateFormat(
        'yyyy-MM-dd',
      ).format(_calendarController.selectedDate.value);
      final countryCode = _getCountryCodeFromRegion(selectedRegion.value);
      final response = await _raceRepo.getRaceLocations(
        date: dateStr,
        status: selectedStatus.value == 'All'
            ? null
            : selectedStatus.value.toUpperCase(),
        search: searchQuery.value.trim().isEmpty
            ? null
            : searchQuery.value.trim(),
        country: countryCode,
      );
      ApiChecker.checkGetApi(response);

      if (response.statusCode == 200) {
        final List<dynamic> fetchedData = response.data['data'] ?? [];
        final parsedMeetings = fetchedData
            .map((e) => MeetingModel.fromJson(e))
            .toList();
        meetingsList.assignAll(parsedMeetings);

        final uniqueLocations = parsedMeetings.map((m) => m.location).toList();
        categories.assignAll(['All', ...uniqueLocations]);
      }
    } catch (e) {
      // Error handled by ApiChecker
    }
  }

  Future<void> fetchRaces({bool isRefresh = true}) async {
    if (isRefresh) {
      isLoading.value = true;
      raceList.clear();
    } else {
      isLoadMore.value = true;
    }

    try {
      final dateStr = DateFormat(
        'yyyy-MM-dd',
      ).format(_calendarController.selectedDate.value);
      final countryCode = _getCountryCodeFromRegion(selectedRegion.value);
      final response = await _raceRepo.getRaces(
        page: isRefresh ? 1 : (meta.value?.page ?? 0) + 1,
        limit: 20,
        status: selectedStatus.value == 'All'
            ? null
            : selectedStatus.value.toUpperCase(),
        location: selectedCategory.value == 'All'
            ? null
            : selectedCategory.value,
        date: dateStr,
        search: searchQuery.value.trim().isEmpty
            ? null
            : searchQuery.value.trim(),
        country: countryCode,
      );

      ApiChecker.checkGetApi(response);

      if (response.statusCode == 200) {
        final raceResponse = RacesResponse.fromJson(response.data);
        if (isRefresh) {
          raceList.assignAll(raceResponse.data ?? []);
        } else {
          raceList.addAll(raceResponse.data ?? []);
        }
        meta.value = raceResponse.meta;

        // Dynamically update categories only when no category filter is active
        if (selectedCategory.value == 'All') {
          final uniqueLocations = raceList
              .map((r) => r.location)
              .whereType<String>()
              .toSet()
              .toList();
          categories.assignAll(['All', ...uniqueLocations]);
        }

        // No auto-fetching pages; only triggered via scrollController at scroll limit
      }
    } catch (e) {
      // Error handled by ApiChecker or repository
    } finally {
      isLoading.value = false;
      isLoadMore.value = false;
    }
  }

  final selectedStatus = 'All'.obs;
  final selectedRegion = 'All'.obs;
  final isLiveFilterActive = false.obs;

  void setStatus(String status) {
    selectedStatus.value = status;
    meetingsList.clear();
    raceList.clear();
    fetchLocations();
    fetchRaces();
  }

  void setRegion(String region) {
    selectedRegion.value = region;
    meetingsList.clear();
    raceList.clear();
    fetchLocations();
    fetchRaces();
  }

  void resetFilters() {
    selectedStatus.value = 'All';
    selectedRegion.value = 'All';
    meetingsList.clear();
    raceList.clear();
    fetchLocations();
    fetchRaces();
  }

  void selectCategory(String category) {
    selectedCategory.value = category;
    raceList.clear();
    fetchRaces();
  }

  void searchRaces(String query) {
    searchQuery.value = query;
    meetingsList.clear();
    raceList.clear();
    fetchLocations();
    fetchRaces();
  }

  /// Toggles the LIVE filter in the app bar.
  /// ON  → status=LIVE, fetches only live races.
  /// OFF → resets to All.
  void toggleLiveFilter() {
    isLiveFilterActive.value = !isLiveFilterActive.value;
    if (isLiveFilterActive.value) {
      selectedStatus.value = 'LIVE';
    } else {
      selectedStatus.value = 'All';
    }
    meetingsList.clear();
    raceList.clear();
    fetchLocations();
    fetchRaces();
  }
}
