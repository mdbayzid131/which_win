import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:which_win/app/routes/app_pages.dart';
import 'package:which_win/data/models/race_model.dart';
import '../controllers/race_bulletin_controller.dart';

class RaceBulletinView extends GetView<RaceBulletinController> {
  const RaceBulletinView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Row(
          children: [
            Obx(() {
              final country = controller.race.value?.country ?? '';
              if (country.isEmpty) return const SizedBox.shrink();
              final flagCode = _getFlagCode(country);
              return Container(
                width: 32.w,
                height: 32.w,
                margin: EdgeInsets.only(right: 8.w),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white24, width: 1.5),
                ),
                child: ClipOval(
                  child: Image.network(
                    'https://flagcdn.com/w160/$flagCode.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.flag, color: Colors.white24, size: 14),
                  ),
                ),
              );
            }),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.race.value?.location ?? 'races'.tr,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Obx(
                    () => Text(
                      '${controller.raceList.length} ${'races'.tr} · ${controller.race.value?.date?.split('T').first ?? ''}',
                      style: TextStyle(color: Colors.white38, fontSize: 12.sp),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        top: false,
        bottom: true,
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4DB6AC)),
              ),
            );
          }

          if (controller.raceList.isEmpty) {
            return Center(
              child: Text(
                'no_races_meeting'.tr,
                style: TextStyle(color: Colors.white38, fontSize: 16.sp),
              ),
            );
          }

          return RefreshIndicator(
            color: const Color(0xFF4DB6AC),
            backgroundColor: const Color(0xFF0F1419),
            onRefresh: () => controller.fetchRaces(),
            child: ListView.builder(
              padding: EdgeInsets.all(16.w),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: controller.raceList.length,
              itemBuilder: (context, index) {
                final raceModel = controller.raceList[index];
                return GestureDetector(
                  onTap: () {
                    if (raceModel.status == 'FINISHED') {
                      Get.toNamed(AppRoutes.RACE_ANALYSIS, arguments: raceModel);
                    } else {
                      Get.toNamed(AppRoutes.RACE_DETAILS, arguments: raceModel);
                    }
                  },
                  child: _buildRaceItem(raceModel, index + 1),
                );
              },
            ),
          );
        }),
      ),
    );
  }

  Widget _buildRaceItem(RaceModel raceModel, int raceNumber) {
    final trackType = raceModel.trackType ?? 'Turf';
    final entriesCount = raceModel.entriesCount ?? 0;
    String labelText = 'ai_prediction'.tr;
    String restMessage = '';
    if (raceModel.predictionMessage != null &&
        raceModel.predictionMessage!.isNotEmpty) {
      final msg = raceModel.predictionMessage!;
      if (msg.toLowerCase().startsWith('who beat whom:')) {
        labelText = 'who_beat_whom'.tr;
        restMessage = msg.substring(14).trim();
      } else {
        labelText = 'ai_prediction'.tr;
        restMessage = msg;
      }
    }

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1419),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.white12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(12.w),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Race Number Circle
                  Container(
                    width: 44.w,
                    height: 44.w,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF004D40), Color(0xFF00796B)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10.r),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00796B).withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$raceNumber',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w900,
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
                            Expanded(
                              child: Text(
                                raceModel.name ?? 'Race $raceNumber',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              raceModel.time ?? '',
                              style: TextStyle(
                                color: Colors.white38,
                                fontSize: 14.sp,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        Wrap(
                          spacing: 6.w,
                          runSpacing: 6.h,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            _buildStatusTag(raceModel.status ?? 'UPCOMING'),
                            _buildInfoTag(
                              trackType,
                              _getTrackIcon(trackType),
                              const Color(0xFF4DB6AC),
                            ),
                            if (raceModel.distance != null &&
                                raceModel.distance!.isNotEmpty)
                              _buildInfoTag(
                                raceModel.distance!,
                                Icons.straighten,
                                Colors.amber[600]!,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 12.w),
                  // Runners count
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.groups_rounded,
                          color: const Color(0xFF4DB6AC),
                          size: 16.sp,
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          '$entriesCount',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'runners_label'.tr,
                          style: TextStyle(
                            color: Colors.white38,
                            fontSize: 8.sp,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (restMessage.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B).withValues(alpha: 0.25),
                  border: const Border(top: BorderSide(color: Colors.white10)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      labelText.contains('Prediction')
                          ? Icons.auto_awesome
                          : Icons.compare_arrows_rounded,
                      color: labelText.contains('Prediction')
                          ? const Color(0xFF4DB6AC)
                          : Colors.orangeAccent,
                      size: 16.sp,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12.sp,
                            height: 1.3,
                          ),
                          children: [
                            TextSpan(
                              text: labelText,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white54,
                              ),
                            ),
                            TextSpan(
                              text: restMessage,
                              style: TextStyle(
                                color: labelText.contains('Prediction')
                                    ? const Color(0xFF4DB6AC)
                                    : Colors.orangeAccent,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusTag(String status) {
    Color bgColor;
    Color textColor;
    IconData icon;

    switch (status.toUpperCase()) {
      case 'LIVE':
        bgColor = const Color(0xFF7F1D1D).withValues(alpha: 0.2);
        textColor = const Color(0xFFFCA5A5);
        icon = Icons.sensors;
        break;
      case 'FINISHED':
        bgColor = const Color(0xFF1E293B);
        textColor = const Color(0xFF94A3B8);
        icon = Icons.check_circle_outline;
        break;
      case 'UPCOMING':
      default:
        bgColor = const Color(0xFF0F2D37);
        textColor = const Color(0xFF38BDF8);
        icon = Icons.schedule;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: textColor.withValues(alpha: 0.2), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: textColor, size: 12.sp),
          SizedBox(width: 4.w),
          Text(
            status.toUpperCase() == 'LIVE'
                ? 'live'.tr
                : (status.toUpperCase() == 'FINISHED'
                    ? 'finished'.tr
                    : 'upcoming'.tr),
            style: TextStyle(
              color: textColor,
              fontSize: 10.sp,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTag(String text, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12.sp),
          SizedBox(width: 4.w),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 10.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getTrackIcon(String track) {
    final t = track.toLowerCase();
    if (t.contains('turf') || t.contains('grass')) {
      return Icons.grass;
    }
    if (t.contains('dirt') || t.contains('sand')) {
      return Icons.landscape;
    }
    return Icons.waves_rounded;
  }

  String _getFlagCode(String country) {
    final c = country.trim().toLowerCase();
    if (c == 'united kingdom' || c == 'uk' || c == 'great britain' || c == 'gb') return 'gb';
    if (c == 'france' || c == 'fr') return 'fr';
    if (c == 'turkey' || c == 'tr' || c == 'türkiye') return 'tr';
    if (c == 'united states' || c == 'usa' || c == 'us') return 'us';
    if (c == 'ireland' || c == 'ire' || c == 'ie') return 'ie';
    if (c == 'australia' || c == 'aus' || c == 'au') return 'au';

    if (c.contains('kingdom') || c.contains('britain')) return 'gb';
    if (c.contains('france')) return 'fr';
    if (c.contains('turkey') || c.contains('türkiye')) return 'tr';
    if (c.contains('states') || c.contains('america')) return 'us';
    if (c.contains('ireland')) return 'ie';
    if (c.contains('australia')) return 'au';

    return 'gb';
  }
}
