import 'package:get/get.dart';
import 'package:which_win/core/services/api_checker.dart';
import 'package:which_win/data/models/race_model.dart';
import 'package:which_win/data/repositories/race_repository.dart';

class RaceBulletinController extends GetxController {
  final RaceRepo _raceRepo = Get.find<RaceRepo>();

  final race = Rxn<RaceModel>();
  final raceList = <RaceModel>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is RaceModel) {
      race.value = Get.arguments;
      fetchRaces();
    }
  }

  Future<void> fetchRaces() async {
    if (race.value == null) return;

    isLoading.value = true;
    try {
      final dateStr = race.value?.date?.split('T').first;
      final response = await _raceRepo.getRaces(
        date: dateStr,
        location: race.value?.location,
      );
      ApiChecker.checkGetApi(response);

      if (response.statusCode == 200) {
        final raceResponse = RacesResponse.fromJson(response.data);
        raceList.assignAll(raceResponse.data ?? []);
      }
    } catch (e) {
      // Error handled by ApiChecker
    } finally {
      isLoading.value = false;
    }
  }
}
