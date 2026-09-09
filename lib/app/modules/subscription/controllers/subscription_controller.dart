import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart' as dio;
import 'package:url_launcher/url_launcher.dart';
import 'package:which_win/config/constants/storage_constants.dart';
import 'package:which_win/core/services/storage_service.dart';
import 'package:which_win/core/services/user_service.dart';
import 'package:which_win/core/utils/device_helper.dart';
import 'package:which_win/data/models/subscription_model.dart';
import 'package:which_win/data/repositories/subscription_repository.dart';

class SubscriptionController extends GetxController {

  final plans = <SubscriptionPlanModel>[].obs;
  final isLoading = false.obs;
  final selectedPlanIndex = 0.obs;
  final errorMessage = ''.obs;

  // Active Subscription State
  final isSubscribed = false.obs;
  final activePlanName = ''.obs;
  final activeProductId = ''.obs;

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
    _checkActiveSubscription();
    _initializeIAP();
    fetchPlans();
  }

  Future<void> _checkActiveSubscription() async {
    final bool savedIsPremium = UserService.to.isPremium.value;
    final String savedProductId = await StorageService.getString('active_subscription_product_id');
    final String savedPlanName = UserService.to.subscriptionPlan.value;

    isSubscribed.value = savedIsPremium;
    if (savedProductId.isNotEmpty) activeProductId.value = savedProductId;
    if (savedPlanName.isNotEmpty) activePlanName.value = savedPlanName;
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
      errorMessage.value = 'no_product_found'.tr;
      plans.clear();
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

    // If store products query returns empty (e.g. no products approved or offline)
    if (localPlans.isEmpty) {
      debugPrint('SubscriptionController: Store query empty; no products found from Store Console.');
      if (errorMessage.value.isEmpty) {
        errorMessage.value = 'no_product_found'.tr;
      }
    }

    debugPrint('SubscriptionController: Populated ${localPlans.length} plans');
    plans.assignAll(localPlans);

    // Auto select active plan index if user is currently subscribed
    if (activeProductId.value.isNotEmpty) {
      final activeIndex = plans.indexWhere(
        (p) => p.productId == activeProductId.value || p.id == activeProductId.value,
      );
      if (activeIndex != -1) {
        selectedPlanIndex.value = activeIndex;
        if (plans[activeIndex].name != null) {
          activePlanName.value = plans[activeIndex].name!;
        }
      }
    }
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

  String getLocalizedPlanName(SubscriptionPlanModel plan, int index) {
    final duration = plan.duration?.toUpperCase() ?? '';
    final id = plan.id?.toLowerCase() ?? '';
    final name = plan.name?.toLowerCase() ?? '';

    if (duration.contains('WEEK') || id.contains('week') || name.contains('week') || index == 0) {
      return 'plan_1_week'.tr;
    } else if (duration.contains('MONTH') || id.contains('month') || name.contains('month') || index == 1) {
      return 'plan_1_month'.tr;
    } else if (duration.contains('YEAR') || id.contains('year') || name.contains('year') || index == 2) {
      return 'plan_1_year'.tr;
    }
    return plan.name ?? '';
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
      return '$symbol$weeklyRate ${'per_week'.tr}';
    } else if (duration.contains('YEAR') || id.contains('yearly') || index == 2) {
      final weeklyRate = (price / 52.0).toStringAsFixed(2);
      return '$symbol$weeklyRate ${'per_week'.tr}';
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
            'Subscription details for "${plan.productId}" not loaded yet.',
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

  // Track verified product IDs and completed transaction IDs in the current session
  final Set<String> _verifiedProductIds = {};
  final Set<String> _completedTransactionIds = {};
  bool _isRestoring = false;
  int _restoredPurchasesCount = 0;

  Future<void> _listenToPurchaseUpdated(
    List<PurchaseDetails> purchaseDetailsList,
  ) async {
    if (purchaseDetailsList.isEmpty) return;

    bool newSuccessVerified = false;
    bool hasError = false;
    String lastErrorMessage = '';

    // Group purchased/restored items by productID to select the single latest transaction per product
    final Map<String, PurchaseDetails> latestPurchasesByProduct = {};

    for (final PurchaseDetails pd in purchaseDetailsList) {
      debugPrint('SubscriptionController: Stream item: ProductID=${pd.productID}, Status=${pd.status}, PurchaseID=${pd.purchaseID}');

      if (pd.status == PurchaseStatus.error) {
        hasError = true;
        lastErrorMessage = pd.error?.message ?? 'Payment failed';
        // Clear pending failed transaction so queue is not blocked
        if (pd.pendingCompletePurchase) {
          try {
            await _iap.completePurchase(pd);
          } catch (_) {}
        }
      } else if (pd.status == PurchaseStatus.canceled) {
        if (!Get.isSnackbarOpen) {
          Get.snackbar(
            'Cancelled',
            'Purchase was cancelled by user.',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
        if (pd.pendingCompletePurchase) {
          try {
            await _iap.completePurchase(pd);
          } catch (_) {}
        }
      } else if (pd.status == PurchaseStatus.purchased || pd.status == PurchaseStatus.restored) {
        if (pd.status == PurchaseStatus.restored) {
          _restoredPurchasesCount++;
        }
        latestPurchasesByProduct[pd.productID] = pd;
      }
    }

    // Turn off loader if no valid purchased/restored items to process (e.g., canceled or error)
    if (latestPurchasesByProduct.isEmpty) {
      isLoading.value = false;
    } else {
      // Validate transactions with backend
      for (final entry in latestPurchasesByProduct.entries) {
        final String productId = entry.key;
        final PurchaseDetails pd = entry.value;

        // Skip API call if this product ID was already verified in this session
        if (_verifiedProductIds.contains(productId)) {
          debugPrint('SubscriptionController: Product $productId already verified in session. Skipping API call.');
          newSuccessVerified = true;
          // Ensure completed
          final String transId = pd.purchaseID ?? pd.productID;
          if (pd.pendingCompletePurchase && !_completedTransactionIds.contains(transId)) {
            try {
              await _iap.completePurchase(pd);
              _completedTransactionIds.add(transId);
            } catch (_) {}
          }
          continue;
        }

        try {
          isLoading.value = true;
          final bool valid = await _validatePurchaseAndActivate(pd);
          if (valid) {
            _verifiedProductIds.add(productId);
            newSuccessVerified = true;

            // Complete StoreKit / Google Play purchase ONLY AFTER backend verification succeeds
            final String transId = pd.purchaseID ?? pd.productID;
            if (pd.pendingCompletePurchase && !_completedTransactionIds.contains(transId)) {
              try {
                await _iap.completePurchase(pd);
                _completedTransactionIds.add(transId);
                debugPrint('SubscriptionController: Store transaction $transId successfully completed after verification.');
              } catch (e) {
                debugPrint('SubscriptionController: Error completing purchase $transId: $e');
              }
            }

            isSubscribed.value = true;
            activeProductId.value = productId;

            // Match active plan: on Android, match selected plan or basePlanId; on iOS match productId
            String? selectedBasePlanId;
            if (selectedPlanIndex.value >= 0 && selectedPlanIndex.value < plans.length) {
              selectedBasePlanId = plans[selectedPlanIndex.value].id;
            }

            final matchingPlan = plans.firstWhereOrNull(
              (p) =>
                  (selectedBasePlanId != null && p.id == selectedBasePlanId) ||
                  (GetPlatform.isIOS && p.productId == productId),
            ) ?? plans.firstWhereOrNull((p) => p.productId == productId || p.id == productId);

            if (matchingPlan != null) {
              activePlanName.value = matchingPlan.name ?? 'PRO Subscription';
              selectedPlanIndex.value = plans.indexOf(matchingPlan);
            }

            await StorageService.setString('active_subscription_product_id', productId);
            await StorageService.setString('active_subscription_plan_name', activePlanName.value);
          } else {
            hasError = true;
            lastErrorMessage = 'Failed to verify purchase with backend.';
          }
        } catch (e) {
          debugPrint('SubscriptionController: Exception verifying $productId: $e');
        } finally {
          isLoading.value = false;
        }
      }
    }

    isLoading.value = false;

    // Show feedback snackbar only once
    if (newSuccessVerified) {
      if (!Get.isSnackbarOpen) {
        Get.snackbar(
          'Success',
          'Your subscription is active!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF00695C),
          colorText: Colors.white,
        );
      }
    } else if (hasError && !Get.isSnackbarOpen) {
      Get.snackbar('Error', lastErrorMessage);
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
        String? selectedPlanId;
        if (selectedPlanIndex.value >= 0 && selectedPlanIndex.value < plans.length) {
          selectedPlanId = plans[selectedPlanIndex.value].id;
        }

        response = await subscriptionRepo.verifyGoogleSubscription(
          purchaseToken: purchaseDetails.verificationData.serverVerificationData,
          productId: purchaseDetails.productID,
          deviceId: deviceId,
          planId: selectedPlanId,
        );
      } else {
        return false;
      }

      debugPrint('SubscriptionController: Backend verification status=${response.statusCode}, response=${response.data}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Save fresh JWT token and updated user subscription state from backend
        final responseData = response.data?['data'];
        final String? newToken = responseData?['token'];
        if (newToken != null && newToken.isNotEmpty) {
          await StorageService.setString(StorageConstants.bearerToken, newToken);
          debugPrint('SubscriptionController: Updated bearer token with fresh active subscription token');
        }

        final sub = responseData?['user']?['subscription'];
        if (sub != null) {
          await UserService.to.updateSubscriptionData(
            active: true,
            plan: sub['plan'],
            endDate: sub['endDate'],
            startDate: sub['startDate'],
            id: sub['id'],
          );
        } else {
          await UserService.to.updateSubscriptionData(
            active: true,
            plan: activePlanName.value,
          );
        }

        return true;
      }

      return false;
    } catch (e) {
      debugPrint('SubscriptionController: Verification failed with exception: $e');
      return false;
    }
  }

  void restorePurchases() async {
    if (isLoading.value) return;
    isLoading.value = true;
    _isRestoring = true;
    _restoredPurchasesCount = 0;

    try {
      debugPrint('SubscriptionController: Requesting restorePurchases from Store...');
      await _iap.restorePurchases();

      // Give a brief window for store restore stream to deliver any existing transactions
      await Future.delayed(const Duration(seconds: 3));

      if (_isRestoring && _restoredPurchasesCount == 0 && !isSubscribed.value) {
        if (!Get.isSnackbarOpen) {
          Get.snackbar(
            'Restore Purchases',
            'no_active_subscription_found'.tr,
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Restore failed: $e');
    } finally {
      _isRestoring = false;
      isLoading.value = false;
    }
  }

  Future<void> manageSubscription() async {
    try {
      final Uri uri = GetPlatform.isIOS
          ? Uri.parse('https://apps.apple.com/account/subscriptions')
          : Uri.parse('https://play.google.com/store/account/subscriptions');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar('Error', 'Unable to open store subscriptions page.');
      }
    } catch (e) {
      Get.snackbar('Error', 'Could not open subscriptions: $e');
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
