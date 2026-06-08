import 'package:get/get.dart';
import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:which_win/config/constants/storage_constants.dart';

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
  }

  Future<void> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();

    String? savedLang = prefs.getString(StorageConstants.languageCode);

    if (savedLang != null) {
      locale.value = Locale(savedLang);
    } else {
      locale.value = const Locale('en');
    }

    Get.updateLocale(locale.value);
  }
}
