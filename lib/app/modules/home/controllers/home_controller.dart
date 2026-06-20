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
  final isLoading = false.obs;
  final isLoadMore = false.obs;
  final meta = Rxn<RaceMeta>();
  final searchQuery = ''.obs;

  final meetingGroups = <MeetingModel>[].obs;

  void _updateMeetingGroups() {
    final Map<String, List<RaceModel>> groupedRaces = {};
    final Map<String, String> locationToCountry = {};

    for (final race in raceList) {
      final location = race.location ?? 'Unknown';
      final country = race.country ?? 'Unknown';

      groupedRaces.putIfAbsent(location, () => []).add(race);
      locationToCountry[location] = country;
    }

    final newList = groupedRaces.entries.map((entry) {
      return MeetingModel(
        location: entry.key,
        country: locationToCountry[entry.key] ?? 'Unknown',
        races: entry.value,
      );
    }).toList();

    meetingGroups.assignAll(newList);
  }

  @override
  void onInit() {
    super.onInit();
    _calendarController = Get.find<CalendarController>();

    // Add scroll listener for pagination
    scrollController.addListener(() {
      // Trigger load-more ONLY when user reaches the very bottom of the scroll view
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 10) {
        final currentMeta = meta.value;
        if (!isLoading.value &&
            !isLoadMore.value &&
            currentMeta != null &&
            (currentMeta.page ?? 1) < (currentMeta.totalPage ?? 1)) {
          isLoadMore.value = true; // Synchronously guard to prevent double-triggering
          fetchRaces(isRefresh: false);
        }
      }
    });

    // Listen to calendar date changes, reset category filter, and fetch races
    ever(_calendarController.selectedDate, (_) {
      selectedCategory.value = 'All';
      fetchRaces(isRefresh: true);
    });
    fetchRaces();
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  Future<void> fetchRaces({bool isRefresh = true}) async {
    if (isRefresh) {
      isLoading.value = true;
    } else {
      isLoadMore.value = true;
    }

    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(_calendarController.selectedDate.value);
      final response = await _raceRepo.getRaces(
        page: isRefresh ? 1 : (meta.value?.page ?? 0) + 1,
        limit: 20,
        status: selectedStatus.value == 'All' ? null : selectedStatus.value.toUpperCase(),
        location: selectedCategory.value == 'All' ? null : selectedCategory.value,
        date: dateStr,
        search: searchQuery.value.trim().isEmpty ? null : searchQuery.value.trim(),
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
        _updateMeetingGroups();

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

  void setStatus(String status) {
    selectedStatus.value = status;
    fetchRaces();
  }

  void setRegion(String region) {
    selectedRegion.value = region;
    fetchRaces();
  }

  void resetFilters() {
    selectedStatus.value = 'All';
    selectedRegion.value = 'All';
    fetchRaces();
  }

  void selectCategory(String category) {
    selectedCategory.value = category;
    fetchRaces();
  }

  void searchRaces(String query) {
    searchQuery.value = query;
    selectedCategory.value = 'All';
    fetchRaces();
  }
}

