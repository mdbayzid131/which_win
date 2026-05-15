import 'package:get/get.dart';
import '../controllers/race_analysis_controller.dart';

class RaceAnalysisBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RaceAnalysisController>(
      () => RaceAnalysisController(),
    );
  }
}
