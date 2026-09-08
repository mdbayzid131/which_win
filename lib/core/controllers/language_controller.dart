import 'package:get/get.dart';
import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';
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

  void changeLanguage(String langCode) async {
    Locale newLocale = Locale(langCode);

    locale.value = newLocale;
    Get.updateLocale(newLocale);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(StorageConstants.languageCode, langCode);
    await prefs.setString(StorageConstants.language, langCode);

    // Sync preference with backend if logged in
    try {
      if (Get.isRegistered<ApiClient>()) {
        final token = await StorageService.getString(StorageConstants.bearerToken);
        if (token.isNotEmpty) {
          await Get.find<ApiClient>().patchData(
            '${ApiConstants.baseUrl}/language',
            {'language': langCode},
          );
        }
      }
    } catch (_) {}
  }

  Future<void> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();

    String? savedLang = prefs.getString(StorageConstants.languageCode) ??
        prefs.getString(StorageConstants.language);

    if (savedLang != null) {
      locale.value = Locale(savedLang);
    } else {
      locale.value = const Locale('en');
    }

    Get.updateLocale(locale.value);
  }
}
