import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:which_win/app/modules/notifications/controllers/notifications_controller.dart';
import 'package:which_win/app/modules/privacy_policy/controllers/privacy_policy_controller.dart';
import 'package:which_win/app/modules/terms_conditions/controllers/terms_conditions_controller.dart';
import 'package:which_win/config/constants/api_constants.dart';
import 'package:which_win/config/constants/storage_constants.dart';
import 'package:which_win/core/services/api_client.dart';
import 'package:which_win/core/services/storage_service.dart';

class LanguageController extends GetxController {
  var locale = const Locale('en').obs;

  @override
  void onInit() {
    loadLanguage();
    super.onInit();
  }

  Future<void> changeLanguage(String langCode) async {
    Locale newLocale = Locale(langCode);

    locale.value = newLocale;
    Get.updateLocale(newLocale);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(StorageConstants.languageCode, langCode);
    await prefs.setString(StorageConstants.language, langCode);
    await StorageService.setString(StorageConstants.languageCode, langCode);
    await StorageService.setString(StorageConstants.language, langCode);

    // Refresh active controllers
    if (Get.isRegistered<TermsConditionsController>()) {
      Get.find<TermsConditionsController>().fetchTerms();
    }
    if (Get.isRegistered<PrivacyPolicyController>()) {
      Get.find<PrivacyPolicyController>().fetchPrivacyPolicy();
    }
    if (Get.isRegistered<NotificationsController>()) {
      Get.find<NotificationsController>().fetchNotifications(isRefresh: true);
    }

    // Sync preference with backend if logged in
    try {
      if (Get.isRegistered<ApiClient>()) {
        final token = await StorageService.getString(StorageConstants.bearerToken);
        if (token.isNotEmpty) {
          final response = await Get.find<ApiClient>().patchData(
            ApiConstants.language,
            {'language': langCode},
          );
          debugPrint('[LanguageController] Language preference synced with backend: ${response.statusCode}');
        }
      }
    } catch (e) {
      debugPrint('[LanguageController] Failed to sync language preference: $e');
    }
  }

  Future<void> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();

    String? savedLang = prefs.getString(StorageConstants.languageCode) ??
        prefs.getString(StorageConstants.language);

    if (savedLang != null && savedLang.isNotEmpty) {
      locale.value = Locale(savedLang);
    } else {
      locale.value = const Locale('en');
    }

    Get.updateLocale(locale.value);
  }
}
