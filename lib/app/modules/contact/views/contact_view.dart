import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/contact_controller.dart';

class ContactView extends GetView<ContactController> {
  const ContactView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Row(
            children: [
              Icon(Icons.arrow_back_ios, color: Colors.white, size: 16.sp),
              Text(
                'back'.tr,
                style: TextStyle(color: Colors.white, fontSize: 14.sp),
              ),
            ],
          ),
          onPressed: () => Get.back(),
        ),
        leadingWidth: 80.w,
        title: Text(
          'contact'.tr,
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
      body: SafeArea(
        top: false,
        bottom: true,
        child: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          children: [
            SizedBox(height: 20.h),
            // Phone Icon Placeholder (Since I can't generate images for inside code yet, I'll use a large icon with styling)
            Icon(Icons.phone_in_talk, size: 80.sp, color: Colors.white38),
            SizedBox(height: 24.h),
            Text(
              'get_in_touch'.tr,
              style: TextStyle(
                color: Colors.white,
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'we_are_here_help'.tr,
              style: TextStyle(color: Colors.white38, fontSize: 16.sp),
            ),
            SizedBox(height: 40.h),

            _buildContactCard(
              'email'.tr,
              'support@whichwin.com',
              Icons.email_outlined,
            ),
            SizedBox(height: 16.h),
            _buildContactCard(
              'telegram'.tr,
              '@whichwin_support',
              Icons.send_rounded,
            ),
            SizedBox(height: 16.h),
            _buildContactCard('website'.tr, 'www.whichwin.com', Icons.language),
            SizedBox(height: 40.h),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'send_us_message'.tr,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 16.h),
            _buildTextField(
              controller: controller.nameController,
              hintText: 'your_name'.tr,
              icon: Icons.person_outline,
            ),
            SizedBox(height: 16.h),
            _buildTextField(
              controller: controller.emailController,
              hintText: 'your_email'.tr,
              icon: Icons.mail_outline,
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16.h),
            _buildTextField(
              controller: controller.subjectController,
              hintText: 'subject'.tr,
              icon: Icons.subject_rounded,
            ),
            SizedBox(height: 16.h),
            _buildTextField(
              controller: controller.messageController,
              hintText: 'type_message_here'.tr,
              icon: Icons.chat_bubble_outline_rounded,
              maxLines: 5,
            ),
            SizedBox(height: 32.h),
            Obx(
              () => SizedBox(
                width: double.infinity,
                height: 54.h,
                child: ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : () => controller.sendContact(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4DB6AC),
                    disabledBackgroundColor: const Color(
                      0xFF4DB6AC,
                    ).withValues(alpha: 0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    elevation: 0,
                  ),
                  child: controller.isLoading.value
                      ? SizedBox(
                          height: 24.h,
                          width: 24.h,
                          child: const CircularProgressIndicator(
                            color: Colors.black,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(
                          'submit_inquiry'.tr,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F1419),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.white12),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: TextStyle(color: Colors.white, fontSize: 15.sp),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.white38, fontSize: 15.sp),
          prefixIcon: Icon(icon, color: Colors.white38, size: 20.sp),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: maxLines > 1 ? 16.h : 12.h,
          ),
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
              color: Colors.white.withValues(alpha: 0.05),
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
                style: TextStyle(color: Colors.white38, fontSize: 14.sp),
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
