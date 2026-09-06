import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:which_win/app/modules/race_details/controllers/race_details_controller.dart';
import 'package:which_win/data/models/race_details_model.dart';

class AnalysisTabContent extends GetView<RaceDetailsController> {
  const AnalysisTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    final details = controller.raceDetails.value;
    final rawEntries = details?.entries ?? [];
    final trackType = details?.trackType ?? 'Turf';
    final distance = details?.distance ?? '';
    final runnersCount = rawEntries.length;

    // Dynamic sorting strictly by highest score / rank descending
    final entries = List<RaceEntry>.from(rawEntries);
    entries.sort((a, b) {
      final rankA = a.rank ?? 999;
      final rankB = b.rank ?? 999;
      if (rankA != rankB) return rankA.compareTo(rankB);
      final scoreA = a.normalizedScore ?? a.rawScore ?? 0.0;
      final scoreB = b.normalizedScore ?? b.rawScore ?? 0.0;
      return scoreB.compareTo(scoreA);
    });

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
          SizedBox(height: 16.h),
          ...List.generate(entries.length, (index) {
            final entry = entries[index];
            final rank = entry.rank ?? (index + 1);
            final clothNo = entry.number ?? entry.draw ?? rank;
            final name = entry.horse?.name ?? 'unknown_horse'.tr;
            final rawScore = entry.rawScore ?? entry.horsePower ?? 0.0;

            // Single 100% benchmark: Rank 1 is guaranteed 100%, others proportional
            final double percentValue = (rank == 1)
                ? 100.0
                : (entry.normalizedScore != null
                    ? entry.normalizedScore!.clamp(0.0, 99.0)
                    : ((entry.winProb ?? 0.0) * 100).clamp(0.0, 99.0));

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
              rankBgColor = const Color(0xFF282E3A);
              isCustomBadge = false;
            }

            List<Color> barColors;
            if (percentValue >= 80) {
              barColors = [
                const Color(0xFF2D9B83),
                const Color(0xFF20C997),
              ];
            } else if (percentValue >= 50) {
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
              rank: '$rank',
              clothNumber: '$clothNo',
              name: name,
              rawScore: rawScore > 0 ? rawScore.toStringAsFixed(1) : null,
              category: entry.category,
              probability: (percentValue / 100.0).clamp(0.0, 1.0),
              percentText: '${percentValue.toInt()}%',
              rankBgColor: rankBgColor,
              rankTextColor: rankTextColor,
              isCustomBadge: isCustomBadge,
              barColors: barColors,
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

Widget buildAnalysisItem({
  required String rank,
  required String clothNumber,
  required String name,
  required String? rawScore,
  required String? category,
  required double probability,
  required String percentText,
  required Color rankBgColor,
  required Color rankTextColor,
  required bool isCustomBadge,
  required List<Color> barColors,
}) {
  return Container(
    margin: EdgeInsets.only(bottom: 12.h),
    padding: EdgeInsets.all(14.w),
    decoration: BoxDecoration(
      color: const Color(0xFF1E222B),
      borderRadius: BorderRadius.circular(12.r),
      border: Border.all(
        color: isCustomBadge ? rankBgColor.withValues(alpha: 0.4) : Colors.white12,
      ),
    ),
    child: Column(
      children: [
        Row(
          children: [
            // Rank Badge
            Container(
              width: 24.w,
              height: 24.w,
              decoration: BoxDecoration(
                color: rankBgColor,
                shape: BoxShape.circle,
                border: isCustomBadge ? null : Border.all(color: Colors.white30),
              ),
              alignment: Alignment.center,
              child: Text(
                rank,
                style: TextStyle(
                  color: rankTextColor,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(width: 8.w),

            // Cloth / Runner Number Badge
            Container(
              padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6.r),
                border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.4)),
              ),
              child: Text(
                'No: $clothNumber',
                style: TextStyle(
                  color: const Color(0xFF2DD4BF),
                  fontSize: 11.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(width: 10.w),

            // Horse Name & Argolithma Score
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name.toUpperCase(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (rawScore != null)
                    Row(
                      children: [
                        Text(
                          '${'score_label'.tr}: $rawScore',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 10.sp,
                          ),
                        ),
                        if (category != null && category.isNotEmpty) ...[
                          SizedBox(width: 6.w),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(3.r),
                            ),
                            child: Text(
                              category.tr.toUpperCase(),
                              style: TextStyle(
                                color: const Color(0xFFE6A817),
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                ],
              ),
            ),

            // Percentage Text
            Text(
              percentText,
              style: TextStyle(
                color: barColors.last,
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),

        // Progress Bar
        Stack(
          children: [
            Container(
              height: 5.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.circular(3.r),
              ),
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                return Container(
                  height: 5.h,
                  width: (constraints.maxWidth * probability).clamp(0.0, constraints.maxWidth),
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
