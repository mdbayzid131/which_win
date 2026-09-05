import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:which_win/app/modules/race_details/controllers/race_details_controller.dart';
import 'package:which_win/data/models/race_details_model.dart';

class PredictionTabContent extends GetView<RaceDetailsController> {
  const PredictionTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    final details = controller.raceDetails.value;
    final entries = details?.entries ?? [];

    // Filter runners for each category tier
    final minimumRunners = entries.where((e) => e.category == 'MINIMUM' || e.rank == 1).toList();
    final smallRunners = entries.where((e) => e.category == 'SMALL' || e.category == 'MINIMUM' || (e.rank != null && e.rank! <= 2)).toList();
    final mediumRunners = entries.where((e) => e.category == 'MEDIUM' || e.category == 'SMALL' || e.category == 'MINIMUM' || (e.rank != null && e.rank! <= 3)).toList();
    final largeRunners = entries.where((e) => e.category == 'LARGE' || (e.rank != null && e.rank! <= 4)).toList();
    final megaRunners = entries.where((e) => e.category == 'MEGA' || (e.rank != null && e.rank! <= 6)).toList();

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

          // ── 5 Category Prediction Cards ──────────────────────────────────
          _buildCategoryCard(
            title: 'minimum'.tr,
            subtitle: 'Tek / En Güvenilir Tercih',
            badgeColor: const Color(0xFF10B981),
            runners: minimumRunners,
            icon: Icons.check_circle_outline,
          ),
          SizedBox(height: 10.h),

          _buildCategoryCard(
            title: 'small'.tr,
            subtitle: 'Küçük Kupon Adayları',
            badgeColor: const Color(0xFF38BDF8),
            runners: smallRunners,
            icon: Icons.filter_1_rounded,
          ),
          SizedBox(height: 10.h),

          _buildCategoryCard(
            title: 'medium'.tr,
            subtitle: 'Orta Kupon Adayları',
            badgeColor: const Color(0xFFE6A817),
            runners: mediumRunners,
            icon: Icons.filter_2_rounded,
          ),
          SizedBox(height: 10.h),

          _buildCategoryCard(
            title: 'large'.tr,
            subtitle: 'Geniş / Büyük Kupon Adayları',
            badgeColor: const Color(0xFFF97316),
            runners: largeRunners.isNotEmpty ? largeRunners : mediumRunners,
            icon: Icons.filter_3_rounded,
          ),
          SizedBox(height: 10.h),

          _buildCategoryCard(
            title: 'mega'.tr,
            subtitle: 'Mega / Sürpriz Kapsamı',
            badgeColor: const Color(0xFFA855F7),
            runners: megaRunners.isNotEmpty ? megaRunners : entries.take(5).toList(),
            icon: Icons.auto_awesome,
          ),
          SizedBox(height: 30.h),
        ],
      ),
    );
  }

  Widget _buildCategoryCard({
    required String title,
    required String subtitle,
    required Color badgeColor,
    required List<RaceEntry> runners,
    required IconData icon,
  }) {
    final distinctRunners = <String, RaceEntry>{};
    for (var r in runners) {
      final key = r.horse?.name ?? r.id ?? '';
      if (!distinctRunners.containsKey(key)) {
        distinctRunners[key] = r;
      }
    }
    final runnerList = distinctRunners.values.toList();

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: const Color(0xFF1E222B),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Icon(icon, color: badgeColor, size: 16.sp),
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
              const Spacer(),
              Text(
                '${runnerList.length} at',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 11.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          if (runnerList.isEmpty)
            Text(
              'no_data_available'.tr,
              style: TextStyle(color: Colors.white38, fontSize: 11.sp),
            )
          else
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: runnerList.map((entry) {
                final clothNo = entry.number ?? entry.draw ?? entry.rank ?? 1;
                final name = entry.horse?.name ?? 'Horse';
                final percent = entry.normalizedScore?.toInt() ?? 
                    (entry.rank == 1 ? 100 : (entry.winProb != null ? (entry.winProb! * 100).toInt() : 0));

                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF121418),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: Colors.white12),
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
                      SizedBox(width: 6.w),
                      Text(
                        name,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        '$percent%',
                        style: TextStyle(
                          color: const Color(0xFF2DD4BF),
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold,
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
