import 'package:get/get.dart';
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
    isLoading.value = true;
    try {
      final response = await _commonRepo.getLegalContent('privacy');
      ApiChecker.checkGetApi(response);

      if (response.statusCode == 200) {
        // Assuming response.data['data']['content'] exists based on standard patterns
        content.value = response.data['data']?['content'] ?? 'No content available';
      }
    } catch (e) {
      // Error handled by ApiChecker
    } finally {
      isLoading.value = false;
    }
  }
}
