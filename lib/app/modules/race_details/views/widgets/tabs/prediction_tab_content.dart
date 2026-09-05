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
      final scoreA = a.normalizedScore ?? a.rawScore ?? 0.0;
      final scoreB = b.normalizedScore ?? b.rawScore ?? 0.0;
      return scoreB.compareTo(scoreA);
    });

    // Extract qualifying runners with percentage calculation
    // Rank 1 gets 100%, others proportional.
    // 6-Horse Limit & 60% Floor Cutoff
    final List<Map<String, dynamic>> eligibleRunners = [];
    for (int i = 0; i < rawEntries.length; i++) {
      final entry = rawEntries[i];
      final rank = entry.rank ?? (i + 1);
      final double score = (rank == 1)
          ? 100.0
          : (entry.normalizedScore != null
              ? entry.normalizedScore!.clamp(0.0, 99.0)
              : ((entry.winProb ?? 0.0) * 100).clamp(0.0, 99.0));

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

      // Max 6 horses total across all prediction tiers
      if (eligibleRunners.length >= 6) break;
    }

    // Bucket into exact percentage tiers according to Excel Rules:
    // MIN: 100% - 95%
    // SMALL: 94% - 90%
    // MEDIUM: 89% - 80%
    // LARGE: 79% - 70%
    // MEGA: 69% - 60%
    final minRunners = eligibleRunners.where((r) => r['score'] >= 95.0).toList();
    final smallRunners = eligibleRunners.where((r) => r['score'] >= 90.0 && r['score'] < 95.0).toList();
    final mediumRunners = eligibleRunners.where((r) => r['score'] >= 80.0 && r['score'] < 90.0).toList();
    final largeRunners = eligibleRunners.where((r) => r['score'] >= 70.0 && r['score'] < 80.0).toList();
    final megaRunners = eligibleRunners.where((r) => r['score'] >= 60.0 && r['score'] < 70.0).toList();

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header Summary Card ──────────────────────────────────────────
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: const Color(0xFF1E222B),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.stars_rounded,
                      color: const Color(0xFFE6A817),
                      size: 20.sp,
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
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6.r),
                          border: Border.all(color: Colors.red.withValues(alpha: 0.4)),
                        ),
                        child: Text(
                          '%${details!.riskRate} ${'guven_seviyesi'.tr}',
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                if (details?.predictionMessage != null && details!.predictionMessage!.isNotEmpty) ...[
                  SizedBox(height: 10.h),
                  Text(
                    details.predictionMessage!,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12.sp,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: 16.h),

          // ── 5 Tier Prediction Cards (Rectangular & Vertically Expanding) ──
          _buildTierCard(
            title: 'minimum'.tr,
            band: '%100 - %95',
            badgeColor: const Color(0xFF10B981),
            runners: minRunners,
            icon: Icons.check_circle_outline,
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
            badgeColor: const Color(0xFFE6A817),
            runners: mediumRunners,
            icon: Icons.filter_2_rounded,
          ),
          SizedBox(height: 10.h),

          _buildTierCard(
            title: 'large'.tr,
            band: '%79 - %70',
            badgeColor: const Color(0xFFF97316),
            runners: largeRunners,
            icon: Icons.filter_3_rounded,
          ),
          SizedBox(height: 10.h),

          _buildTierCard(
            title: 'mega'.tr,
            band: '%69 - %60',
            badgeColor: const Color(0xFFA855F7),
            runners: megaRunners,
            icon: Icons.auto_awesome,
          ),
          SizedBox(height: 20.h),

          // ── Mandatory Legal Warning / Disclaimer Banner ───────────────────
          Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: const Color(0xFF1E222B),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.amber,
                  size: 18.sp,
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    'legal_disclaimer'.tr,
                    style: TextStyle(
                      color: Colors.white60,
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
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: const Color(0xFF1E222B),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: runners.isNotEmpty
              ? badgeColor.withValues(alpha: 0.35)
              : Colors.white12,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(5.w),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Icon(icon, color: badgeColor, size: 15.sp),
              ),
              SizedBox(width: 8.w),
              Text(
                title.toUpperCase(),
                style: TextStyle(
                  color: badgeColor,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
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
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 11.sp,
                  ),
                ),
            ],
          ),
          SizedBox(height: 10.h),
          if (runners.isEmpty)
            Text(
              'Bu aralıkta uygun at bulunamadı',
              style: TextStyle(color: Colors.white24, fontSize: 11.sp, fontStyle: FontStyle.italic),
            )
          else
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: runners.map((r) {
                final clothNo = r['clothNo'];
                final name = r['name'];

                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF121418),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: badgeColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          '$clothNo',
                          style: TextStyle(
                            color: badgeColor,
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
