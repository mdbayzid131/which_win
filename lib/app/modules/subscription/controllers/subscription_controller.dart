import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:dio/dio.dart' as dio;
import 'package:which_win/core/utils/device_helper.dart';
import 'package:which_win/data/models/subscription_model.dart';
import 'package:which_win/data/repositories/subscription_repository.dart';

class SubscriptionController extends GetxController {

  final plans = <SubscriptionPlanModel>[].obs;
  final isLoading = false.obs;
  final selectedPlanIndex = 0.obs;

  // In-App Purchase properties
  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _iapSubscription;
  final storeProducts = <ProductDetails>[].obs;
  final isStoreLoading = false.obs;

  // Subscription Product IDs
  static const String _androidPremiumProductId =
      'com.whichwin.horseracing.premium';
  static const Set<String> _iosProductIds = {
    'com.whichwin.horseracing.weekly',
    'com.whichwin.horseracing.monthly',
    'com.whichwin.horseracing.yearly',
  };

  @override
  void onInit() {
    super.onInit();
    _initializeIAP();
    fetchPlans();
  }

  @override
  void onClose() {
    _iapSubscription?.cancel();
    super.onClose();
  }

  void _initializeIAP() {
    final Stream<List<PurchaseDetails>> purchaseUpdated = _iap.purchaseStream;
    _iapSubscription = purchaseUpdated.listen(
      (purchaseDetailsList) {
        _listenToPurchaseUpdated(purchaseDetailsList);
      },
      onDone: () {
        _iapSubscription?.cancel();
      },
      onError: (error) {
        Get.snackbar('Error', 'Payment stream error: $error');
      },
    );
  }

  Future<void> fetchPlans() async {
    isLoading.value = true;
    try {
      await _fetchStoreProducts();
    } catch (e) {
      // Error handled or logged
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetchStoreProducts() async {
    final bool isAvailable = await _iap.isAvailable();
    if (!isAvailable) {
      isStoreLoading.value = false;
      return;
    }

    isStoreLoading.value = true;
    try {
      final Set<String> idsToQuery = GetPlatform.isIOS
          ? _iosProductIds
          : {_androidPremiumProductId};

      final ProductDetailsResponse response = await _iap.queryProductDetails(
        idsToQuery,
      );
      storeProducts.assignAll(response.productDetails);
      _populatePlansFromStore();
    } catch (e) {
      // Handle error
    } finally {
      isStoreLoading.value = false;
    }
  }

  void _populatePlansFromStore() {
    final List<SubscriptionPlanModel> localPlans = [];

    if (GetPlatform.isIOS) {
      final sortedProducts = List<ProductDetails>.from(storeProducts);
      sortedProducts.sort((a, b) {
        final aId = a.id.toLowerCase();
        final bId = b.id.toLowerCase();
        if (aId.contains('weekly')) return -1;
        if (bId.contains('weekly')) return 1;
        if (aId.contains('monthly')) return -1;
        if (bId.contains('monthly')) return 1;
        return 0;
      });

      for (final product in sortedProducts) {
        final duration = product.id.toLowerCase().contains('weekly')
            ? 'WEEKLY'
            : product.id.toLowerCase().contains('monthly')
                ? 'MONTHLY'
                : 'YEARLY';
        
        final name = duration == 'WEEKLY'
            ? '1 Week'
            : duration == 'MONTHLY'
                ? '1 Month'
                : '1 Year';

        localPlans.add(SubscriptionPlanModel(
          id: product.id,
          name: name,
          description: product.description,
          price: product.rawPrice,
          currency: product.currencyCode,
          duration: duration,
          productId: product.id,
        ));
      }
    } else if (GetPlatform.isAndroid) {
      final androidProducts = storeProducts.whereType<GooglePlayProductDetails>().toList();
      androidProducts.sort((a, b) {
        final aBase = _getAndroidBasePlanId(a);
        final bBase = _getAndroidBasePlanId(b);
        if (aBase.contains('weekly')) return -1;
        if (bBase.contains('weekly')) return 1;
        if (aBase.contains('monthly')) return -1;
        if (bBase.contains('monthly')) return 1;
        return 0;
      });

      for (final product in androidProducts) {
        final basePlanId = _getAndroidBasePlanId(product);
        if (basePlanId.isEmpty) continue;

        final duration = basePlanId.contains('weekly')
            ? 'WEEKLY'
            : basePlanId.contains('monthly')
                ? 'MONTHLY'
                : 'YEARLY';

        final name = duration == 'WEEKLY'
            ? '1 Week'
            : duration == 'MONTHLY'
                ? '1 Month'
                : '1 Year';

        localPlans.add(SubscriptionPlanModel(
          id: basePlanId,
          name: name,
          description: product.description,
          price: product.rawPrice,
          currency: product.currencyCode,
          duration: duration,
          productId: product.id,
        ));
      }
    }

    plans.assignAll(localPlans);
  }

  String _getAndroidBasePlanId(GooglePlayProductDetails product) {
    final index = product.subscriptionIndex;
    if (index != null) {
      final offers = product.productDetails.subscriptionOfferDetails;
      if (offers != null && index < offers.length) {
        return offers[index].basePlanId;
      }
    }
    return '';
  }

  // Helper to get formatted localized price for the UI
  String getPlanPriceString(SubscriptionPlanModel plan, int index) {
    if (GetPlatform.isIOS) {
      final String? expectedIosId = plan.productId;
      final storeProduct = storeProducts.firstWhereOrNull(
        (p) => p.id == expectedIosId,
      );
      if (storeProduct != null) {
        return storeProduct.price;
      }
    } else if (GetPlatform.isAndroid) {
      GooglePlayProductDetails? matchingProduct;
      for (final p in storeProducts) {
        if (p is GooglePlayProductDetails) {
          if (_getAndroidBasePlanId(p) == plan.id) {
            matchingProduct = p;
            break;
          }
        }
      }
      if (matchingProduct != null) {
        return matchingProduct.price;
      }
    }
    // Fallback if store product not found
    return '${plan.currency ?? 'BDT'} ${plan.price ?? 0}';
  }

  void selectPlan(int index) {
    selectedPlanIndex.value = index;
  }

  Future<void> subscribe() async {
    if (plans.isEmpty) return;

    final plan = plans[selectedPlanIndex.value];

    isLoading.value = true;
    try {
      if (GetPlatform.isIOS) {
        final storeProduct = storeProducts.firstWhereOrNull(
          (p) => p.id == plan.productId,
        );
        if (storeProduct == null) {
          throw Exception(
            'Store product details not loaded yet. Please try again.',
          );
        }
        final PurchaseParam purchaseParam = PurchaseParam(
          productDetails: storeProduct,
        );
        await _iap.buyNonConsumable(purchaseParam: purchaseParam);
      } else if (GetPlatform.isAndroid) {
        final expectedBasePlanId = plan.id;
        GooglePlayProductDetails? matchingProduct;
        for (final p in storeProducts) {
          if (p is GooglePlayProductDetails) {
            final index = p.subscriptionIndex;
            if (index != null) {
              final offers = p.productDetails.subscriptionOfferDetails;
              if (offers != null && index < offers.length) {
                if (offers[index].basePlanId == expectedBasePlanId) {
                  matchingProduct = p;
                  break;
                }
              }
            }
          }
        }

        if (matchingProduct == null) {
          throw Exception(
            'Google Play Store subscription details not loaded yet.',
          );
        }

        final GooglePlayPurchaseParam purchaseParam = GooglePlayPurchaseParam(
          productDetails: matchingProduct,
          changeSubscriptionParam: null,
        );

        await _iap.buyNonConsumable(purchaseParam: purchaseParam);
      } else {
        throw Exception('Subscriptions are only supported on Android and iOS.');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
      isLoading.value = false;
    }
  }

  Future<void> _listenToPurchaseUpdated(
    List<PurchaseDetails> purchaseDetailsList,
  ) async {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        isLoading.value = true;
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          Get.snackbar(
            'Error',
            'Payment failed: ${purchaseDetails.error?.message}',
          );
          isLoading.value = false;
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          final bool valid = await _validatePurchaseAndActivate(
            purchaseDetails,
          );
          if (valid) {
            Get.snackbar(
              'Success',
              'Your subscription is active!',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: const Color(0xFF00695C),
              colorText: Colors.white,
            );
          } else {
            Get.snackbar('Error', 'Failed to verify purchase with backend.');
          }
          isLoading.value = false;
        }
        if (purchaseDetails.pendingCompletePurchase) {
          await _iap.completePurchase(purchaseDetails);
        }
      }
    }
  }

  Future<bool> _validatePurchaseAndActivate(
    PurchaseDetails purchaseDetails,
  ) async {
    try {
      final deviceId = await DeviceHelper.getDeviceId();
      final subscriptionRepo = Get.find<SubscriptionRepo>();
      final dio.Response response;

      if (GetPlatform.isIOS) {
        response = await subscriptionRepo.verifyAppleSubscription(
          signedTransactionInfo: purchaseDetails.verificationData.serverVerificationData,
          deviceId: deviceId,
        );
      } else if (GetPlatform.isAndroid) {
        response = await subscriptionRepo.verifyGoogleSubscription(
          purchaseToken: purchaseDetails.verificationData.serverVerificationData,
          productId: purchaseDetails.productID,
          deviceId: deviceId,
        );
      } else {
        return false;
      }

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  void restorePurchases() async {
    isLoading.value = true;
    try {
      await _iap.restorePurchases();
    } catch (e) {
      Get.snackbar('Error', 'Restore failed: $e');
      isLoading.value = false;
    }
  }
}
