import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
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
        return controller.isActive.value
            ? _buildActiveStatus() // This can be a "Manage Subscription" view if needed
            : _buildSubscriptionWorkflow();
      }),
    );
  }

  Widget _buildSubscriptionWorkflow() {
    final showPlans = false.obs;
    return Obx(
      () => showPlans.value
          ? _buildPlanSelection()
          : _buildNoPlanFound(() => showPlans.value = true),
    );
  }

  Widget _buildNoPlanFound(VoidCallback onSubscribe) {
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
          _buildPrimaryButton('Subscribe Now', onSubscribe),
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
                  _buildPlanCard('1 Week', 'BDT 349.00', '', true),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Expanded(
                        child: _buildPlanCard(
                          '1 Month',
                          'BDT 1,199.00',
                          'BDT 275.95 / w',
                          false,
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: _buildPlanCard(
                          '1 Year',
                          'BDT 7,999.00',
                          'BDT 153.83 / w',
                          false,
                        ),
                      ),
                    ],
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

  Widget _buildPlanCard(
    String title,
    String price,
    String subtext,
    bool isBest,
  ) {
    return Obx(() {
      final isSelected = controller.selectedPlan.value == title;
      return GestureDetector(
        onTap: () => controller.selectPlan(title),
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
                    title,
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
                price,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w900,
                ),
              ),
              if (subtext.isNotEmpty) ...[
                SizedBox(height: 6.h),
                Text(
                  subtext,
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              SizedBox(height: 20.h),
              Align(
                alignment: Alignment.centerRight,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 28.w,
                  height: 28.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Colors.transparent : Colors.white24,
                    ),
                    gradient: isSelected
                        ? const LinearGradient(
                            colors: [Color(0xFF4DB6AC), Color(0xFF00695C)],
                          )
                        : null,
                  ),
                  child: isSelected
                      ? Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 18.sp,
                        )
                      : null,
                ),
              ),
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
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'WHICH ',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 24.sp,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          Text(
            'WIN',
            style: TextStyle(
              color: const Color(0xFF4DB6AC),
              fontSize: 24.sp,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          SizedBox(width: 8.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: const Color(0xFFFBC02D),
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Text(
              'PRO',
              style: TextStyle(
                color: Colors.black,
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturePreview() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          _buildPreviewRow('AI Prediction Confidence', '90%', true),
          SizedBox(height: 12.h),
          _buildPreviewRow('Which Win Guess', 'Man City or Draw', false),
        ],
      ),
    );
  }

  Widget _buildPreviewRow(String label, String value, bool isProgress) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.white38, fontSize: 13.sp),
        ),
        if (isProgress)
          Row(
            children: [
              Container(
                width: 80.w,
                height: 6.h,
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(3.r),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: 0.9,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4DB6AC), Color(0xFF004D40)],
                      ),
                      borderRadius: BorderRadius.circular(3.r),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                value,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          )
        else
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 13.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
      ],
    );
  }

  Widget _buildBenefitList() {
    return Column(
      children: [
        _buildBenefitItem('90% Prediction Accuracy with AI'),
        _buildBenefitItem('Early Access to Upcoming Matches'),
        _buildBenefitItem('No Advertisements & Faster Updates'),
        _buildBenefitItem('Exclusive High-Confidence Tips'),
      ],
    );
  }

  Widget _buildBenefitItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: const Color(0xFF4DB6AC).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_rounded,
              color: const Color(0xFF4DB6AC),
              size: 14.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Text(
            text,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14.sp,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 58.h,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          gradient: const LinearGradient(
            colors: [Color(0xFF00695C), Color(0xFF004D40)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF004D40).withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
          ),
          child: Text(
            text.toUpperCase(),
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 56.h,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildActiveStatus() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: const Color(0xFF4DB6AC).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_rounded,
                color: const Color(0xFF4DB6AC),
                size: 80.sp,
              ),
            ),
            SizedBox(height: 32.h),
            Text(
              'Active Subscription',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'You are currently on the ${controller.selectedPlan.value} plan.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 16.sp),
            ),
            SizedBox(height: 48.h),
            _buildSecondaryButton('Manage Subscription', () {
              // Future logic for managing subscription
            }),
            SizedBox(height: 16.h),
            TextButton(
              onPressed: () => controller.isActive.value = false,
              child: Text(
                'Cancel Subscription (Debug)',
                style: TextStyle(color: Colors.red.shade400, fontSize: 14.sp),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
