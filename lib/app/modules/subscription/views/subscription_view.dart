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
              Text('Back', style: TextStyle(color: Colors.white, fontSize: 14.sp)),
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
    return Obx(() => showPlans.value ? _buildPlanSelection() : _buildNoPlanFound(() => showPlans.value = true));
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
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 60.h),
          Text(
            'Active Plan Not Found',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            'You do no have an active subscription. If you think there is an error, you can renew you subscription by pressing the \'Restore Purchases\' button. You can also subscribe with the \'Subscribe Now\' button.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16.sp,
              height: 1.5,
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 56.h,
            child: ElevatedButton(
              onPressed: onSubscribe,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF004D40),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              ),
              child: Text(
                'Subscribe Now',
                style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          SizedBox(
            width: double.infinity,
            height: 56.h,
            child: ElevatedButton(
              onPressed: () => controller.restorePurchases(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E293B),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              ),
              child: Text(
                'Restore Purchases',
                style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SizedBox(height: 40.h),
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
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          SizedBox(height: 32.h),
          Text(
            'Subscribe Now',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 32.h),
          _buildPlanCard('1 Week', 'BDT 349.00', '', true),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(child: _buildPlanCard('1 Month', 'BDT 1,199.00', 'BDT 275.95 / w', false)),
              SizedBox(width: 16.w),
              Expanded(child: _buildPlanCard('1 Year', 'BDT 7,999.00', 'BDT 153.83 / w', false)),
            ],
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 56.h,
            child: ElevatedButton(
              onPressed: () => controller.subscribe(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF004D40),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              ),
              child: Text(
                'Subscribe Now',
                style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SizedBox(height: 40.h),
        ],
      ),
    );
  }

  Widget _buildPlanCard(String title, String price, String subtext, bool isBest) {
    return Obx(() {
      final isSelected = controller.selectedPlan.value == title;
      return GestureDetector(
        onTap: () => controller.selectPlan(title),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B).withOpacity(0.5),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isSelected ? const Color(0xFF4DB6AC) : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold),
                  ),
                  if (isBest)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFBC02D),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        'Most preferred',
                        style: TextStyle(color: Colors.black, fontSize: 10.sp, fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 16.h),
              Text(
                price,
                style: TextStyle(color: Colors.white, fontSize: 22.sp, fontWeight: FontWeight.bold),
              ),
              if (subtext.isNotEmpty) ...[
                SizedBox(height: 4.h),
                Text(
                  subtext,
                  style: TextStyle(color: Colors.white38, fontSize: 12.sp),
                ),
              ],
              SizedBox(height: 16.h),
              Container(
                width: 24.w,
                height: 24.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white24),
                  color: isSelected ? const Color(0xFF4DB6AC) : Colors.transparent,
                ),
                child: isSelected ? Icon(Icons.check, color: Colors.black, size: 16.sp) : null,
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildActiveStatus() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, color: const Color(0xFF4DB6AC), size: 80.sp),
          SizedBox(height: 24.h),
          Text(
            'Active Subscription',
            style: TextStyle(color: Colors.white, fontSize: 24.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.h),
          Text(
            'You are currently on the ${controller.selectedPlan.value} plan.',
            style: TextStyle(color: Colors.white70, fontSize: 16.sp),
          ),
          SizedBox(height: 40.h),
          TextButton(
            onPressed: () => controller.isActive.value = false,
            child: const Text('Cancel Subscription (Debug)', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
