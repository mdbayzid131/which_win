import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SubscriptionController extends GetxController {
  final isActive = false.obs;
  final selectedPlan = '1 Week'.obs;

  void selectPlan(String plan) {
    selectedPlan.value = plan;
  }

  void subscribe() {
    isActive.value = true;
    Get.snackbar(
      'Success',
      'You are now subscribed to the ${selectedPlan.value} plan!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF00695C),
      colorText: Colors.white,
    );
  }

  void restorePurchases() {
    Get.snackbar(
      'Restore',
      'Checking for previous purchases...',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF1E293B),
      colorText: Colors.white,
    );
  }
}
