import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart' as dio;
import 'package:which_win/core/utils/device_helper.dart';
import 'package:which_win/data/models/subscription_model.dart';
import 'package:which_win/data/repositories/subscription_repository.dart';

class SubscriptionController extends GetxController {

  final plans = <SubscriptionPlanModel>[].obs;
  final isLoading = false.obs;
  final selectedPlanIndex = 0.obs;
  final errorMessage = ''.obs;

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
    errorMessage.value = '';
    try {
      // Fetch live localized products directly from Apple App Store / Google Play Store Console
      await _fetchStoreProducts();
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetchStoreProducts() async {
    debugPrint('SubscriptionController: Initializing product fetching from Store Console...');
    final bool isAvailable = await _iap.isAvailable();
    if (!isAvailable) {
      debugPrint('SubscriptionController WARNING: In-app billing is NOT available on this device!');
      _populatePlansFromStore();
      isStoreLoading.value = false;
      return;
    }

    isStoreLoading.value = true;
    try {
      final Set<String> idsToQuery = {};

      if (GetPlatform.isIOS) {
        idsToQuery.addAll(_iosProductIds);
      } else {
        idsToQuery.add(_androidPremiumProductId);
      }

      debugPrint('SubscriptionController: Querying Store Console for IDs: $idsToQuery');
      final ProductDetailsResponse response = await _iap.queryProductDetails(
        idsToQuery,
      );
      
      debugPrint('SubscriptionController: Query finished.');
      debugPrint('SubscriptionController: Found store products count: ${response.productDetails.length}');
      for (var product in response.productDetails) {
        debugPrint(' - Store Product: ID=${product.id}, Price=${product.price}, Title=${product.title}');
        if (product is GooglePlayProductDetails) {
          debugPrint('   - Offers: ${product.productDetails.subscriptionOfferDetails?.map((o) => o.basePlanId).toList()}');
          debugPrint('   - Subscription Index: ${product.subscriptionIndex}');
        }
      }
      
      if (response.notFoundIDs.isNotEmpty) {
        debugPrint('SubscriptionController WARNING: Product IDs not found in Store: ${response.notFoundIDs}');
      }
      
      if (response.error != null) {
        debugPrint('SubscriptionController ERROR from store query: ${response.error!.message}');
        errorMessage.value = response.error!.message;
      }

      storeProducts.assignAll(response.productDetails);
      _populatePlansFromStore();
    } catch (e) {
      debugPrint('SubscriptionController EXCEPTION fetching products: $e');
      _populatePlansFromStore();
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
          description: product.description.isNotEmpty
              ? product.description
              : '$name Subscription',
          price: product.rawPrice,
          currency: product.currencyCode.isNotEmpty
              ? product.currencyCode
              : 'USD',
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
          _addPlan(localPlans, product, basePlanId);
        } else {
          final offers = product.productDetails.subscriptionOfferDetails;
          if (offers != null && offers.isNotEmpty) {
            for (final offer in offers) {
              final bId = offer.basePlanId;
              if (bId.isNotEmpty) {
                _addPlan(localPlans, product, bId);
              }
            }
          } else {
            _addPlan(localPlans, product, product.id);
          }
        }
      }

      localPlans.sort((a, b) {
        final aId = a.id?.toLowerCase() ?? '';
        final bId = b.id?.toLowerCase() ?? '';
        if (aId.contains('weekly')) return -1;
        if (bId.contains('weekly')) return 1;
        if (aId.contains('monthly')) return -1;
        if (bId.contains('monthly')) return 1;
        return 0;
      });
    }

    // Fallback if store products query returns empty (e.g. on emulator/no active store billing setup)
    if (localPlans.isEmpty) {
      debugPrint('SubscriptionController: Store query empty; populating default store fallback plans');
      if (GetPlatform.isIOS) {
        localPlans.addAll([
          SubscriptionPlanModel(
            id: 'com.whichwin.horseracing.weekly',
            name: '1 Week',
            description: '1 Week Subscription',
            price: 4.99,
            currency: 'USD',
            duration: 'WEEKLY',
            productId: 'com.whichwin.horseracing.weekly',
          ),
          SubscriptionPlanModel(
            id: 'com.whichwin.horseracing.monthly',
            name: '1 Month',
            description: '1 Month Subscription',
            price: 14.99,
            currency: 'USD',
            duration: 'MONTHLY',
            productId: 'com.whichwin.horseracing.monthly',
          ),
          SubscriptionPlanModel(
            id: 'com.whichwin.horseracing.yearly',
            name: '1 Year',
            description: '1 Year Subscription',
            price: 99.99,
            currency: 'USD',
            duration: 'YEARLY',
            productId: 'com.whichwin.horseracing.yearly',
          ),
        ]);
      } else {
        localPlans.addAll([
          SubscriptionPlanModel(
            id: 'weekly-plan',
            name: '1 Week',
            description: '1 Week Subscription',
            price: 4.99,
            currency: 'USD',
            duration: 'WEEKLY',
            productId: _androidPremiumProductId,
          ),
          SubscriptionPlanModel(
            id: 'monthly-plan',
            name: '1 Month',
            description: '1 Month Subscription',
            price: 14.99,
            currency: 'USD',
            duration: 'MONTHLY',
            productId: _androidPremiumProductId,
          ),
          SubscriptionPlanModel(
            id: 'yearly-plan',
            name: '1 Year',
            description: '1 Year Subscription',
            price: 99.99,
            currency: 'USD',
            duration: 'YEARLY',
            productId: _androidPremiumProductId,
          ),
        ]);
      }
    }

    debugPrint('SubscriptionController: Populated ${localPlans.length} plans');
    plans.assignAll(localPlans);
  }

  void _addPlan(
    List<SubscriptionPlanModel> localPlans,
    GooglePlayProductDetails product,
    String id,
  ) {
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
      description: product.description.isNotEmpty
          ? product.description
          : '$name Subscription',
      price: product.rawPrice,
      currency: product.currencyCode.isNotEmpty
          ? product.currencyCode
          : 'USD',
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
    final currencySymbol = _getCurrencySymbol(plan.currency);
    return '$currencySymbol${plan.price ?? 0}';
  }

  // Helper to compute weekly breakdown for monthly/yearly plans
  String getWeeklySubtitle(SubscriptionPlanModel plan, int index) {
    final duration = plan.duration?.toUpperCase() ?? '';
    final id = plan.id?.toLowerCase() ?? '';
    final price = plan.price;
    if (price == null || price <= 0) return '';

    final symbol = _getCurrencySymbol(plan.currency);

    if (duration.contains('MONTH') || id.contains('monthly') || index == 1) {
      final weeklyRate = (price / 4.33).toStringAsFixed(2);
      return '$symbol$weeklyRate / week';
    } else if (duration.contains('YEAR') || id.contains('yearly') || index == 2) {
      final weeklyRate = (price / 52.0).toStringAsFixed(2);
      return '$symbol$weeklyRate / week';
    }
    return '';
  }

  String _getCurrencySymbol(String? currency) {
    if (currency == null || currency.isEmpty) return '\$';
    final c = currency.trim().toUpperCase();
    if (c == 'USD' || c == '\$') return '\$';
    if (c == 'BDT') return '৳';
    if (c == 'EUR') return '€';
    if (c == 'GBP') return '£';
    return '$currency ';
  }

  // Helper to calculate and format the next billing date for the selected plan
  String getNextBillingDate() {
    if (plans.isEmpty ||
        selectedPlanIndex.value < 0 ||
        selectedPlanIndex.value >= plans.length) {
      return '';
    }

    final plan = plans[selectedPlanIndex.value];
    final duration = plan.duration?.toUpperCase() ?? '';
    final id = plan.id?.toLowerCase() ?? '';
    final now = DateTime.now();

    DateTime nextDate;
    if (duration.contains('WEEK') || id.contains('weekly')) {
      nextDate = now.add(const Duration(days: 7));
    } else if (duration.contains('MONTH') || id.contains('monthly')) {
      nextDate = DateTime(now.year, now.month + 1, now.day);
    } else if (duration.contains('YEAR') || id.contains('yearly')) {
      nextDate = DateTime(now.year + 1, now.month, now.day);
    } else {
      nextDate = DateTime(now.year, now.month + 1, now.day);
    }

    return DateFormat('dd MMM, yyyy').format(nextDate);
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

      debugPrint('SubscriptionController: Validating purchase product=${purchaseDetails.productID}, transactionId=${purchaseDetails.purchaseID}');
      if (GetPlatform.isIOS) {
        response = await subscriptionRepo.verifyAppleSubscription(
          signedTransactionInfo: purchaseDetails.verificationData.serverVerificationData,
          receiptData: purchaseDetails.verificationData.serverVerificationData,
          transactionId: purchaseDetails.purchaseID ?? '',
          productId: purchaseDetails.productID,
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

      debugPrint('SubscriptionController: Backend verification status=${response.statusCode}, response=${response.data}');
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('SubscriptionController: Verification failed with exception: $e');
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
