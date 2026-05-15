import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:which_win/app/routes/app_pages.dart';
import '../controllers/race_bulletin_controller.dart';

class RaceBulletinView extends GetView<RaceBulletinController> {
  const RaceBulletinView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Race Bulletin',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '5 races · 2025-05-05',
              style: TextStyle(
                color: Colors.white38,
                fontSize: 12.sp,
              ),
            ),
          ],
        ),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: 5,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => Get.toNamed(AppRoutes.RACE_ANALYSIS),
            child: _buildRaceItem(index + 1),
          );
        },
      ),
    );
  }

  Widget _buildRaceItem(int raceNumber) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1419),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Race Number Circle
                Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: const Color(0xFF003D33),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$raceNumber',
                    style: TextStyle(
                      color: const Color(0xFF4DB6AC),
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                // Race Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Race $raceNumber',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            '13:45',
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: 14.sp,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          _buildTag('Handicap', const Color(0xFF1E293B)),
                          SizedBox(width: 4.w),
                          _buildTag('Turf', const Color(0xFF003D33),
                              textColor: const Color(0xFF4DB6AC)),
                          SizedBox(width: 8.w),
                          Text(
                            '1200m',
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Price and Horses
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₺850,000',
                      style: TextStyle(
                        color: const Color(0xFF4DB6AC),
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '8 horses',
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white12, height: 1),
          // Footer Text
          Padding(
            padding: EdgeInsets.all(12.w),
            child: RichText(
              text: TextSpan(
                style: TextStyle(color: Colors.white38, fontSize: 13.sp),
                children: [
                  const TextSpan(text: 'Who beat whom: '),
                  TextSpan(
                    text: 'AKSI SEDA 3-2 VENOMAKSI SEDA 3-1 ',
                    style: TextStyle(color: Colors.orange.withOpacity(0.8)),
                  ),
                  const TextSpan(
                    text: 'GOLDEN ARROW',
                    style: TextStyle(color: Colors.orange),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color bgColor, {Color textColor = Colors.white70}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 10.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
