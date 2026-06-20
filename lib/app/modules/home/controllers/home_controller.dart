import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:which_win/app/modules/calendar/controllers/calendar_controller.dart';
import 'package:which_win/core/services/api_checker.dart';
import 'package:which_win/data/models/race_model.dart';
import 'package:which_win/data/repositories/race_repository.dart';

class MeetingGroup {
  final String country;
  final String location;
  final List<RaceModel> races;

  MeetingGroup({
    required this.country,
    required this.location,
    required this.races,
  });

  bool get isLive => races.any((r) => r.status == 'LIVE');
  int get racesCount => races.length;
}

class MeetingModel {
  final String country;
  final String location;
  final int racesCount;
  final bool isLive;

  MeetingModel({
    required this.country,
    required this.location,
    required this.racesCount,
    required this.isLive,
  });

  factory MeetingModel.fromJson(Map<String, dynamic> json) {
    return MeetingModel(
      country: json['country'] ?? 'Unknown',
      location: json['location'] ?? 'Unknown',
      racesCount: json['racesCount'] ?? 0,
      isLive: json['isLive'] ?? false,
    );
  }
}

class HomeController extends GetxController {
  final RaceRepo _raceRepo = Get.find<RaceRepo>();
  late final CalendarController _calendarController;

  final selectedCategory = 'All'.obs;
  final categories = <String>['All'].obs;

  final raceList = <RaceModel>[].obs;
  final meetingsList = <MeetingModel>[].obs;
  final isLoading = false.obs;
  final meta = Rxn<RaceMeta>();
  final searchQuery = ''.obs;

  List<MeetingModel> get filteredMeetings {
    if (selectedCategory.value == 'All') {
      return meetingsList;
    }
    return meetingsList.where((m) => m.location == selectedCategory.value).toList();
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

  List<MeetingGroup> get meetingGroups {
    final list = <MeetingGroup>[];
    for (final race in raceList) {
      final country = race.country ?? 'Unknown';
      final location = race.location ?? 'Unknown';
      
      MeetingGroup? existing;
      for (final g in list) {
        if (g.country == country && g.location == location) {
          existing = g;
          break;
        }
      }
      
      if (existing != null) {
        existing.races.add(race);
      } else {
        list.add(MeetingGroup(country: country, location: location, races: [race]));
      }
    }
    return list;
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
      final dateStr = DateFormat('yyyy-MM-dd').format(_calendarController.selectedDate.value);
      final countryCode = _getCountryCodeFromRegion(selectedRegion.value);
      final response = await _raceRepo.getRaceLocations(
        date: dateStr,
        status: selectedStatus.value == 'All' ? null : selectedStatus.value.toUpperCase(),
        search: searchQuery.value.trim().isEmpty ? null : searchQuery.value.trim(),
        country: countryCode,
      );
      ApiChecker.checkGetApi(response);

      if (response.statusCode == 200) {
        final List<dynamic> fetchedData = response.data['data'] ?? [];
        final parsedMeetings = fetchedData.map((e) => MeetingModel.fromJson(e)).toList();
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
    }

    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(_calendarController.selectedDate.value);
      final countryCode = _getCountryCodeFromRegion(selectedRegion.value);
      final response = await _raceRepo.getRaces(
        page: isRefresh ? 1 : (meta.value?.page ?? 0) + 1,
        limit: 20,
        status: selectedStatus.value == 'All' ? null : selectedStatus.value.toUpperCase(),
        location: selectedCategory.value == 'All' ? null : selectedCategory.value,
        date: dateStr,
        search: searchQuery.value.trim().isEmpty ? null : searchQuery.value.trim(),
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
      }
    } catch (e) {
      // Error handled by ApiChecker or repository
    } finally {
      isLoading.value = false;
    }
  }

  final selectedStatus = 'All'.obs;
  final selectedRegion = 'All'.obs;

  void setStatus(String status) {
    selectedStatus.value = status;
    fetchLocations();
    fetchRaces();
  }

  void setRegion(String region) {
    selectedRegion.value = region;
    fetchLocations();
    fetchRaces();
  }

  void resetFilters() {
    selectedStatus.value = 'All';
    selectedRegion.value = 'All';
    fetchLocations();
    fetchRaces();
  }

  void selectCategory(String category) {
    selectedCategory.value = category;
    fetchRaces();
  }

  void searchRaces(String query) {
    searchQuery.value = query;
    fetchLocations();
    fetchRaces();
  }
}

