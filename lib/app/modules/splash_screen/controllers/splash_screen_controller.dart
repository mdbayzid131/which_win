import 'dart:async';
import 'package:get/get.dart';
import 'package:which_win/app/routes/app_pages.dart';
import 'package:which_win/config/constants/storage_constants.dart';
import 'package:which_win/core/services/storage_service.dart';
import 'package:which_win/core/utils/device_helper.dart';
import 'package:which_win/core/utils/helpers.dart';
import 'package:which_win/data/models/device_login_response.dart';
import 'package:which_win/data/repositories/auth_repository.dart';

class SplashScreenController extends GetxController {
  final AuthRepo _authRepo = Get.find<AuthRepo>();

  @override
  void onInit() {
    super.onInit();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // 1. Get Device ID
      final deviceId = await DeviceHelper.getDeviceId();
      Helpers.debug('Device ID: $deviceId');
      await StorageService.setString(StorageConstants.userId, deviceId); // Store device ID as user ID for reference

      // 2. Device Login
      final response = await _authRepo.deviceLogin(deviceId);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final loginResponse = DeviceLoginResponse.fromJson(response.data);
        
        if (loginResponse.data?.token != null) {
          // 3. Save Token and User Info
          await StorageService.setString(StorageConstants.bearerToken, loginResponse.data!.token!);
          // You might want to save more user info here if needed
          Helpers.info('Device login successful');
        }
      } else {
        Helpers.error('Device login failed: ${response.statusMessage}');
      }
    } catch (e) {
      Helpers.error('Error during splash initialization: $e');
    } finally {
      // 4. Navigate to Home
      _navigateToHome();
    }
  }

  void _navigateToHome() {
    Timer(const Duration(seconds: 2), () {
      Get.offAllNamed(AppRoutes.HOME);
    });
  }
}
