import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:which_win/app/modules/race_details/controllers/race_details_controller.dart';

class _StatItem {
  final String label;
  final double value;

  _StatItem(this.label, this.value);
}

class StatisticsTabContent extends GetView<RaceDetailsController> {
  const StatisticsTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final stats = controller.raceStats.value;
      if (controller.isStatsLoading.value && stats == null) {
        return const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
          ),
        );
      }

      if (stats == null) {
        return  Center(
          child: Text(
            'no_statistics_available'.tr,
            style: TextStyle(color: Colors.white60),
          ),
        );
      }

      return GridView.count(
        crossAxisCount: 2,
        padding: EdgeInsets.all(12.w),
        mainAxisSpacing: 12.h,
        crossAxisSpacing: 12.w,
        childAspectRatio: 1.05,
        children: [
          _buildStatCard(
            'earnings_stat'.tr,
            Icons.payments_outlined,
            (stats.earnings ?? [])
                .map(
                  (e) => _StatItem(
                    '${e.horseName}: ${e.amount}',
                    (e.percentage ?? 0) / 100.0,
                  ),
                )
                .toList(),
          ),
          _buildStatCard(
            'origin_stat'.tr,
            Icons.public_outlined,
            (stats.origin ?? [])
                .map(
                  (e) => _StatItem(
                    '${e.country} ${e.percentage}%',
                    (e.percentage ?? 0) / 100.0,
                  ),
                )
                .toList(),
          ),
          _buildStatCard(
            'distance_stat'.tr,
            Icons.straighten_outlined,
            (stats.distance ?? [])
                .map(
                  (e) => _StatItem(
                    '${e.label}: ${e.detail}',
                    (e.percentage ?? 0) / 100.0,
                  ),
                )
                .toList(),
          ),
          _buildStatCard(
            'track_stat'.tr,
            Icons.layers_outlined,
            (stats.track ?? [])
                .map(
                  (e) => _StatItem(
                    '${e.surface}: ${e.detail}',
                    (e.percentage ?? 0) / 100.0,
                  ),
                )
                .toList(),
          ),
        ],
      );
    });
  }

  Widget _buildStatCard(String title, IconData icon, List<_StatItem> items) {
    return Container(
      padding: EdgeInsets.all(12.w),
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
              Icon(icon, color: const Color(0xFFE6A817), size: 14.sp),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Expanded(
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (context, index) => SizedBox(height: 8.h),
              itemBuilder: (context, index) {
                final item = items[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item.label,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 10.sp,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '${(item.value * 100).toInt()}%',
                          style: TextStyle(
                            color: const Color(0xFF2D9B83),
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2.r),
                      child: LinearProgressIndicator(
                        value: item.value,
                        backgroundColor: Colors.white24,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF2D9B83),
                        ),
                        minHeight: 4.h,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
