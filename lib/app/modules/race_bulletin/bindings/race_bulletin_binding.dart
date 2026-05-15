import 'package:get/get.dart';
import '../controllers/race_bulletin_controller.dart';

class RaceBulletinBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RaceBulletinController>(
      () => RaceBulletinController(),
    );
  }
}
