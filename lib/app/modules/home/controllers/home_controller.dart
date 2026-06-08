import 'package:get/get.dart';
import 'package:which_win/core/services/api_checker.dart';
import 'package:which_win/data/models/race_model.dart';
import 'package:which_win/data/repositories/race_repository.dart';

class HomeController extends GetxController {
  final RaceRepo _raceRepo = Get.find<RaceRepo>();

  final selectedCategory = 'All'.obs;
  final categories = <String>['All', 'Tumu', 'Guvnell', 'Guvnell 2', 'Guvnell 3', 'Guvnell 4'].obs;

  final raceList = <RaceModel>[].obs;
  final isLoading = false.obs;
  final meta = Rxn<RaceMeta>();

  @override
  void onInit() {
    super.onInit();
    fetchRaces();
  }

  Future<void> fetchRaces({bool isRefresh = true}) async {
    if (isRefresh) {
      isLoading.value = true;
    }

    try {
      final response = await _raceRepo.getRaces(
        page: isRefresh ? 1 : (meta.value?.page ?? 0) + 1,
        limit: 20,
        status: selectedStatus.value == 'All' ? null : selectedStatus.value.toUpperCase(),
        location: selectedCategory.value == 'All' ? null : selectedCategory.value,
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
}
