import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:which_win/core/utils/custom_snackbar.dart';
import 'package:which_win/data/repositories/common_repository.dart';

class RateUsController extends GetxController {
  final CommonRepo _commonRepo = Get.find<CommonRepo>();

  final rating = 0.obs;
  final commentController = TextEditingController();
  final isLoading = false.obs;

  void setRating(int value) {
    rating.value = value;
  }

  Future<void> submitRating() async {
    if (rating.value == 0) {
      CustomSnackBar.error('please_select_rating'.tr);
      return;
    }

    isLoading.value = true;
    try {
      final response = await _commonRepo.rateUs(
        rating: rating.value,
        comment: commentController.text,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        CustomSnackBar.success('thank_you_feedback'.tr);
        Get.back();
      }
    } catch (e) {
      CustomSnackBar.error('failed_submit_rating'.tr);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    commentController.dispose();
    super.onClose();
  }
}
