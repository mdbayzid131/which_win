import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:which_win/core/utils/custom_snackbar.dart';
import 'package:which_win/data/repositories/common_repository.dart';

class ContactController extends GetxController {
  final CommonRepo _commonRepo = Get.find<CommonRepo>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final subjectController = TextEditingController();
  final messageController = TextEditingController();

  final isLoading = false.obs;

  Future<void> sendContact() async {
    if (nameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        subjectController.text.trim().isEmpty ||
        messageController.text.trim().isEmpty) {
      CustomSnackBar.error('Please fill all fields');
      return;
    }

    // Basic email format check
    if (!GetUtils.isEmail(emailController.text.trim())) {
      CustomSnackBar.error('Please enter a valid email address');
      return;
    }

    isLoading.value = true;
    try {
      final response = await _commonRepo.contactUs(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        subject: subjectController.text.trim(),
        message: messageController.text.trim(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        CustomSnackBar.success('Message sent successfully!');
        nameController.clear();
        emailController.clear();
        subjectController.clear();
        messageController.clear();
      }
    } catch (e) {
      CustomSnackBar.error('Failed to send message');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    subjectController.dispose();
    messageController.dispose();
    super.onClose();
  }
}
