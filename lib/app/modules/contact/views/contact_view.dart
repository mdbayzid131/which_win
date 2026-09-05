import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:which_win/core/utils/custom_snackbar.dart';
import '../controllers/contact_controller.dart';

class ContactView extends GetView<ContactController> {
  const ContactView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Stack(
        children: [
          // Background Image with dark gradient overlay
          Positioned.fill(
            child: Image.asset(
              'assets/images/horse_racing_bg.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF121212).withValues(alpha: 0.3),
                    const Color(0xFF121212).withValues(alpha: 0.8),
                    const Color(0xFF121212),
                  ],
                ),
              ),
            ),
          ),

          // Scrollable Content
          SafeArea(
            child: CustomScrollView(
              slivers: [
                // Top Custom Header
                SliverToBoxAdapter(
                  child: Padding(
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
                              'contact'.tr,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 80.w), // Balance the back button
                      ],
                    ),
                  ),
                ),

                // Vertical spacing
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.1,
                  ),
                ),

                // Bottom card form (align to bottom)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: _buildBottomContactCard(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return GestureDetector(
      onTap: () => Get.back(),
      child: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white24, width: 1.2),
          shape: BoxShape.circle,
          color: Colors.black.withValues(alpha: 0.2),
        ),
        child: Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18.sp),
      ),
    );
  }

  Widget _buildBottomContactCard(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32.r),
          topRight: Radius.circular(32.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 15,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(24.w, 32.h, 24.w, 36.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Title "Contact"
          Text(
            'contact'.tr,
            style: TextStyle(
              color: Colors.white,
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 24.h),

          // Name Surname field
          _buildFormTextField(
            controller: controller.nameController,
            labelText: 'your_name'.tr,
            hintText: 'your_name'.tr,
            icon: Icons.person_rounded,
          ),
          SizedBox(height: 18.h),

          // E-Mail field
          _buildFormTextField(
            controller: controller.emailController,
            labelText: 'your_email'.tr,
            hintText: 'your_email'.tr,
            icon: Icons.email_rounded,
            keyboardType: TextInputType.emailAddress,
          ),
          SizedBox(height: 18.h),

          // Message field
          _buildFormTextField(
            controller: controller.messageController,
            labelText: 'type_message_here'.tr,
            hintText: 'type_message_here'.tr,
            icon: Icons.chat_bubble_rounded,
            maxLines: 4,
          ),
          SizedBox(height: 24.h),

          // Send Button
          _buildSendButton(),
          SizedBox(height: 24.h),

          // OR Divider
          _buildOrDivider(),
          SizedBox(height: 24.h),

          // Social Media Icons
          _buildSocialRow(),
        ],
      ),
    );
  }

  Widget _buildFormTextField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: Colors.white54),
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.white30),
        prefixIcon: Icon(icon, color: Colors.white70, size: 22.sp),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: const BorderSide(color: Color(0xFF4DB6AC)),
        ),
        filled: true,
        fillColor: Colors.black,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 20.w,
          vertical: maxLines > 1 ? 16.h : 14.h,
        ),
      ),
    );
  }

  Widget _buildSendButton() {
    return Obx(() {
      final isLoading = controller.isLoading.value;
      return SizedBox(
        width: double.infinity,
        height: 56.h,
        child: ElevatedButton(
          onPressed: isLoading
              ? null
              : () {
                  if (controller.subjectController.text.isEmpty) {
                    controller.subjectController.text = "App Support Message";
                  }
                  controller.sendContact();
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00CC99),
            disabledBackgroundColor: const Color(0xFF00CC99).withValues(alpha: 0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            elevation: 8,
            shadowColor: const Color(0xFF00CC99).withValues(alpha: 0.4),
          ),
          child: isLoading
              ? SizedBox(
                  width: 24.w,
                  height: 24.w,
                  child: const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Text(
                  'Send',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      );
    });
  }

  Widget _buildOrDivider() {
    return Row(
      children: [
        const Expanded(child: Divider(color: Colors.white24)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Text(
            'OR',
            style: TextStyle(
              color: Colors.white38,
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ),
        const Expanded(child: Divider(color: Colors.white24)),
      ],
    );
  }

  Widget _buildSocialRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Facebook
        GestureDetector(
          onTap: () => _openSocialLink('Facebook'),
          child: SizedBox(
            width: 52.w,
            height: 52.w,
            child: Image.asset(
              'assets/icons/facebook.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
        SizedBox(width: 20.w),
        // Instagram
        GestureDetector(
          onTap: () => _openSocialLink('Instagram'),
          child: SizedBox(
            width: 52.w,
            height: 52.w,
            child: Image.asset(
              'assets/icons/instagram.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
        SizedBox(width: 20.w),
        // YouTube
        GestureDetector(
          onTap: () => _openSocialLink('YouTube'),
          child: SizedBox(
            width: 52.w,
            height: 52.w,
            child: Image.asset('assets/icons/youtube.png', fit: BoxFit.contain),
          ),
        ),
      ],
    );
  }

  Future<void> _openSocialLink(String platform) async {
    if (platform == 'Instagram') {
      const url = 'https://www.instagram.com/whichwin.horcerace/';
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        CustomSnackBar.error('Could not launch $url');
      }
    } else {
      CustomSnackBar.success('Opening $platform support...');
    }
  }
}
