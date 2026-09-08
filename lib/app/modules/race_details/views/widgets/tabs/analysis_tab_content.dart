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
      final scoreA = a.normalizedScore ?? a.rawScore ?? a.horsePower ?? 0.0;
      final scoreB = b.normalizedScore ?? b.rawScore ?? b.horsePower ?? 0.0;
      return scoreB.compareTo(scoreA);
    });

    // Find max score in the field for proportional percentage (Excel formula)
    double topFieldScore = 0.0;
    for (final e in entries) {
      final s = e.rawScore ?? e.horsePower ?? (e.normalizedScore ?? 0.0);
      if (s > topFieldScore) topFieldScore = s;
    }

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: const Color(0xFF181B22),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.auto_graph_rounded,
                      color: const Color(0xFFD4AF37),
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
                SizedBox(height: 10.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: [
                    buildAnalysisTag(
                      label: 'track_bias'.tr,
                      value: trackType,
                    ),
                    buildAnalysisTag(
                      label: 'dist'.tr,
                      value: distance,
                    ),
                    buildAnalysisTag(
                      label: 'field'.tr,
                      value: '$runnersCount',
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 14.h),
          ...List.generate(entries.length, (index) {
            final entry = entries[index];
            final rank = entry.rank ?? (index + 1);
            final clothNo = entry.number ?? entry.draw ?? rank;
            final name = entry.horse?.name ?? 'unknown_horse'.tr;
            final rawScore = entry.rawScore ?? entry.horsePower ?? 0.0;

            // Excel Formula: Rank 1 gets 100%, others proportional = (HorseScore / TopScore) * 100
            double percentValue;
            if (entry.normalizedScore != null && entry.normalizedScore! > 0) {
              percentValue = entry.normalizedScore!.clamp(0.0, 100.0);
            } else if (topFieldScore > 0 && rawScore > 0) {
              percentValue = (index == 0)
                  ? 100.0
                  : ((rawScore / topFieldScore) * 100.0).clamp(0.0, 99.0);
            } else if (entry.winProb != null && entry.winProb! > 0) {
              percentValue = (entry.winProb! * 100.0).clamp(0.0, 100.0);
            } else {
              percentValue = 0.0;
            }

            Color rankBgColor;
            Color rankTextColor = Colors.white;

            if (rank == 1) {
              rankBgColor = const Color(0xFFD4AF37);
              rankTextColor = const Color(0xFF121418);
            } else if (rank == 2) {
              rankBgColor = const Color(0xFF94A3B8);
              rankTextColor = const Color(0xFF121418);
            } else if (rank == 3) {
              rankBgColor = const Color(0xFFA86D3C);
              rankTextColor = Colors.white;
            } else {
              rankBgColor = const Color(0xFF252A36);
              rankTextColor = Colors.white60;
            }

            Color barColor;
            if (percentValue >= 80) {
              barColor = const Color(0xFF10B981);
            } else if (percentValue >= 50) {
              barColor = const Color(0xFFD4AF37);
            } else {
              barColor = const Color(0xFF64748B);
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
              barColor: barColor,
            );
          }),
          SizedBox(height: 14.h),
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

Widget buildAnalysisTag({required String label, required String value}) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
    decoration: BoxDecoration(
      color: const Color(0xFF252A36),
      borderRadius: BorderRadius.circular(6.r),
      border: Border.all(color: Colors.white.withOpacity(0.06)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            color: Colors.white38,
            fontSize: 10.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 10.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
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
  required Color barColor,
}) {
  return Container(
    margin: EdgeInsets.only(bottom: 10.h),
    padding: EdgeInsets.all(12.w),
    decoration: BoxDecoration(
      color: const Color(0xFF181B22),
      borderRadius: BorderRadius.circular(12.r),
      border: Border.all(color: Colors.white10),
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
                color: const Color(0xFF252A36),
                borderRadius: BorderRadius.circular(6.r),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: Text(
                'No: $clothNumber',
                style: TextStyle(
                  color: Colors.white70,
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
                            padding: EdgeInsets.symmetric(
                              horizontal: 5.w,
                              vertical: 1.h,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF252A36),
                              borderRadius: BorderRadius.circular(3.r),
                            ),
                            child: Text(
                              category.tr.toUpperCase(),
                              style: TextStyle(
                                color: const Color(0xFFD4AF37),
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
                color: Colors.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),

        // Progress Bar (Sleek Minimalist Track)
        Stack(
          children: [
            Container(
              height: 4.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                return Container(
                  height: 4.h,
                  width: (constraints.maxWidth * probability).clamp(
                    0.0,
                    constraints.maxWidth,
                  ),
                  decoration: BoxDecoration(
                    color: barColor,
                    borderRadius: BorderRadius.circular(2.r),
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
