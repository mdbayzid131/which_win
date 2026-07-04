import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:which_win/core/services/storage_service.dart';
import 'package:which_win/config/constants/storage_constants.dart';
import 'package:which_win/core/utils/custom_snackbar.dart';

class GiftAFriendController extends GetxController {
  final referralCode = '70492F72B'.obs;
  final remainingInvites = 4.obs;
  final referenceController = TextEditingController();
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final userIdStr = await StorageService.getString(StorageConstants.userId);
      if (userIdStr.isNotEmpty) {
        referralCode.value = _generateReferralCode(userIdStr);
      }
      
      final invites = await StorageService.getInt('remaining_invites_key');
      if (invites != -1) {
        remainingInvites.value = invites;
      } else {
        await StorageService.setInt('remaining_invites_key', 4);
        remainingInvites.value = 4;
      }
    } catch (e) {
      // Fallback in case of storage issue
      remainingInvites.value = 4;
    }
  }

  String _generateReferralCode(String id) {
    if (id.isEmpty) return '70492F72B';
    final cleaned = id.replaceAll('-', '').toUpperCase();
    if (cleaned.length >= 9) {
      return cleaned.substring(cleaned.length - 9);
    }
    return cleaned.padRight(9, 'X');
  }

  void copyCode() {
    Clipboard.setData(ClipboardData(text: referralCode.value));
    CustomSnackBar.success('referral_copied'.tr);
  }

  void shareCode() {
    final String currentLang = Get.locale?.languageCode ?? 'en';
    final String text = currentLang == 'tr'
        ? 'Selam! Which Win uygulamasını incele ve 7 günlük ücretsiz premium kullanımı almak için referans kodumu kullan: ${referralCode.value}'
        : 'Hey! Check out Which Win app and use my referral code: ${referralCode.value} to get 7 days of free premium usage!';
    Share.share(text);
  }

  Future<void> approveCode() async {
    final code = referenceController.text.trim();
    if (code.isEmpty) {
      CustomSnackBar.error('invalid_code'.tr);
      return;
    }
    if (code.toUpperCase() == referralCode.value) {
      CustomSnackBar.error('cannot_use_own_code'.tr);
      return;
    }

    isLoading.value = true;
    try {
      // Simulate API verification call
      await Future.delayed(const Duration(milliseconds: 1500));
      
      // Save locally
      if (remainingInvites.value > 0) {
        remainingInvites.value = remainingInvites.value - 1;
        await StorageService.setInt('remaining_invites_key', remainingInvites.value);
      }

      // Unlock premium locally
      await StorageService.setBool(StorageConstants.isPremium, true);
      
      CustomSnackBar.success('code_approved_success'.tr);
      referenceController.clear();
    } catch (e) {
      CustomSnackBar.error('invalid_code'.tr);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    referenceController.dispose();
    super.onClose();
  }
}
