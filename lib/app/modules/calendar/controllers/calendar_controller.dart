import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:which_win/core/services/api_checker.dart';
import 'package:which_win/data/models/race_model.dart';
import 'package:which_win/data/repositories/race_repository.dart';

class CalendarController extends GetxController {
  final RaceRepo _raceRepo = Get.find<RaceRepo>();

  final selectedDate = DateTime.now().obs;
  final focusedDate = DateTime.now().obs;
  
  final raceDates = <DateTime>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchRaceDates();
  }

  void selectDate(DateTime date) {
    selectedDate.value = date;
    focusedDate.value = date;
  }

  void nextMonth() {
    focusedDate.value = DateTime(focusedDate.value.year, focusedDate.value.month + 1);
    fetchRaceDates();
  }

  void prevMonth() {
    focusedDate.value = DateTime(focusedDate.value.year, focusedDate.value.month - 1);
    fetchRaceDates();
  }

  Future<void> fetchRaceDates() async {
    isLoading.value = true;
    try {
      final monthStr = DateFormat('yyyy-MM').format(focusedDate.value);
      final response = await _raceRepo.getRaceDates(month: monthStr);
      ApiChecker.checkGetApi(response);

      if (response.statusCode == 200) {
        final raceDatesResponse = RaceDatesResponse.fromJson(response.data);
        raceDates.assignAll(
          (raceDatesResponse.data ?? []).map((dateStr) => DateTime.parse(dateStr)).toList(),
        );
      }
    } catch (e) {
      // Error handled by ApiChecker
    } finally {
      isLoading.value = false;
    }
  }
}
