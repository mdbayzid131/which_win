import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:which_win/app/modules/race_details/controllers/race_details_controller.dart';

class PredictionTabContent extends GetView<RaceDetailsController> {
  const PredictionTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    final details = controller.raceDetails.value;
    final rawEntries = [...(details?.entries ?? [])];

    // Sort entries strictly by rank / score descending
    rawEntries.sort((a, b) {
      final rankA = a.rank ?? 999;
      final rankB = b.rank ?? 999;
      if (rankA != rankB) return rankA.compareTo(rankB);
      final scoreA = a.normalizedScore ?? a.rawScore ?? a.horsePower ?? 0.0;
      final scoreB = b.normalizedScore ?? b.rawScore ?? b.horsePower ?? 0.0;
      return scoreB.compareTo(scoreA);
    });

    double topFieldScore = 0.0;
    for (final e in rawEntries) {
      final s = e.rawScore ?? e.horsePower ?? (e.normalizedScore ?? 0.0);
      if (s > topFieldScore) topFieldScore = s;
    }

    // Extract qualifying runners with percentage calculation (6-Horse Limit & 60% Floor Cutoff)
    final List<Map<String, dynamic>> eligibleRunners = [];
    for (int i = 0; i < rawEntries.length; i++) {
      final entry = rawEntries[i];
      final rank = entry.rank ?? (i + 1);
      final rawScore = entry.rawScore ?? entry.horsePower ?? 0.0;

      double score;
      if (i == 0) {
        score = 100.0;
      } else if (entry.normalizedScore != null && entry.normalizedScore! > 0) {
        score = entry.normalizedScore!.clamp(0.0, 99.0);
      } else if (topFieldScore > 0 && rawScore > 0) {
        score = ((rawScore / topFieldScore) * 100.0).clamp(0.0, 99.0);
      } else if (entry.winProb != null && entry.winProb! > 0) {
        score = (entry.winProb! * 100.0).clamp(0.0, 99.0);
      } else {
        score = (100.0 - (i * 7.0)).clamp(60.0, 99.0);
      }

      // Cut off under 60%
      if (score >= 60.0) {
        eligibleRunners.add({
          'entry': entry,
          'rank': rank,
          'score': score,
          'clothNo': entry.number ?? entry.draw ?? rank,
          'name': entry.horse?.name ?? 'Unknown Horse',
        });
      }

      if (eligibleRunners.length >= 6) break;
    }

    // Bucket into exact percentage tiers according to Excel Rules:
    final minRunners = eligibleRunners
        .where((r) => r['score'] >= 95.0)
        .toList();
    final smallRunners = eligibleRunners
        .where((r) => r['score'] >= 90.0 && r['score'] < 95.0)
        .toList();
    final mediumRunners = eligibleRunners
        .where((r) => r['score'] >= 80.0 && r['score'] < 90.0)
        .toList();
    final largeRunners = eligibleRunners
        .where((r) => r['score'] >= 70.0 && r['score'] < 80.0)
        .toList();
    final megaRunners = eligibleRunners
        .where((r) => r['score'] >= 60.0 && r['score'] < 70.0)
        .toList();

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header Summary Card (Sleek Dark Theme) ─────────────────────────
          Container(
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
                      Icons.auto_awesome,
                      color: const Color(0xFFD4AF37),
                      size: 18.sp,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'which_win_tahmini'.tr,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    if (details?.riskRate != null)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 3.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF222630),
                          borderRadius: BorderRadius.circular(6.r),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Text(
                          '%${details!.riskRate} ${'guven_seviyesi'.tr}',
                          style: TextStyle(
                            color: const Color(0xFFF87171),
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                if (details?.predictionMessage != null &&
                    details!.predictionMessage!.isNotEmpty) ...[
                  SizedBox(height: 8.h),
                  Text(
                    details.predictionMessage!,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12.sp,
                      height: 1.35,
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: 14.h),

          // ── 5 Tier Prediction Cards (Refined & Unified Theme) ──────────────
          _buildTierCard(
            title: 'minimum'.tr,
            band: '%100 - %95',
            badgeColor: const Color(0xFF10B981),
            runners: minRunners,
            icon: Icons.verified_outlined,
          ),
          SizedBox(height: 10.h),

          _buildTierCard(
            title: 'small'.tr,
            band: '%94 - %90',
            badgeColor: const Color(0xFF38BDF8),
            runners: smallRunners,
            icon: Icons.filter_1_rounded,
          ),
          SizedBox(height: 10.h),

          _buildTierCard(
            title: 'medium'.tr,
            band: '%89 - %80',
            badgeColor: const Color(0xFFF59E0B),
            runners: mediumRunners,
            icon: Icons.filter_2_rounded,
          ),
          SizedBox(height: 10.h),

          _buildTierCard(
            title: 'large'.tr,
            band: '%79 - %70',
            badgeColor: const Color(0xFF94A3B8),
            runners: largeRunners,
            icon: Icons.filter_3_rounded,
          ),
          SizedBox(height: 10.h),

          _buildTierCard(
            title: 'mega'.tr,
            band: '%69 - %60',
            badgeColor: const Color(0xFF71717A),
            runners: megaRunners,
            icon: Icons.filter_4_rounded,
          ),
          SizedBox(height: 18.h),

          // ── Mandatory Legal Warning / Disclaimer Banner ───────────────────
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: const Color(0xFF14171D),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: Colors.white.withOpacity(0.06)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  color: const Color(0xFF8E99A8),
                  size: 16.sp,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'legal_disclaimer'.tr,
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 11.sp,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 30.h),
        ],
      ),
    );
  }

  Widget _buildTierCard({
    required String title,
    required String band,
    required Color badgeColor,
    required List<Map<String, dynamic>> runners,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(13.w),
      decoration: BoxDecoration(
        color: const Color(0xFF181B22),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: runners.isNotEmpty
              ? Colors.white12
              : Colors.white.withOpacity(0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: badgeColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(5.r),
                ),
                child: Icon(icon, color: badgeColor, size: 14.sp),
              ),
              SizedBox(width: 8.w),
              Text(
                title.toUpperCase(),
                style: TextStyle(
                  color: badgeColor,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.4,
                ),
              ),
              SizedBox(width: 6.w),
              Text(
                '($band)',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              if (runners.isNotEmpty)
                Text(
                  '${runners.length} at',
                  style: TextStyle(color: Colors.white38, fontSize: 11.sp),
                ),
            ],
          ),
          SizedBox(height: 10.h),
          if (runners.isEmpty)
            Text(
              'no_horses_in_band'.tr,
              style: TextStyle(
                color: Colors.white24,
                fontSize: 11.sp,
                fontStyle: FontStyle.italic,
              ),
            )
          else
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: runners.map((r) {
                final clothNo = r['clothNo'];
                final name = r['name'];

                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF121418),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF252A36),
                          borderRadius: BorderRadius.circular(4.r),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.06),
                          ),
                        ),
                        child: Text(
                          '$clothNo',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        name,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}
