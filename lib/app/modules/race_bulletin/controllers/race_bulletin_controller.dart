import 'package:get/get.dart';
import 'package:which_win/core/services/api_checker.dart';
import 'package:which_win/data/models/race_details_model.dart';
import 'package:which_win/data/models/race_model.dart';
import 'package:which_win/data/repositories/race_repository.dart';

class RaceBulletinController extends GetxController {
  final RaceRepo _raceRepo = Get.find<RaceRepo>();

  final race = Rxn<RaceModel>();
  final raceDetails = Rxn<RaceDetailsData>();
  final isLoading = false.obs;

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
}
