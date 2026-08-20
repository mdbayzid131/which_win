import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:which_win/app/modules/race_details/controllers/race_details_controller.dart';
import 'package:which_win/data/models/race_details_model.dart';

class BulletinTabContent extends GetView<RaceDetailsController> {
  final RaceDetailsData details;

  const BulletinTabContent({super.key, required this.details});

  @override
  Widget build(BuildContext context) {
    final entries = [...(details.entries ?? [])];
    if (entries.isEmpty) {
      return const Center(
        child: Text(
          'No horses registered',
          style: TextStyle(color: Colors.white60),
        ),
      );
    }

    entries.sort((a, b) {
      final aDraw = a.draw ?? 999;
      final bDraw = b.draw ?? 999;
      return aDraw.compareTo(bDraw);
    });

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return BulletinHorseCard(
          entry: entry,
          fallbackIndex: index,
        );
      },
    );
  }
}

class BulletinHorseCard extends GetView<RaceDetailsController> {
  final RaceEntry entry;
  final int fallbackIndex;

  const BulletinHorseCard({
    super.key,
    required this.entry,
    required this.fallbackIndex,
  });

  @override
  Widget build(BuildContext context) {
    final horse = entry.horse;
    final horseName = horse?.name ?? 'Unknown Horse';
    final jockeyName = entry.jockeyName ?? 'Unknown Jockey';
    final trainerName = entry.trainerName ?? 'N/A';
    final age = horse?.age != null ? '${horse!.age}yo' : 'N/A';
    final color = horse?.color ?? 'd';
    final sex = horse?.sex ?? 'k';
    final weightText = entry.weight != null
        ? '${entry.weight!.toStringAsFixed(0)} kg'
        : 'N/A';

    final horseNumber = entry.draw ?? (fallbackIndex + 1);

    final totalRaces = horse?.totalRaces ?? 0;
    final wins = horse?.wins ?? 0;
    final seconds = horse?.seconds ?? 0;
    final thirds = horse?.thirds ?? 0;
    final fourths = horse?.fourths ?? 0;

    final winRate = totalRaces > 0
        ? (wins / totalRaces * 100).toStringAsFixed(1)
        : '0';
    final placeRate = totalRaces > 0
        ? ((wins + seconds + thirds) / totalRaces * 100).toStringAsFixed(1)
        : '0';

    return Obx(() {
      final isExpanded =
          controller.bulletinExpandedIndex.value == fallbackIndex;

      return Container(
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
          color: const Color(0xFF1E222B),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isExpanded ? const Color(0xFFE6A817) : Colors.white24,
            width: isExpanded ? 1.2 : 1.0,
          ),
        ),
        child: Column(
          children: [
            GestureDetector(
              onTap: () => controller.toggleBulletinExpand(fallbackIndex),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Row(
                  children: [
                    Container(
                      width: 36.w,
                      height: 36.w,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E222B),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: const Color(0xFF2D9B83).withValues(alpha: 0.3),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$horseNumber',
                        style: TextStyle(
                          color: const Color(0xFFE6A817),
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            horseName.toUpperCase(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            '$age $color $sex · $weightText · ${'jockey_label'.tr}: $jockeyName',
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: 11.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Colors.white60,
                      size: 20.sp,
                    ),
                  ],
                ),
              ),
            ),
            if (isExpanded) ...[
              const Divider(color: Colors.white24, height: 1),
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: const Color(0xFF2D9B83),
                          size: 14.sp,
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          'pedigree_team'.tr.toUpperCase(),
                          style: TextStyle(
                            color: const Color(0xFFE6A817),
                            fontSize: 11.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Padding(
                      padding: EdgeInsets.only(left: 20.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${'sire'.tr}: ${horse?.sireName ?? "N/A"} · ${'dam'.tr}: ${horse?.damName ?? "N/A"}',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11.sp,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            '${'trainer'.tr}: $trainerName · ${'owner'.tr}: ${horse?.owner ?? "N/A"}',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        Icon(
                          Icons.history,
                          color: const Color(0xFF2D9B83),
                          size: 14.sp,
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          'career_performance'.tr.toUpperCase(),
                          style: TextStyle(
                            color: const Color(0xFFE6A817),
                            fontSize: 11.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Padding(
                      padding: EdgeInsets.only(left: 20.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${'total_starts'.tr}: $totalRaces  · ${'wins_1st'.tr}: $wins  · ${'places_1_3'.tr}: ${wins + seconds + thirds}',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11.sp,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            '${'win_rate'.tr}: $winRate% · ${'place_rate'.tr}: $placeRate%',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11.sp,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            '${'career_form'.tr}: $wins-$seconds-$thirds-$fourths',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      );
    });
  }
}
