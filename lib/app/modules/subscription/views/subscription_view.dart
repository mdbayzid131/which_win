import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:which_win/app/routes/app_pages.dart';
import 'package:which_win/core/services/user_service.dart';
import 'package:which_win/data/models/subscription_model.dart';
import '../controllers/subscription_controller.dart';

class SubscriptionView extends StatefulWidget {
  const SubscriptionView({super.key});

  @override
  State<SubscriptionView> createState() => _SubscriptionViewState();
}

class _SubscriptionViewState extends State<SubscriptionView> {
  final controller = Get.find<SubscriptionController>();
  final currentSlideIndex = 0.obs;
  late final PageController pageController;
  Timer? _carouselTimer;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
    _startCarouselTimer();
  }

  void _startCarouselTimer() {
    _carouselTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (pageController.hasClients) {
        final nextIndex = (currentSlideIndex.value + 1) % 5;
        pageController.animateToPage(
          nextIndex,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _carouselTimer?.cancel();
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Stack(
        children: [
          // Content Scroll
          SafeArea(
            child: Column(
              children: [
                // Custom App Bar Header
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  child: Row(
                    children: [
                      _buildBackButton(),
                      Expanded(
                        child: Center(
                          child: Text(
                            'subscription_title'.tr,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 40.w), // Balance the back button
                    ],
                  ),
                ),

                // Main dynamic content
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value &&
                        controller.plans.isEmpty) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF2DD4BF),
                        ),
                      );
                    }

                    if (controller.plans.isEmpty) {
                      return _buildErrorOrEmptyState();
                    }

                    return SingleChildScrollView(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Logo text
                          _buildProLogo(),
                          SizedBox(height: 16.h),

                          // Active Subscription Banner Card (if user has active subscription)
                          Obx(() {
                            if (controller.isSubscribed.value) {
                              return Padding(
                                padding: EdgeInsets.only(bottom: 20.h),
                                child: _buildActiveSubscriptionCard(),
                              );
                            }
                            return const SizedBox.shrink();
                          }),

                          // Carousel/Slide Section
                          _buildCarouselSection(context),
                          SizedBox(height: 24.h),

                          // Plans Section
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'choose_plan'.tr,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 16.h),
                                ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: controller.plans.length,
                                  separatorBuilder: (context, index) =>
                                      SizedBox(height: 16.h),
                                  itemBuilder: (context, index) {
                                    final plan = controller.plans[index];
                                    return _buildPlanCard(plan, index);
                                  },
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 24.h),

                          // Checkout Form / Bottom Button
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24.w),
                            child: _buildCheckoutSection(),
                          ),
                          SizedBox(height: 12.h),
                        ],
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),

          // Loader Overlay (for purchase in-progress)
          Obx(() {
            if (controller.isLoading.value && controller.plans.isNotEmpty) {
              return Container(
                color: Colors.black54,
                child: const Center(
                  child: CircularProgressIndicator(color: Color(0xFF2DD4BF)),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Get.back(),
      child: Padding(
        padding: EdgeInsets.all(6.r),
        child: Container(
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white24, width: 1.2),
            shape: BoxShape.circle,
            color: Colors.black.withValues(alpha: 0.2),
          ),
          child: Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18.sp),
        ),
      ),
    );
  }

  Widget _buildProLogo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "WHICH ",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22.sp,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
        Text(
          "WIN ",
          style: TextStyle(
            color: const Color(0xFF2DD4BF),
            fontSize: 22.sp,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: const Color(0xFFFFCC00),
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Text(
            "PRO",
            style: TextStyle(
              color: Colors.black,
              fontSize: 10.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCarouselSection(BuildContext context) {
    final List<String> descriptions = [
      'carousel_feat_1'.tr,
      'carousel_feat_2'.tr,
      'carousel_feat_3'.tr,
      'carousel_feat_4'.tr,
      'carousel_feat_5'.tr,
    ];

    return Column(
      children: [
        SizedBox(
          height: 190.h,
          child: PageView.builder(
            controller: pageController,
            onPageChanged: (index) => currentSlideIndex.value = index,
            itemCount: 5,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: _buildCarouselSlide(index),
              );
            },
          ),
        ),
        SizedBox(height: 16.h),
        // Active description text below active slide
        Obx(() {
          final index = currentSlideIndex.value;
          final desc = index >= 0 && index < descriptions.length
              ? descriptions[index]
              : descriptions[0];

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: Text(
                desc.toUpperCase(),
                key: ValueKey<String>(desc),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.6,
                ),
              ),
            ),
          );
        }),
        SizedBox(height: 14.h),
        // Dots indicator (5 items)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            return Obx(() {
              final isActive = currentSlideIndex.value == index;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: isActive ? 18.w : 6.w,
                height: 6.w,
                margin: EdgeInsets.symmetric(horizontal: 3.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4.r),
                  color: isActive ? const Color(0xFF2DD4BF) : Colors.white24,
                ),
              );
            });
          }),
        ),
      ],
    );
  }

  Widget _buildCarouselSlide(int index) {
    String imagePath;
    IconData iconData;
    String badgeTag;
    Color accentColor;

    switch (index) {
      case 0:
        imagePath = 'assets/images/premium_race_header.png';
        iconData = Icons.all_inclusive_rounded;
        badgeTag = 'UNLIMITED';
        accentColor = const Color(0xFF2DD4BF);
        break;
      case 1:
        imagePath = 'assets/images/horse_racing_bg.png';
        iconData = Icons.psychology_rounded;
        badgeTag = 'AI POWERED';
        accentColor = const Color(0xFF10B981);
        break;
      case 2:
        imagePath = 'assets/images/race_analysis_header.png';
        iconData = Icons.insights_rounded;
        badgeTag = 'ALGORITHM';
        accentColor = const Color(0xFF38BDF8);
        break;
      case 3:
        imagePath = 'assets/images/horse_racing_bg.png';
        iconData = Icons.query_stats_rounded;
        badgeTag = 'RISK %';
        accentColor = const Color(0xFFFBBF24);
        break;
      case 4:
      default:
        imagePath = 'assets/images/race_analysis_header.png';
        iconData = Icons.leaderboard_rounded;
        badgeTag = 'HEAD-TO-HEAD';
        accentColor = const Color(0xFFA78BFA);
        break;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(14.r),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Image.asset(
            imagePath,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(color: const Color(0xFF1E293B)),
          ),
          // Dark Gradient Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withValues(alpha: 0.75),
                  Colors.black.withValues(alpha: 0.4),
                  Colors.black.withValues(alpha: 0.8),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Center Icon & Badge
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: accentColor.withValues(alpha: 0.6),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withValues(alpha: 0.35),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    iconData,
                    color: accentColor,
                    size: 38.sp,
                  ),
                ),
                SizedBox(height: 10.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.white24, width: 0.8),
                  ),
                  child: Text(
                    badgeTag,
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveSubscriptionCard() {
    return Obx(() {
      final rawPlanName = UserService.to.subscriptionPlan.value.isNotEmpty
          ? UserService.to.subscriptionPlan.value
          : (controller.activePlanName.value.isNotEmpty
              ? controller.activePlanName.value
              : 'PRO Subscription');

      final isTrial = UserService.to.isTrial;
      final remainingDays = UserService.to.remainingDays;

      final planName = isTrial ? '7_day_free_trial'.tr : rawPlanName.toUpperCase();
      final subtitle = isTrial
          ? '$remainingDays ${'days_trial_left'.tr}'
          : 'active_unlimited_access'.tr;

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF00695C), Color(0xFF0F1419)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: const Color(0xFF2DD4BF).withValues(alpha: 0.6),
              width: 1.2,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: const BoxDecoration(
                  color: Color(0xFF2DD4BF),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.stars_rounded,
                  color: Colors.black,
                  size: 22.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'current_plan_title'.tr,
                      style: TextStyle(
                        color: const Color(0xFF2DD4BF),
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      planName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11.sp,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF2DD4BF).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: const Color(0xFF2DD4BF)),
                ),
                child: Text(
                  'active_badge'.tr,
                  style: TextStyle(
                    color: const Color(0xFF2DD4BF),
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildPlanCard(SubscriptionPlanModel plan, int index) {
    return Obx(() {
      final isSelected = controller.selectedPlanIndex.value == index;
      final isActivePlan =
          controller.isSubscribed.value &&
          (plan.productId == controller.activeProductId.value ||
              plan.id == controller.activeProductId.value);
      String priceStr = controller.getPlanPriceString(plan, index);
      String subtitle = controller.getWeeklySubtitle(plan, index);
      String localizedName = controller.getLocalizedPlanName(plan, index);

      return GestureDetector(
        onTap: () => controller.selectPlan(index),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
          decoration: BoxDecoration(
            color: const Color(0xFF0F1419),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF2DD4BF)
                  : (isActivePlan
                        ? const Color(0xFF2DD4BF).withValues(alpha: 0.5)
                        : Colors.white12),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              // Circular Indicator
              Icon(
                isSelected
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_off_outlined,
                color: isSelected ? const Color(0xFF2DD4BF) : Colors.white54,
                size: 24.sp,
              ),
              SizedBox(width: 16.w),

              // Plan Name & Price Subtext
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          localizedName,
                          style: TextStyle(
                            color: isSelected
                                ? const Color(0xFF2DD4BF)
                                : Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (isActivePlan) ...[
                          SizedBox(width: 8.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF2DD4BF,
                              ).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4.r),
                              border: Border.all(
                                color: const Color(0xFF2DD4BF),
                                width: 0.8,
                              ),
                            ),
                            child: Text(
                              'active_badge'.tr,
                              style: TextStyle(
                                color: const Color(0xFF2DD4BF),
                                fontSize: 9.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      priceStr,
                      style: TextStyle(color: Colors.white54, fontSize: 14.sp),
                    ),
                  ],
                ),
              ),

              // Right side weekly breakdown (Calculated dynamically)
              if (subtitle.isNotEmpty)
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.white30, fontSize: 13.sp),
                ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildCheckoutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Obx(() {
          final nextDate = controller.getNextBillingDate();
          if (nextDate.isEmpty) return const SizedBox.shrink();
          return Padding(
            padding: EdgeInsets.only(bottom: 16.h),
            child: Center(
              child: Text(
                "${'next_billing_date'.tr} $nextDate",
                style: TextStyle(color: Colors.white38, fontSize: 13.sp),
              ),
            ),
          );
        }),
        Obx(() {
          if (controller.isSubscribed.value) {
            return Column(
              children: [
                SizedBox(
                  height: 56.h,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => controller.manageSubscription(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2DD4BF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      elevation: 8,
                      shadowColor: const Color(0xFF2DD4BF).withValues(alpha: 0.4),
                    ),
                    child: Text(
                      'manage_subscription'.tr,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                TextButton(
                  onPressed: () => controller.subscribe(),
                  child: Text(
                    'change_plan'.tr,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13.sp,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            );
          }

          return SizedBox(
            height: 56.h,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => controller.subscribe(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2DD4BF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
                elevation: 8,
                shadowColor: const Color(0xFF2DD4BF).withValues(alpha: 0.4),
              ),
              child: Text(
                'subscribe_now'.tr,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }),
        SizedBox(height: 12.h),
        Center(
          child: TextButton(
            onPressed: () => controller.restorePurchases(),
            child: Text(
              'restore_purchases'.tr,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
        SizedBox(height: 6.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => Get.toNamed(AppRoutes.TERMS_CONDITIONS),
              child: Text(
                'terms_conditions'.tr,
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 11.sp,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Text(
                '•',
                style: TextStyle(color: Colors.white38, fontSize: 11.sp),
              ),
            ),
            GestureDetector(
              onTap: () => Get.toNamed(AppRoutes.PRIVACY_POLICY),
              child: Text(
                'privacy_policy'.tr,
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 11.sp,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Text(
          GetPlatform.isIOS
              ? 'recurring_billing_desc_ios'.tr
              : (GetPlatform.isAndroid
                  ? 'recurring_billing_desc_android'.tr
                  : 'recurring_billing_desc'.tr),
          style: TextStyle(color: Colors.white38, fontSize: 10.sp, height: 1.3),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildErrorOrEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 24.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 76.w,
              height: 76.w,
              decoration: BoxDecoration(
                color: const Color(0xFF1E222B),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white12),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                color: const Color(0xFF2DD4BF),
                size: 38.sp,
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'no_product_found'.tr,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            Obx(
              () => Text(
                controller.errorMessage.value.isNotEmpty
                    ? controller.errorMessage.value
                    : 'no_product_found_desc'.tr,
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 13.sp,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: 160.w,
              height: 46.h,
              child: ElevatedButton.icon(
                onPressed: () => controller.fetchPlans(),
                icon: Icon(
                  Icons.refresh_rounded,
                  size: 20.sp,
                  color: Colors.black,
                ),
                label: Text(
                  'try_again'.tr,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2DD4BF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            TextButton(
              onPressed: () => controller.restorePurchases(),
              child: Text(
                'restore_purchases'.tr,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13.sp,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
