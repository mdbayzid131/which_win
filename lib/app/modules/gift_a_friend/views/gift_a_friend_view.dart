import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/gift_a_friend_controller.dart';

class GiftAFriendView extends GetView<GiftAFriendController> {
  const GiftAFriendView({super.key});

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
                    const Color(0xFF121212).withValues(alpha: 0.4),
                    const Color(0xFF121212).withValues(alpha: 0.85),
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
                // Top header bar with Close button
                SliverToBoxAdapter(
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: EdgeInsets.only(right: 16.w, top: 8.h),
                      child: IconButton(
                        icon: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 28.sp,
                        ),
                        onPressed: () => Get.back(),
                      ),
                    ),
                  ),
                ),
                // Title Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Column(
                      children: [
                        SizedBox(height: 10.h),
                        Text(
                          'gift_win_win'.tr,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26.sp,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),
                        SizedBox(height: 30.h),
                        // Golden Gift box illustration
                        _buildGiftBoxIllustration(),
                        SizedBox(height: 24.h),
                        // Remaining Invites Credit
                        _buildRemainingInvites(),
                        SizedBox(height: 20.h),
                        // Description text
                        Text(
                          'gift_desc'.tr,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13.sp,
                            height: 1.4,
                          ),
                        ),
                        SizedBox(height: 24.h),
                        // Referral Code display container
                        _buildReferralCodeCard(),
                        SizedBox(height: 30.h),
                      ],
                    ),
                  ),
                ),
                // Bottom input form (Add Reference)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: _buildBottomReferenceForm(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGiftBoxIllustration() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Glow effect behind
        Container(
          width: 140.w,
          height: 140.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.amber.withValues(alpha: 0.18),
                blurRadius: 40,
                spreadRadius: 10,
              ),
            ],
          ),
        ),
        // Central Gift Icon
        Container(
          width: 110.w,
          height: 110.w,
          decoration: BoxDecoration(
            color: Colors.amber.withValues(alpha: 0.12),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.amber.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Icon(
            Icons.card_giftcard,
            size: 56.sp,
            color: Colors.amber[400],
          ),
        ),
        // Small decorative stars around
        Positioned(
          left: 10.w,
          bottom: 10.h,
          child: Icon(Icons.star, color: Colors.amber[200], size: 14.sp),
        ),
        Positioned(
          right: 8.w,
          top: 20.h,
          child: Icon(Icons.star, color: Colors.amber[200], size: 18.sp),
        ),
        Positioned(
          left: 24.w,
          top: 10.h,
          child: Icon(Icons.star_border, color: Colors.amber[300], size: 12.sp),
        ),
      ],
    );
  }

  Widget _buildRemainingInvites() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_play_rounded,
              color: Colors.amber[400],
              size: 20.sp,
            ),
            SizedBox(width: 8.w),
            Obx(
              () => Text(
                '${controller.remainingInvites.value}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        Text(
          'remaining_invites'.tr,
          style: TextStyle(
            color: Colors.white38,
            fontSize: 13.sp,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildReferralCodeCard() {
    return SizedBox(
      width: double.infinity,
      height: 60.h,
      child: CustomPaint(
        painter: DashedBorderPainter(
          color: Colors.white24,
          borderRadius: 12.r,
          dashLength: 5,
          gap: 5,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12.r),
          onTap: () => controller.copyCode(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              children: [
                Expanded(
                  child: Obx(
                    () => Text(
                      controller.referralCode.value,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
                Container(width: 1.w, height: 24.h, color: Colors.white12),
                SizedBox(width: 16.w),
                IconButton(
                  icon: Icon(
                    Icons.ios_share_rounded,
                    color: Colors.white,
                    size: 22.sp,
                  ),
                  onPressed: () => controller.shareCode(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomReferenceForm() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
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
          Text(
            'add_reference'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 24.h),
          _buildTextField(),
          SizedBox(height: 24.h),
          _buildApproveButton(),
        ],
      ),
    );
  }

  Widget _buildTextField() {
    return TextFormField(
      controller: controller.referenceController,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: 'reference_code'.tr,
        labelStyle: const TextStyle(color: Colors.white54),
        hintText: 'reference_code'.tr,
        hintStyle: const TextStyle(color: Colors.white30),
        prefixIcon: Icon(
          Icons.redeem_rounded,
          color: Colors.white70,
          size: 22.sp,
        ),
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
        contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      ),
    );
  }

  Widget _buildApproveButton() {
    return Obx(() {
      final isLoading = controller.isLoading.value;
      return SizedBox(
        width: double.infinity,
        height: 56.h,
        child: ElevatedButton(
          onPressed: isLoading ? null : () => controller.approveCode(),
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
                  'approve'.tr,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      );
    });
  }
}

class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;
  final double dashLength;
  final double borderRadius;

  DashedBorderPainter({
    required this.color,
    this.strokeWidth = 1.0,
    this.gap = 4.0,
    this.dashLength = 6.0,
    this.borderRadius = 12.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(borderRadius),
    );

    final Path path = Path()..addRRect(rrect);
    final Path dashPath = Path();

    double distance = 0.0;
    for (final PathMetric measurePath in path.computeMetrics()) {
      while (distance < measurePath.length) {
        dashPath.addPath(
          measurePath.extractPath(distance, distance + dashLength),
          Offset.zero,
        );
        distance += dashLength + gap;
      }
    }
    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
