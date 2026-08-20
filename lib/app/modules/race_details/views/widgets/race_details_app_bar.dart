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

          // Day number badge (right side)
          if (dayStr.isNotEmpty) buildAppBarBadge(dayStr),
        ],
      ),
    );
  }
}

Widget buildAppBarBadge(String label, {bool isLive = false}) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
    decoration: BoxDecoration(
      color: isLive
          ? Colors.red.withValues(alpha: 0.15)
          : const Color(0xFF121418),
      borderRadius: BorderRadius.circular(4.r),
      border: Border.all(
        color: isLive ? Colors.red.withValues(alpha: 0.7) : Colors.white38,
        width: 1.5,
      ),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isLive) ...[
          Container(
            width: 5.w,
            height: 5.w,
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 4.w),
        ],
        Text(
          label,
          style: TextStyle(
            color: isLive ? Colors.red : Colors.white,
            fontSize: 13.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}
