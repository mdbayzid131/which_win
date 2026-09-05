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
    final results = details.results ?? [];
    final entries = details.entries ?? [];
    final isFinished = details.status?.toUpperCase() == 'FINISHED' || results.isNotEmpty;

    if (isFinished && results.isNotEmpty) {
      // Sort results strictly by finishing position
      final sortedResults = [...results];
      sortedResults.sort((a, b) => (a.position ?? 999).compareTo(b.position ?? 999));

      return ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        itemCount: sortedResults.length,
        itemBuilder: (context, index) {
          final result = sortedResults[index];
          // Match corresponding entry if available for fallback data
          final matchingEntry = entries.firstWhereOrNull(
            (e) => e.horseId == result.horse?.id || e.horse?.name?.toLowerCase() == result.horse?.name?.toLowerCase(),
          );

          return ResultHorseCard(
            result: result,
            matchingEntry: matchingEntry,
            fallbackIndex: index,
          );
        },
      );
    }

    if (entries.isEmpty) {
      return Center(
        child: Text(
          'no_horses_registered'.tr,
          style: const TextStyle(color: Colors.white60),
        ),
      );
    }

    final sortedEntries = [...entries];
    sortedEntries.sort((a, b) {
      final aDraw = a.number ?? a.draw ?? 999;
      final bDraw = b.number ?? b.draw ?? 999;
      return aDraw.compareTo(bDraw);
    });

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      itemCount: sortedEntries.length,
      itemBuilder: (context, index) {
        final entry = sortedEntries[index];
        return BulletinHorseCard(
          entry: entry,
          fallbackIndex: index,
        );
      },
    );
  }
}

class ResultHorseCard extends GetView<RaceDetailsController> {
  final RaceResult result;
  final RaceEntry? matchingEntry;
  final int fallbackIndex;

  const ResultHorseCard({
    super.key,
    required this.result,
    this.matchingEntry,
    required this.fallbackIndex,
  });

  @override
  Widget build(BuildContext context) {
    final position = result.position ?? (fallbackIndex + 1);
    final horseName = result.horse?.name ?? matchingEntry?.horse?.name ?? 'Unknown Horse';
    final clothNumber = result.number ?? matchingEntry?.number ?? matchingEntry?.draw ?? position;

    final jockeyName = result.jockey?.name ?? matchingEntry?.jockeyName ?? 'N/A';
    final hp = result.or ?? result.rpr ?? (matchingEntry?.horsePower != null ? matchingEntry!.horsePower!.toStringAsFixed(0) : '-');
    final weight = result.weight != null
        ? '${result.weight!.toStringAsFixed(0)} kg'
        : (matchingEntry?.weight != null ? '${matchingEntry!.weight!.toStringAsFixed(0)} kg' : 'N/A');
    final timeStr = (result.time != null && result.time!.isNotEmpty && result.time != 'N/A')
        ? result.time!
        : '-';
    final margin = result.btn ?? result.ovrBtn ?? (position == 1 ? 'KAZANDI' : '-');
    final odds = result.sp ?? matchingEntry?.winOddsFair?.toStringAsFixed(2) ?? '-';

    Color posBgColor;
    Color posTextColor = Colors.black;
    if (position == 1) {
      posBgColor = const Color(0xFFE6A817);
    } else if (position == 2) {
      posBgColor = const Color(0xFF94A3B8);
    } else if (position == 3) {
      posBgColor = const Color(0xFFCD7F32);
      posTextColor = Colors.white;
    } else {
      posBgColor = const Color(0xFF282E3A);
      posTextColor = Colors.white70;
    }

    return Obx(() {
      final isExpanded = controller.bulletinExpandedIndex.value == fallbackIndex;

      return Container(
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
          color: const Color(0xFF1E222B),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isExpanded ? const Color(0xFFE6A817) : Colors.white12,
            width: isExpanded ? 1.2 : 1.0,
          ),
        ),
        child: Column(
          children: [
            GestureDetector(
              onTap: () => controller.toggleBulletinExpand(fallbackIndex),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: EdgeInsets.all(14.w),
                child: Row(
                  children: [
                    // Position Badge
                    Container(
                      width: 28.w,
                      height: 28.w,
                      decoration: BoxDecoration(
                        color: posBgColor,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$position',
                        style: TextStyle(
                          color: posTextColor,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),

                    // Cloth Number Badge
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

                    // Horse Name
                    Expanded(
                      child: Text(
                        horseName.toUpperCase(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    Icon(
                      isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      color: Colors.white54,
                      size: 20.sp,
                    ),
                  ],
                ),
              ),
            ),

            // Expanded Detail Grid: JOKEY | HP | KG | DERECE | FARK | ORAN
            if (isExpanded)
              Container(
                padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 14.h),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.white10)),
                ),
                child: Column(
                  children: [
                    SizedBox(height: 10.h),
                    Row(
                      children: [
                        _buildResultStatCell('jockey_short'.tr, jockeyName, flex: 3),
                        _buildResultStatCell('hp_short'.tr, hp, flex: 1),
                        _buildResultStatCell('kg_short'.tr, weight, flex: 2),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        _buildResultStatCell('derece_label'.tr, timeStr, flex: 3),
                        _buildResultStatCell('fark_label'.tr, margin, flex: 2),
                        _buildResultStatCell('oran_label'.tr, odds, flex: 1),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildResultStatCell(String label, String value, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 2.w),
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: const Color(0xFF121418),
          borderRadius: BorderRadius.circular(6.r),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: const Color(0xFFE6A817),
                fontSize: 9.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
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
    final age = horse?.age != null ? '${horse!.age}yo' : 'N/A';
    final color = horse?.color ?? 'd';
    final sex = horse?.sex ?? 'k';
    final weightText = entry.weight != null
        ? '${entry.weight!.toStringAsFixed(0)} kg'
        : 'N/A';

    final horseNumber = entry.number ?? entry.draw ?? (fallbackIndex + 1);

    final totalRaces = horse?.totalRaces ?? 0;
    final wins = horse?.wins ?? 0;
    final seconds = horse?.seconds ?? 0;
    final thirds = horse?.thirds ?? 0;

    final winRate = totalRaces > 0
        ? (wins / totalRaces * 100).toStringAsFixed(1)
        : '0';
    final placeRate = totalRaces > 0
        ? ((wins + seconds + thirds) / totalRaces * 100).toStringAsFixed(1)
        : '0';

    return Obx(() {
      final isExpanded = controller.bulletinExpandedIndex.value == fallbackIndex;

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
                padding: EdgeInsets.all(14.w),
                child: Row(
                  children: [
                    Container(
                      width: 32.w,
                      height: 32.w,
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
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            horseName.toUpperCase(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 3.h),
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
                      isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      color: Colors.white54,
                      size: 20.sp,
                    ),
                  ],
                ),
              ),
            ),
            if (isExpanded)
              Container(
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.white10)),
                ),
                child: Column(
                  children: [
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        _buildInfoColumn('starts_stat'.tr, '$totalRaces'),
                        _buildInfoColumn('wins_stat'.tr, '$wins'),
                        _buildInfoColumn('seconds_stat'.tr, '$seconds'),
                        _buildInfoColumn('thirds_stat'.tr, '$thirds'),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        _buildInfoColumn('win_rate_stat'.tr, '%$winRate'),
                        _buildInfoColumn('place_rate_stat'.tr, '%$placeRate'),
                        _buildInfoColumn('form_stat'.tr, entry.form ?? 'N/A'),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildInfoColumn(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.white38, fontSize: 10.sp),
          ),
          SizedBox(height: 2.h),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
