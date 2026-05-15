import 'package:get/get.dart';

class CalendarController extends GetxController {
  final selectedDate = DateTime.now().obs;
  final focusedDate = DateTime.now().obs;

  void selectDate(DateTime date) {
    selectedDate.value = date;
    focusedDate.value = date;
  }

  void nextMonth() {
    focusedDate.value = DateTime(focusedDate.value.year, focusedDate.value.month + 1);
  }

  void prevMonth() {
    focusedDate.value = DateTime(focusedDate.value.year, focusedDate.value.month - 1);
  }
}
