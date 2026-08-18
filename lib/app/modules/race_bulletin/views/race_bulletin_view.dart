import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:which_win/app/routes/app_pages.dart';
import 'package:which_win/data/models/race_details_model.dart';
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
        title: Obx(() {
          final race = controller.race.value;
          final details = controller.raceDetails.value;
          final count = details?.entries?.length ?? race?.entriesCount ?? 0;
          final date = race?.date ?? '';
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                race?.name ?? 'Race Bulletin',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '$count entries · $date',
                style: TextStyle(color: Colors.white38, fontSize: 12.sp),
              ),
            ],
          );
        }),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF4DB6AC)),
          );
        }

        final entries = controller.raceDetails.value?.entries ?? [];
        final race = controller.race.value;

        if (entries.isEmpty) {
          return Center(
            child: Text(
              'No entries available',
              style: TextStyle(color: Colors.white38, fontSize: 16.sp),
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(16.w),
          itemCount: entries.length,
          itemBuilder: (context, index) {
            final entry = entries[index];
            return GestureDetector(
              onTap: () => Get.toNamed(AppRoutes.RACE_ANALYSIS),
              child: _buildRaceItem(index + 1, entry, race),
            );
          },
        );
      }),
    );
  }

  Widget _buildRaceItem(int raceNumber, RaceEntry entry, dynamic race) {
    final horseName = entry.horse?.name ?? 'N/A';
    final draw = entry.draw?.toString() ?? 'N/A';
    final weight = entry.weightStr ?? entry.weight?.toStringAsFixed(0) ?? 'N/A';
    final distance = (race?.distance as String?) ?? 'N/A';
    final surfaceLabel = (race?.surfaceLabel as String?) ?? 'N/A';
    final winProb = entry.winProb != null
        ? '${(entry.winProb! * 100).toInt()}% win'
        : 'N/A';
    final jockeyName = entry.jockeyName ?? 'N/A';
    final trainerName = entry.trainerName ?? entry.horse?.trainer ?? 'N/A';

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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              horseName,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'Draw: $draw',
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
                          _buildTag(surfaceLabel, const Color(0xFF003D33),
                              textColor: const Color(0xFF4DB6AC)),
                          SizedBox(width: 8.w),
                          Text(
                            distance,
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: 12.sp,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            '${weight}kg',
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      winProb,
                      style: TextStyle(
                        color: const Color(0xFF4DB6AC),
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${entry.draw != null ? entry.draw! : "N/A"}',
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
          Padding(
            padding: EdgeInsets.all(12.w),
            child: RichText(
              text: TextSpan(
                style: TextStyle(color: Colors.white38, fontSize: 13.sp),
                children: [
                  const TextSpan(text: 'Jockey: '),
                  TextSpan(
                    text: jockeyName,
                    style: TextStyle(color: Colors.orange.withOpacity(0.8)),
                  ),
                  const TextSpan(text: '  |  Trainer: '),
                  TextSpan(
                    text: trainerName,
                    style: const TextStyle(color: Colors.orange),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color bgColor,
      {Color textColor = Colors.white70}) {
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
