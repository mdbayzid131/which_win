import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RateUsController extends GetxController {
  final rating = 0.obs;

  void setRating(int value) {
    rating.value = value;
  }

  void submitRating() {
    if (rating.value > 0) {
      Get.snackbar(
        'Thank you!',
        'Your rating of ${rating.value} stars helps us improve.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF00695C),
        colorText: Colors.white,
      );
      Get.back();
    } else {
      Get.snackbar(
        'Oops',
        'Please select a rating before submitting.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFC62828),
        colorText: Colors.white,
      );
    }
  }
}
