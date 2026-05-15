import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controllers/privacy_policy_controller.dart';

class PrivacyPolicyView extends GetView<PrivacyPolicyController> {
  const PrivacyPolicyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
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
        title: Text(
          'Privacy Policy',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.h),
          child: Container(color: Colors.white12, height: 1.h),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              'Information We Collect',
              'We collect information you provide directly to us, including name, email address, and usage data.',
            ),
            SizedBox(height: 32.h),
            _buildSection(
              'How We Use Your Information',
              'We use the information to provide, maintain, and improve our services, and to communicate with you.',
            ),
            SizedBox(height: 32.h),
            _buildSection(
              'Data Security',
              'We take reasonable measures to help protect your personal information from loss, theft, misuse and unauthorized access.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16.h),
        Text(
          content,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 15.sp,
            height: 1.6,
          ),
        ),
      ],
    );
  }
}
