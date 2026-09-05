import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:which_win/app/modules/race_details/controllers/race_details_controller.dart';
import 'package:which_win/core/utils/helpers.dart';

class PremiumLockOverlay extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;

  const PremiumLockOverlay({
    super.key,
    required this.icon,
    required this.label,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64.w,
              height: 64.w,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFE6A817), Color(0xFFCC8800)],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lock_outline,
                color: Colors.black87,
                size: 30.sp,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              description,
              style: TextStyle(
                color: Colors.white60,
                fontSize: 12.sp,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            GestureDetector(
              onTap: () => showPremiumPrompt(context),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE6A817), Color(0xFFCC8800)],
                  ),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  '✦  ${'upgrade_to_premium'.tr}',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LockedCard extends StatelessWidget {
  final Widget card;

  const LockedCard({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IgnorePointer(child: Opacity(opacity: 0.2, child: card)),
        Positioned.fill(
          child: GestureDetector(
            onTap: () => showPremiumPrompt(context),
            child: Container(
              margin: EdgeInsets.only(bottom: 12.h),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: const Color(0xFFE6A817).withValues(alpha: 0.2),
                ),
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.lock_outline,
                      color: const Color(0xFFE6A817),
                      size: 16.sp,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      'premium_only'.tr,
                      style: TextStyle(
                        color: const Color(0xFFE6A817),
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

void showPremiumPrompt(BuildContext context) {
  Get.bottomSheet(
    Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1419),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
        border: Border.all(
          color: const Color(0xFF2DD4BF).withValues(alpha: 0.2),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 24.h),
            Container(
              width: 64.w,
              height: 64.w,
              decoration: BoxDecoration(
                color: const Color(0xFF2DD4BF).withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF2DD4BF).withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: Icon(
                Icons.workspace_premium_rounded,
                color: const Color(0xFF2DD4BF),
                size: 32.sp,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'Unlock Premium Access',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Unlock advanced AI analytics, win probabilities,\nfair odds, and daily horse ratings.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white60,
                fontSize: 13.sp,
                height: 1.4,
              ),
            ),
            SizedBox(height: 24.h),
            GestureDetector(
              onTap: () {
                Get.back();
                Get.toNamed('/subscription');
              },
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2DD4BF), Color(0xFF0D9488)],
                  ),
                  borderRadius: BorderRadius.circular(14.r),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2DD4BF).withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  'View Plans',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xFF0F1419),
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 12.h),
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                'Maybe Later',
                style: TextStyle(color: Colors.white38, fontSize: 13.sp),
              ),
            ),
          ],
        ),
      ),
    ),
    isScrollControlled: true,
  );
}

void showHorseDetails(
  BuildContext context,
  String horseName,
  int hpVal,
  RaceDetailsController controller,
) {
  Get.bottomSheet(
    Obx(() {
      if (controller.isHorseLoading.value) {
        return Container(
          height: Get.height * 0.85,
          decoration: BoxDecoration(
            color: const Color(0xFF121418),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
            border: Border.all(color: Colors.white24),
          ),
          child: const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
            ),
          ),
        );
      }

      final horse = controller.horseDetails.value;
      if (horse == null) {
        return Container(
          height: Get.height * 0.85,
          decoration: BoxDecoration(
            color: const Color(0xFF121418),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
            border: Border.all(color: Colors.white24),
          ),
          child: Center(
            child: Text(
              'Failed to load career profile',
              style: TextStyle(color: Colors.white60, fontSize: 14.sp),
            ),
          ),
        );
      }

      final wins = horse.wins ?? 0;
      final seconds = horse.seconds ?? 0;
      final thirds = horse.thirds ?? 0;
      final totalRaces = horse.totalRaces ?? 0;

      final winRate = totalRaces > 0
          ? ((wins / totalRaces) * 100).toStringAsFixed(0)
          : '0';
      final top3Rate = totalRaces > 0
          ? (((wins + seconds + thirds) / totalRaces) * 100).toStringAsFixed(0)
          : '0';

      final results = horse.results ?? [];
      final totalEarnings = horse.totalEarnings ?? 0.0;
      final earningsText = Helpers.formatCurrency(totalEarnings);
      final last6Form = results
          .take(6)
          .map((r) => '${r.position ?? ""}')
          .join('');

      return Container(
        height: Get.height * 0.85,
        decoration: BoxDecoration(
          color: const Color(0xFF121418),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          border: Border.all(color: Colors.white24),
        ),
        padding: EdgeInsets.all(20.w),
        child: SafeArea(
          top: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (horse.name ?? horseName).toUpperCase(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          '${horse.age ?? 4}yo ${horse.color ?? "d"} · ${horse.country ?? "TR"}',
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 13.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: Colors.white60,
                      size: 24.sp,
                    ),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E222B),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: const Color(0xFF1E222B)),
                ),
                child: Center(
                  child: Text(
                    'Stats: $winRate% Win | $top3Rate% Top 3 | Last 6: $last6Form',
                    style: TextStyle(
                      color: const Color(0xFF10B981),
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Row(
                children: [
                  Expanded(child: buildInfoBox('HP Score', '$hpVal')),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: buildInfoBox('Total Earnings', earningsText),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              buildPopupSection(
                'PEDIGREE',
                'Sire: ${horse.sireName ?? "N/A"} · Dam: ${horse.damName ?? "N/A"}',
              ),
              SizedBox(height: 16.h),
              buildPopupSection(
                'TEAM',
                'Owner: ${horse.owner ?? "N/A"} · Trainer: ${horse.trainer ?? "N/A"}',
              ),
              SizedBox(height: 20.h),
              Text(
                'RACE HISTORY (LAST 6)',
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10.h),
              Expanded(
                child: ListView.builder(
                  itemCount: results.length,
                  itemBuilder: (context, idx) {
                    final run = results[idx];
                    final pos = run.position ?? 0;
                    Color badgeColor = Colors.grey;
                    if (pos == 1) {
                      badgeColor = const Color(0xFF1A4D40);
                    } else if (pos == 2) {
                      badgeColor = const Color(0xFF268060);
                    } else if (pos == 3) {
                      badgeColor = Colors.orange;
                    }

                    return buildHistoryItem(
                      '$pos',
                      run.race?.name ?? 'Race ${idx + 1}',
                      '${run.race?.distance ?? ""} · ${run.race?.trackType ?? ""}',
                      badgeColor,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    }),
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
  );
}

Widget buildInfoBox(String title, String value) {
  return Container(
    padding: EdgeInsets.all(12.w),
    decoration: BoxDecoration(
      color: const Color(0xFF1E222B),
      borderRadius: BorderRadius.circular(8.r),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(color: Colors.white60, fontSize: 11.sp),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}

Widget buildPopupSection(String title, String content) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: TextStyle(
          color: Colors.white60,
          fontSize: 10.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
      SizedBox(height: 6.h),
      Text(
        content,
        style: TextStyle(color: Colors.white, fontSize: 13.sp),
      ),
    ],
  );
}

Widget buildHistoryItem(
  String rank,
  String title,
  String subtitle,
  Color rankColor,
) {
  return Padding(
    padding: EdgeInsets.only(bottom: 12.h),
    child: Column(
      children: [
        Row(
          children: [
            Container(
              width: 24.w,
              height: 24.w,
              decoration: BoxDecoration(
                color: rankColor,
                borderRadius: BorderRadius.circular(4.r),
              ),
              alignment: Alignment.center,
              child: Text(
                rank,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(color: Colors.white, fontSize: 13.sp),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              subtitle,
              style: TextStyle(color: Colors.white60, fontSize: 11.sp),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        const Divider(color: Colors.white24, height: 1),
      ],
    ),
  );
}
