import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:which_win/data/models/subscription_model.dart';
import '../controllers/subscription_controller.dart';

class SubscriptionView extends GetView<SubscriptionController> {
  SubscriptionView({super.key});

  final currentSlideIndex = 0.obs;
  final PageController pageController = PageController();

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
                            'Subscription'.tr,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 80.w), // Balance the back button
                    ],
                  ),
                ),

                // Main scrollable content
                Expanded(
                  child: Obx(() {
                    if (controller.plans.isEmpty) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF00CC99),
                        ),
                      );
                    }
                    return SingleChildScrollView(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Logo text
                          _buildProLogo(),
                          SizedBox(height: 20.h),

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

          // Loader Overlay
          Obx(() {
            if (controller.isLoading.value) {
              return Container(
                color: Colors.black54,
                child: const Center(
                  child: CircularProgressIndicator(color: Color(0xFF00CC99)),
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
      onTap: () => Get.back(),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white24, width: 1.2),
          borderRadius: BorderRadius.circular(20.r),
          color: Colors.black.withOpacity(0.2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 12.sp),
            SizedBox(width: 6.w),
            Text(
              'back'.tr,
              style: TextStyle(
                color: Colors.white,
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
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
            color: const Color(0xFF00CC99),
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
    return Column(
      children: [
        SizedBox(
          height: 200.h,
          child: PageView.builder(
            controller: pageController,
            onPageChanged: (index) => currentSlideIndex.value = index,
            itemCount: 3,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: _buildMockLeagueList(),
                );
              } else if (index == 1) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Image.asset(
                            'assets/images/horse_racing_bg.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                        Container(color: Colors.black.withOpacity(0.5)),
                        Center(
                          child: Icon(
                            Icons.psychology_rounded,
                            color: const Color(0xFF00CC99),
                            size: 64.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.workspace_premium_rounded,
                            color: Colors.amber[600],
                            size: 56.sp,
                          ),
                          SizedBox(height: 10.h),
                          Text(
                            "AD-FREE EXPERIENCE",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
            },
          ),
        ),
        SizedBox(height: 16.h),
        // Active description text below active slide
        Obx(() {
          final index = currentSlideIndex.value;
          String desc = "";
          if (index == 0) {
            desc = "190 COUNTRIES COVERAGE 1500+ LEAGUE MATCHES";
          } else if (index == 1) {
            desc = "REAL-TIME ALERTS & AI HORSE RACING TIPS";
          } else {
            desc = "EXCLUSIVE AD-FREE PREVIEW & INSIGHTS";
          }
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Text(
              desc,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          );
        }),
        SizedBox(height: 16.h),
        // Dots indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            return Obx(() {
              final isActive = currentSlideIndex.value == index;
              return Container(
                width: 8.w,
                height: 8.w,
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive ? Colors.white : Colors.white24,
                ),
              );
            });
          }),
        ),
      ],
    );
  }

  Widget _buildMockLeagueList() {
    return Container(
      width: double.infinity,
      height: 180.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.white12),
      ),
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          children: [
            _buildMockLeagueRow("🇹🇷", "Türkiye - 1. Lig", "1"),
            SizedBox(height: 6.h),
            _buildMockLeagueRow("🇹🇷", "Türkiye - Süper Lig", "1"),
            SizedBox(height: 6.h),
            _buildMockLeagueRow("🇩🇪", "Almanya - Oberliga - Baden-W.", "1"),
            SizedBox(height: 6.h),
            _buildMockLeagueRow("🇩🇪", "Almanya - Oberliga - Bremen", "8"),
          ],
        ),
      ),
    );
  }

  Widget _buildMockLeagueRow(String flag, String name, String count) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: const Color(0xFF121212),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Text(flag, style: TextStyle(fontSize: 14.sp)),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 11.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            count,
            style: TextStyle(color: Colors.white54, fontSize: 11.sp),
          ),
          SizedBox(width: 4.w),
          Icon(Icons.keyboard_arrow_down, color: Colors.white54, size: 14.sp),
        ],
      ),
    );
  }

  Widget _buildPlanCard(SubscriptionPlanModel plan, int index) {
    return Obx(() {
      final isSelected = controller.selectedPlanIndex.value == index;
      String priceStr = controller.getPlanPriceString(plan, index);
      String subtitle = "";
      if (index == 1) {
        subtitle = "\$2.77 / week";
      } else if (index == 2) {
        subtitle = "\$1.15 / week";
      }

      return GestureDetector(
        onTap: () => controller.selectPlan(index),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
          decoration: BoxDecoration(
            color: const Color(0xFF0F1419),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isSelected ? const Color(0xFF00CC99) : Colors.white12,
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
                color: isSelected ? const Color(0xFF00CC99) : Colors.white54,
                size: 24.sp,
              ),
              SizedBox(width: 16.w),

              // Plan Name & Price Subtext
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan.name ?? '',
                      style: TextStyle(
                        color: isSelected
                            ? const Color(0xFF00CC99)
                            : Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      priceStr,
                      style: TextStyle(color: Colors.white54, fontSize: 14.sp),
                    ),
                  ],
                ),
              ),

              // Right side weekly breakdown
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
        Center(
          child: Text(
            "Next Billing Date: Jun 29, 2026",
            style: TextStyle(color: Colors.white38, fontSize: 13.sp),
          ),
        ),
        SizedBox(height: 16.h),
        SizedBox(
          height: 56.h,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => controller.subscribe(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00CC99),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
              elevation: 8,
              shadowColor: const Color(0xFF00CC99).withOpacity(0.4),
            ),
            child: Text(
              'subscribe_now'.tr,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SizedBox(height: 12.h),
        Center(
          child: TextButton(
            onPressed: () => controller.restorePurchases(),
            child: Text(
              'restore_purchases'.tr,
              style: TextStyle(
                color: Colors.white30,
                fontSize: 12.sp,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
