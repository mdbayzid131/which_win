import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class RaceDetailsAppBar extends StatelessWidget {
  final String locationName;
  final String dayStr;

  const RaceDetailsAppBar({
    super.key,
    required this.locationName,
    required this.dayStr,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF121418),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Back arrow
          GestureDetector(
            onTap: () => Get.back(),
            child: Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 16.w),

          // Location name
          Expanded(
            child: Text(
              locationName,
              style: TextStyle(
                color: Colors.white,
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Calendar Date badge (right side)
          if (dayStr.isNotEmpty) buildAppBarBadge(dayStr),
        ],
      ),
    );
  }
}

Widget buildAppBarBadge(String label, {bool isLive = false}) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
    decoration: BoxDecoration(
      color: isLive
          ? Colors.red.withValues(alpha: 0.15)
          : const Color(0xFF1E222B),
      borderRadius: BorderRadius.circular(8.r),
      border: Border.all(
        color: isLive
            ? Colors.red.withValues(alpha: 0.7)
            : const Color(0xFF10B981).withValues(alpha: 0.5),
        width: 1.2,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.25),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isLive) ...[
          Container(
            width: 6.w,
            height: 6.w,
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 5.w),
        ] else ...[
          Icon(
            Icons.calendar_month_rounded,
            color: const Color(0xFF10B981),
            size: 15.sp,
          ),
          SizedBox(width: 5.w),
        ],
        Text(
          label,
          style: TextStyle(
            color: isLive ? Colors.red : Colors.white,
            fontSize: 13.sp,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.3,
          ),
        ),
      ],
    ),
  );
}
