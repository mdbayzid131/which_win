import 'package:get/get.dart';
import 'package:which_win/core/services/api_checker.dart';
import 'package:which_win/data/models/race_details_model.dart';
import 'package:which_win/data/models/race_model.dart';
import 'package:which_win/data/models/race_statistics_model.dart';
import 'package:which_win/data/repositories/race_repository.dart';

class RaceDetailsController extends GetxController {
  final RaceRepo _raceRepo = Get.find<RaceRepo>();

  final race = Rxn<RaceModel>();
  final raceDetails = Rxn<RaceDetailsData>();
  final raceStats = Rxn<RaceStatsData>();
  
  final isLoading = false.obs;
  final isStatsLoading = false.obs;
  final selectedTab = 0.obs;
  final expandedIndex = (-1).obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is RaceModel) {
      race.value = Get.arguments;
      fetchRaceDetails();
    }
  }

  Future<void> fetchRaceDetails() async {
    if (race.value?.id == null) return;

    isLoading.value = true;
    try {
      final response = await _raceRepo.getRaceDetails(race.value!.id!);
      ApiChecker.checkGetApi(response);

      if (response.statusCode == 200) {
        final raceDetailsResponse = RaceDetailsResponse.fromJson(response.data);
        raceDetails.value = raceDetailsResponse.data;
      }
    } catch (e) {
      // Error handled by ApiChecker
    } finally {
      isLoading.value = false;
    }
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
      // Error handled by ApiChecker
    } finally {
      isStatsLoading.value = false;
    }
  }

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
}
