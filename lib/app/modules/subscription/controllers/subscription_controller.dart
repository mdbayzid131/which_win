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
    // Default mock plans to match screenshot design
    plans.assignAll([
      SubscriptionPlanModel(
        id: 'weekly',
        name: '1 Week',
        description: '',
        price: 4.99,
        currency: 'USD',
        duration: 'WEEKLY',
        productId: 'com.whichwin.horseracing.weekly',
      ),
      SubscriptionPlanModel(
        id: 'monthly',
        name: '1 Month',
        description: '',
        price: 11.99,
        currency: 'USD',
        duration: 'MONTHLY',
        productId: 'com.whichwin.horseracing.monthly',
      ),
      SubscriptionPlanModel(
        id: 'yearly',
        name: '1 Year',
        description: '',
        price: 59.99,
        currency: 'USD',
        duration: 'YEARLY',
        productId: 'com.whichwin.horseracing.yearly',
      ),
    ]);
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
    debugPrint('SubscriptionController: Initializing product fetching...');
    final bool isAvailable = await _iap.isAvailable();
    if (!isAvailable) {
      debugPrint('SubscriptionController ERROR: In-app billing is NOT available on this device!');
      isStoreLoading.value = false;
      return;
    }

    isStoreLoading.value = true;
    try {
      final Set<String> idsToQuery = GetPlatform.isIOS
          ? _iosProductIds
          : {_androidPremiumProductId};

      debugPrint('SubscriptionController: Querying product details for IDs: $idsToQuery');
      final ProductDetailsResponse response = await _iap.queryProductDetails(
        idsToQuery,
      );
      
      debugPrint('SubscriptionController: Query finished.');
      debugPrint('SubscriptionController: Found products count: ${response.productDetails.length}');
      for (var product in response.productDetails) {
        debugPrint(' - Product ID: ${product.id}, Price: ${product.price}, Title: ${product.title}');
        if (product is GooglePlayProductDetails) {
          debugPrint('   - Android Offer details: ${product.productDetails.subscriptionOfferDetails?.map((o) => o.basePlanId).toList()}');
          debugPrint('   - Subscription Index: ${product.subscriptionIndex}');
        }
      }
      
      if (response.notFoundIDs.isNotEmpty) {
        debugPrint('SubscriptionController WARNING: Product IDs not found in Store: ${response.notFoundIDs}');
      }
      
      if (response.error != null) {
        debugPrint('SubscriptionController ERROR from store query: ${response.error!.message}');
      }

      storeProducts.assignAll(response.productDetails);
      _populatePlansFromStore();
    } catch (e) {
      debugPrint('SubscriptionController EXCEPTION fetching products: $e');
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
      debugPrint('SubscriptionController: Populating plans from ${androidProducts.length} Android products');

      for (final product in androidProducts) {
        final basePlanId = _getAndroidBasePlanId(product);
        if (basePlanId.isNotEmpty) {
          debugPrint('SubscriptionController: Found base plan ID "$basePlanId" for product "${product.id}" via index');
          _addPlan(localPlans, product, basePlanId);
        } else {
          // Fallback 1: Manually iterate subscriptionOfferDetails if available
          final offers = product.productDetails.subscriptionOfferDetails;
          if (offers != null && offers.isNotEmpty) {
            debugPrint('SubscriptionController: basePlanId empty via index, iterating subscriptionOfferDetails manually');
            for (final offer in offers) {
              final bId = offer.basePlanId;
              if (bId.isNotEmpty) {
                debugPrint('SubscriptionController: Found base plan ID "$bId" manually');
                _addPlan(localPlans, product, bId);
              }
            }
          } else {
            // Fallback 2: Simple product ID fallback
            debugPrint('SubscriptionController: No offers found, falling back to product ID "${product.id}"');
            _addPlan(localPlans, product, product.id);
          }
        }
      }

      // Sort plans: weekly -> monthly -> yearly
      localPlans.sort((a, b) {
        final aId = a.id?.toLowerCase() ?? '';
        final bId = b.id?.toLowerCase() ?? '';
        if (aId.contains('weekly')) return -1;
        if (bId.contains('weekly')) return 1;
        if (aId.contains('monthly')) return -1;
        if (bId.contains('monthly')) return 1;
        return 0;
      });

      debugPrint('SubscriptionController: Populated ${localPlans.length} plans successfully');
    }

    plans.assignAll(localPlans);
  }

  void _addPlan(List<SubscriptionPlanModel> localPlans, GooglePlayProductDetails product, String id) {
    if (localPlans.any((p) => p.id == id)) {
      debugPrint('SubscriptionController: Plan with ID "$id" already exists, skipping duplicate');
      return;
    }

    final duration = id.toLowerCase().contains('weekly')
        ? 'WEEKLY'
        : id.toLowerCase().contains('monthly')
            ? 'MONTHLY'
            : 'YEARLY';

    final name = duration == 'WEEKLY'
        ? '1 Week'
        : duration == 'MONTHLY'
            ? '1 Month'
            : '1 Year';

    localPlans.add(SubscriptionPlanModel(
      id: id,
      name: name,
      description: product.description,
      price: product.rawPrice,
      currency: product.currencyCode,
      duration: duration,
      productId: product.id,
    ));
    debugPrint('SubscriptionController: Added Android plan: ID=$id, name=$name, duration=$duration, price=${product.price}');
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
          if (p.id == plan.productId) {
            final basePlanId = _getAndroidBasePlanId(p);
            if (basePlanId == plan.id || (basePlanId.isEmpty && p.id == plan.id)) {
              matchingProduct = p;
              break;
            }
          }
        }
      }
      matchingProduct ??= storeProducts
          .whereType<GooglePlayProductDetails>()
          .firstWhereOrNull((p) => p.id == plan.productId);
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
        GooglePlayProductDetails? matchingProduct;
        for (final p in storeProducts) {
          if (p is GooglePlayProductDetails) {
            if (p.id == plan.productId) {
              final basePlanId = _getAndroidBasePlanId(p);
              if (basePlanId == plan.id || (basePlanId.isEmpty && p.id == plan.id)) {
                matchingProduct = p;
                break;
              }
            }
          }
        }

        matchingProduct ??= storeProducts
            .whereType<GooglePlayProductDetails>()
            .firstWhereOrNull((p) => p.id == plan.productId);

        if (matchingProduct == null) {
          throw Exception(
            'Google Play Store subscription details for "${plan.productId}" not loaded yet.',
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
      debugPrint('SubscriptionController: Purchase stream updated: ProductID=${purchaseDetails.productID}, Status=${purchaseDetails.status}');
      if (purchaseDetails.status == PurchaseStatus.pending) {
        isLoading.value = true;
      } else {
        try {
          if (purchaseDetails.status == PurchaseStatus.error) {
            Get.snackbar(
              'Error',
              'Payment failed: ${purchaseDetails.error?.message}',
            );
          } else if (purchaseDetails.status == PurchaseStatus.canceled) {
            Get.snackbar(
              'Cancelled',
              'Purchase was cancelled by user.',
              snackPosition: SnackPosition.BOTTOM,
            );
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
          }
        } catch (e) {
          debugPrint('SubscriptionController: Error handling purchase update: $e');
        } finally {
          isLoading.value = false;
        }
        if (purchaseDetails.pendingCompletePurchase) {
          try {
            await _iap.completePurchase(purchaseDetails);
          } catch (e) {
            debugPrint('SubscriptionController: Error completing purchase: $e');
          }
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
    } finally {
      isLoading.value = false;
    }
  }
}

extension _IterableExtensions<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
