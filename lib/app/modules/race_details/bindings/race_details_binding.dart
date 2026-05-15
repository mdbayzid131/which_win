import 'package:get/get.dart';
import '../controllers/race_details_controller.dart';

class RaceDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RaceDetailsController>(
      () => RaceDetailsController(),
    );
  }
}
