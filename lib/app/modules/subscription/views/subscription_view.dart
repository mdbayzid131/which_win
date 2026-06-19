import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:which_win/data/models/subscription_model.dart';
import '../controllers/subscription_controller.dart';

class SubscriptionView extends GetView<SubscriptionController> {
  const SubscriptionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Row(
            children: [
              Icon(Icons.arrow_back_ios, color: Colors.white, size: 16.sp),
              Text(
                'Back',
                style: TextStyle(color: Colors.white, fontSize: 14.sp),
              ),
            ],
          ),
          onPressed: () => Get.back(),
        ),
        leadingWidth: 80.w,
      ),
      body: Obx(() {
        if (controller.plans.isEmpty) {
          return _buildNoPlanFound();
        }
        return Stack(
          children: [
            _buildSubscriptionWorkflow(),
            if (controller.isLoading.value)
              Container(
                color: Colors.black54,
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4DB6AC)),
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }

  Widget _buildSubscriptionWorkflow() {
    final showPlans = false.obs;
    return Obx(
      () => showPlans.value
          ? _buildPlanSelection()
          : _buildNoPlanFound(onSubscribe: () => showPlans.value = true),
    );
  }

  Widget _buildNoPlanFound({VoidCallback? onSubscribe}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF0F1419),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
      ),
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      child: Column(
        children: [
          _buildHandle(),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(vertical: 24.h),
              child: Column(
                children: [
                  _buildProLogo(),
                  SizedBox(height: 24.h),
                  _buildFeaturePreview(),
                  SizedBox(height: 32.h),
                  _buildBenefitList(),
                ],
              ),
            ),
          ),
          SizedBox(height: 16.h),
          if (onSubscribe != null) _buildPrimaryButton('Subscribe Now', onSubscribe),
          SizedBox(height: 12.h),
          _buildSecondaryButton(
            'Restore Purchases',
            () => controller.restorePurchases(),
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  Widget _buildPlanSelection() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF0F1419),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
      ),
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHandle(),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(vertical: 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProLogo(),
                  SizedBox(height: 24.h),
                  _buildFeaturePreview(),
                  SizedBox(height: 32.h),
                  _buildBenefitList(),
                  SizedBox(height: 32.h),
                  Text(
                    'Choose Your Plan',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.plans.length,
                    separatorBuilder: (context, index) => SizedBox(height: 16.h),
                    itemBuilder: (context, index) {
                      final plan = controller.plans[index];
                      return _buildPlanCard(plan, index);
                    },
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16.h),
          _buildPrimaryButton('Subscribe Now', () => controller.subscribe()),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  Widget _buildPlanCard(SubscriptionPlanModel plan, int index) {
    return Obx(() {
      final isSelected = controller.selectedPlanIndex.value == index;
      final bool isBest = index == 0; // Simple logic to match original UI's "Best Value"
      return GestureDetector(
        onTap: () => controller.selectPlan(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF1E293B)
                : const Color(0xFF0F1419),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: isSelected ? const Color(0xFF4DB6AC) : Colors.white12,
              width: 1.5,
            ),
            boxShadow: [
              if (isSelected)
                BoxShadow(
                  color: const Color(0xFF4DB6AC).withOpacity(0.15),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    plan.name ?? '',
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (isBest)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 5.h,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFBC02D), Color(0xFFF9A825)],
                        ),
                        borderRadius: BorderRadius.circular(10.r),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFBC02D).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        'BEST VALUE',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 20.h),
              Text(
                controller.getPlanPriceString(plan, index),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w900,
                ),
              ),
              if (plan.description != null && plan.description!.isNotEmpty) ...[
                SizedBox(height: 6.h),
                Text(
                  plan.description!,
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              SizedBox(height: 20.h),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildHandle() {
    return Center(
      child: Container(
        width: 40.w,
        height: 4.h,
        decoration: BoxDecoration(
          color: Colors.white12,
          borderRadius: BorderRadius.circular(2.r),
        ),
      ),
    );
  }

  Widget _buildProLogo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF4DB6AC), Color(0xFF00796B)],
            ),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            children: [
              Icon(Icons.star, color: Colors.white, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                'PRO',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturePreview() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withOpacity(0.5),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildFeatureIcon(Icons.psychology, 'AI Tips'),
          _buildFeatureIcon(Icons.analytics, 'Analysis'),
          _buildFeatureIcon(Icons.notifications_active, 'Alerts'),
        ],
      ),
    );
  }

  Widget _buildFeatureIcon(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF4DB6AC), size: 28.sp),
        SizedBox(height: 8.h),
        Text(
          label,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildBenefitList() {
    return Column(
      children: [
        _buildBenefitItem('Unlimited AI predictions for all races'),
        _buildBenefitItem('Detailed performance analytics & statistics'),
        _buildBenefitItem('Instant push notifications for live results'),
        _buildBenefitItem('Ad-free experience across the app'),
      ],
    );
  }

  Widget _buildBenefitItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: const Color(0xFF4DB6AC), size: 18.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 56.h,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4DB6AC), Color(0xFF00796B)],
          ),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4DB6AC).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 56.h,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.white10),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
