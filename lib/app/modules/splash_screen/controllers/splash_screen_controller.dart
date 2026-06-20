import 'dart:async';
import 'package:get/get.dart';
import 'package:which_win/app/routes/app_pages.dart';
import 'package:which_win/config/constants/storage_constants.dart';
import 'package:which_win/core/services/push_notification_service.dart';
import 'package:which_win/core/services/storage_service.dart';
import 'package:which_win/core/utils/device_helper.dart';
import 'package:which_win/core/utils/helpers.dart';
import 'package:which_win/data/models/device_login_response.dart';
import 'package:which_win/data/repositories/auth_repository.dart';
import 'package:which_win/data/repositories/notification_repository.dart';

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
          Helpers.info('Device login successful');

          // 3.2 Persist premium status locally for instant UI gating
          final sub = loginResponse.data!.user?.subscription;
          bool premiumActive = false;
          if (sub != null && sub.isActive == true && sub.endDate != null) {
            try {
              final expiry = DateTime.parse(sub.endDate!);
              premiumActive = expiry.isAfter(DateTime.now());
            } catch (_) {}
          }
          await StorageService.setBool(StorageConstants.isPremium, premiumActive);
          Helpers.info('Premium status saved: $premiumActive');
          
          // 3.1 Safely register push notification token with backend
          _registerPushToken();
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

  Future<void> _registerPushToken() async {
    try {
      final fcmToken = await FirebaseNotificationService.requestPermissionAndGetToken();
      if (fcmToken != null && fcmToken.isNotEmpty) {
        Helpers.info('FCM Token retrieved, registering...');
        final platform = GetPlatform.isIOS ? 'ios' : 'android';
        final response = await Get.find<NotificationRepo>().registerFcmToken(fcmToken, platform);
        if (response.statusCode == 200 || response.statusCode == 201) {
          Helpers.info('FCM Token registered successfully');
        } else {
          Helpers.warning('Failed to register FCM Token: ${response.statusMessage}');
        }
      }
    } catch (e) {
      Helpers.error('Error registering FCM token: $e');
    }
  }

  void _navigateToHome() {
    Timer(const Duration(seconds: 2), () {
      Get.offAllNamed(AppRoutes.HOME);
    });
  }
}
