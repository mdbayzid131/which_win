import 'package:get/get.dart';
import 'package:which_win/core/services/api_checker.dart';
import 'package:which_win/data/repositories/common_repository.dart';

class TermsConditionsController extends GetxController {
  final CommonRepo _commonRepo = Get.find<CommonRepo>();

  final content = ''.obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchTerms();
  }

  Future<void> fetchTerms() async {
    isLoading.value = true;
    try {
      final response = await _commonRepo.getLegalContent('TERMS_AND_CONDITIONS');
      ApiChecker.checkGetApi(response);

      if (response.statusCode == 200) {
        content.value = response.data['data']?['content'] ?? 'No content available';
      }
    } catch (e) {
      // Error handled by ApiChecker
    } finally {
      isLoading.value = false;
    }
  }
}
