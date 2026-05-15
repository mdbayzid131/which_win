import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/contact_controller.dart';

class ContactView extends GetView<ContactController> {
  const ContactView({super.key});

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
          'Contact',
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
          children: [
            SizedBox(height: 20.h),
            // Phone Icon Placeholder (Since I can't generate images for inside code yet, I'll use a large icon with styling)
            Icon(
              Icons.phone_in_talk,
              size: 80.sp,
              color: Colors.white38,
            ),
            SizedBox(height: 24.h),
            Text(
              'Get in Touch',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              "We're here to help you",
              style: TextStyle(
                color: Colors.white38,
                fontSize: 16.sp,
              ),
            ),
            SizedBox(height: 40.h),
            
            _buildContactCard(
              'Email',
              'support@whichwin.com',
              Icons.email_outlined,
            ),
            SizedBox(height: 16.h),
            _buildContactCard(
              'Telegram',
              '@whichwin_support',
              Icons.send_rounded,
            ),
            SizedBox(height: 16.h),
            _buildContactCard(
              'Website',
              'www.whichwin.com',
              Icons.language,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard(String title, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1419),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, color: Colors.white70, size: 24.sp),
          ),
          SizedBox(width: 16.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 14.sp,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                value,
                style: TextStyle(
                  color: const Color(0xFF4DB6AC),
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
