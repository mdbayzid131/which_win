import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controllers/terms_conditions_controller.dart';

class TermsConditionsView extends GetView<TermsConditionsController> {
  const TermsConditionsView({super.key});

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
          'Terms and Conditions',
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
              '1. Acceptance of Terms',
              'By accessing and using Which Win, you accept and agree to be bound by the terms and provision of this agreement.',
            ),
            SizedBox(height: 32.h),
            _buildSection(
              '2. Use License',
              'Permission is granted to temporarily download one copy of the materials for personal, non-commercial transitory viewing only.',
            ),
            SizedBox(height: 32.h),
            _buildSection(
              '3. Disclaimer',
              'The materials on Which Win are provided on an \'as is\' basis. We make no warranties, expressed or implied.',
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
