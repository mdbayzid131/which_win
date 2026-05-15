import 'dart:async';
import 'package:get/get.dart';
import 'package:which_win/app/routes/app_pages.dart';

class SplashScreenController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _navigateToHome();
  }

  void _navigateToHome() {
    Timer(const Duration(seconds: 3), () {
      Get.offAllNamed(AppRoutes.HOME);
    });
  }
}
