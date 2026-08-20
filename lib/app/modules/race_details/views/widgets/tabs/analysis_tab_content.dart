import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:which_win/app/modules/race_details/controllers/race_details_controller.dart';

class AnalysisTabContent extends GetView<RaceDetailsController> {
  const AnalysisTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    final details = controller.raceDetails.value;
    final entries = details?.entries ?? [];
    final trackType = details?.trackType ?? 'Turf';
    final distance = details?.distance ?? '';
    final runnersCount = entries.length;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: const Color(0xFF1E222B),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.white24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.insights,
                      color: const Color(0xFF10B981),
                      size: 18.sp,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'ai_win_probabilities'.tr,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: [
                    buildAnalysisTag(
                      '${'track_bias'.tr}: $trackType',
                      const Color(0xFF1A4D40),
                      const Color(0xFF5FBFAA),
                    ),
                    buildAnalysisTag(
                      '${'dist'.tr}: $distance',
                      const Color(0xFF1A5276),
                      const Color(0xFF7FBFCF),
                    ),
                    buildAnalysisTag(
                      '${'field'.tr}: $runnersCount',
                      const Color(0xFF3D2066),
                      const Color(0xFFA070B0),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),
          ...List.generate(entries.length, (index) {
            final entry = entries[index];
            final rank = entry.rank ?? (index + 1);
            final name = entry.horse?.name ?? 'unknown_horse'.tr;
            final score = entry.normalizedScore?.toInt() ??
                (entry.winProb != null
                    ? (entry.winProb! * 100).toInt()
                    : (entry.horsePower?.toInt() ?? 0));

            Color rankBgColor;
            Color rankTextColor = Colors.white;
            bool isCustomBadge = true;

            if (rank == 1) {
              rankBgColor = const Color(0xFFE6A817);
              rankTextColor = const Color(0xFF121418);
            } else if (rank == 2) {
              rankBgColor = const Color(0xFF94A3B8);
              rankTextColor = const Color(0xFF121418);
            } else if (rank == 3) {
              rankBgColor = const Color(0xFFCD7F32);
            } else {
              rankBgColor = Colors.transparent;
              isCustomBadge = false;
            }

            List<Color> barColors;
            if (score >= 70) {
              barColors = [
                const Color(0xFF2D9B83),
                const Color(0xFF20C997),
              ];
            } else if (score >= 50) {
              barColors = [
                const Color(0xFFE6A817),
                const Color(0xFFFFC107),
              ];
            } else {
              barColors = [
                const Color(0xFFD94E4E),
                const Color(0xFFFF6B6B),
              ];
            }

            return buildAnalysisItem(
              '$rank',
              name,
              score / 100.0,
              rankBgColor,
              rankTextColor,
              isCustomBadge,
              barColors,
            );
          }),
          SizedBox(height: 16.h),
          Text(
            'prob_computed_disclaimer'.tr,
            style: TextStyle(
              color: Colors.white38,
              fontSize: 11.sp,
              fontStyle: FontStyle.italic,
            ),
          ),
          SizedBox(height: 40.h),
        ],
      ),
    );
  }
}

Widget buildAnalysisTag(String text, Color bgColor, Color textColor) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
    decoration: BoxDecoration(
      color: bgColor.withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(4.r),
      border: Border.all(color: bgColor.withValues(alpha: 0.4)),
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

Widget buildAnalysisItem(
  String rank,
  String name,
  double probability,
  Color rankBgColor,
  Color rankTextColor,
  bool isCustomBadge,
  List<Color> barColors,
) {
  return Container(
    margin: EdgeInsets.only(bottom: 12.h),
    padding: EdgeInsets.all(16.w),
    decoration: BoxDecoration(
      color: const Color(0xFF1E222B),
      borderRadius: BorderRadius.circular(12.r),
      border: Border.all(color: Colors.white24),
    ),
    child: Column(
      children: [
        Row(
          children: [
            Container(
              width: 26.w,
              height: 26.w,
              decoration: BoxDecoration(
                color: rankBgColor,
                shape: BoxShape.circle,
                border: isCustomBadge
                    ? null
                    : Border.all(color: Colors.white30),
              ),
              alignment: Alignment.center,
              child: Text(
                rank,
                style: TextStyle(
                  color: rankTextColor,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                name.toUpperCase(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              '${(probability * 100).toInt()}%',
              style: TextStyle(
                color: barColors.last,
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Stack(
          children: [
            Container(
              height: 6.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(3.r),
              ),
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                return Container(
                  height: 6.h,
                  width: constraints.maxWidth * probability,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: barColors),
                    borderRadius: BorderRadius.circular(3.r),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    ),
  );
}
