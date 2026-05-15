import 'package:get/get.dart';
import 'package:which_win/app/modules/home/controllers/home_controller.dart';
import 'package:which_win/app/modules/calendar/controllers/calendar_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<CalendarController>(() => CalendarController());
  }
}
