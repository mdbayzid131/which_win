import 'package:get/get.dart';
import 'package:which_win/config/constants/legal_content_constants.dart';
import 'package:which_win/core/services/api_checker.dart';
import 'package:which_win/data/repositories/common_repository.dart';

class PrivacyPolicyController extends GetxController {
  final CommonRepo _commonRepo = Get.find<CommonRepo>();

  final content = ''.obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPrivacyPolicy();
  }

  Future<void> fetchPrivacyPolicy() async {
    final currentLang = Get.locale?.languageCode ?? 'en';
    isLoading.value = true;
    try {
      final response = await _commonRepo.getLegalContent('PRIVACY_POLICY');
      ApiChecker.checkGetApi(response);

      if (response.statusCode == 200) {
        final raw = response.data['data']?['content']?.toString() ?? '';
        final cleaned = LegalContentConstants.cleanHtml(raw);
        if (cleaned.length > 200 && !cleaned.contains('Welcome to GoldenTak')) {
          content.value = cleaned;
        } else {
          content.value = LegalContentConstants.getPrivacy(currentLang);
        }
      } else {
        content.value = LegalContentConstants.getPrivacy(currentLang);
      }
    } catch (e) {
      content.value = LegalContentConstants.getPrivacy(currentLang);
    } finally {
      isLoading.value = false;
    }
  }
}
