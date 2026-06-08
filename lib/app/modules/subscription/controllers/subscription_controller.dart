import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:which_win/core/services/api_checker.dart';
import 'package:which_win/core/utils/device_helper.dart';
import 'package:which_win/data/models/subscription_model.dart';
import 'package:which_win/data/repositories/auth_repository.dart';
import 'package:which_win/data/repositories/subscription_repository.dart';

class SubscriptionController extends GetxController {
  final SubscriptionRepo _subscriptionRepo = Get.find<SubscriptionRepo>();
  final AuthRepo _authRepo = Get.find<AuthRepo>();

  final plans = <SubscriptionPlanModel>[].obs;
  final isLoading = false.obs;
  final selectedPlanIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPlans();
  }

  Future<void> fetchPlans() async {
    isLoading.value = true;
    try {
      final response = await _subscriptionRepo.getPlans();
      ApiChecker.checkGetApi(response);

      if (response.statusCode == 200) {
        final plansResponse = SubscriptionPlansResponse.fromJson(response.data);
        plans.assignAll(plansResponse.data ?? []);
      }
    } catch (e) {
      // Error handled by ApiChecker
    } finally {
      isLoading.value = false;
    }
  }

  void selectPlan(int index) {
    selectedPlanIndex.value = index;
  }

  Future<void> subscribe() async {
    if (plans.isEmpty) return;
    
    final plan = plans[selectedPlanIndex.value];
    final deviceId = await DeviceHelper.getDeviceId();

    isLoading.value = true;
    try {
      final response = await _authRepo.purchaseSubscription(
        deviceId: deviceId,
        planId: plan.id ?? '',
        duration: plan.duration ?? '',
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar(
          'Success',
          'You are now subscribed to the ${plan.name} plan!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF00695C),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Subscription failed. Please try again.');
    } finally {
      isLoading.value = false;
    }
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
