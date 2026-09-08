import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:which_win/app/modules/race_details/controllers/race_details_controller.dart';
import 'package:which_win/core/utils/helpers.dart';
import 'package:which_win/data/models/race_details_model.dart';

class BulletinTabContent extends GetView<RaceDetailsController> {
  final RaceDetailsData details;

  const BulletinTabContent({super.key, required this.details});

  @override
  Widget build(BuildContext context) {
    final results = details.results ?? [];
    final entries = details.entries ?? [];

    if (results.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(32.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: const Color(0xFF181B22),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white10),
                ),
                child: Icon(
                  Icons.emoji_events_outlined,
                  color: const Color(0xFFD4AF37),
                  size: 36.sp,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'race_not_resulted_yet'.tr == 'race_not_resulted_yet'
                    ? (Get.locale?.languageCode == 'tr'
                        ? 'Yarış Henüz Sonuçlanmadı'
                        : 'Race Not Resulted Yet')
                    : 'race_not_resulted_yet'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                'results_will_appear_after_finish'.tr ==
                        'results_will_appear_after_finish'
                    ? (Get.locale?.languageCode == 'tr'
                        ? 'Resmi sonuçlar yarış tamamlandıktan sonra burada görüntülenecektir.'
                        : 'Official results will appear here once the race is completed.')
                    : 'results_will_appear_after_finish'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Sort results strictly by finishing position from API
    final sortedResults = [...results];
    sortedResults.sort(
      (a, b) => (a.position ?? 999).compareTo(b.position ?? 999),
    );

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      itemCount: sortedResults.length,
      itemBuilder: (context, index) {
        final result = sortedResults[index];
        final matchingEntry = entries.firstWhereOrNull(
          (e) =>
              e.horseId == result.horse?.id ||
              e.horse?.name?.toLowerCase() ==
                  result.horse?.name?.toLowerCase(),
        );

        return ResultHorseCard(
          result: result,
          matchingEntry: matchingEntry,
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
    final horseName =
        result.horse?.name ?? matchingEntry?.horse?.name ?? 'Unknown Horse';
    final clothNumber =
        result.number ??
        matchingEntry?.number ??
        matchingEntry?.draw ??
        position;

    final jockeyName =
        result.jockey?.name ?? matchingEntry?.jockeyName ?? 'N/A';
    final hp =
        result.or ??
        result.rpr ??
        (matchingEntry?.horsePower != null
            ? matchingEntry!.horsePower!.toStringAsFixed(0)
            : '-');
    final weight = Helpers.formatWeight(
      result.weight ?? matchingEntry?.weight,
      showBoth: true,
    );
    final timeStr =
        (result.time != null && result.time!.isNotEmpty && result.time != 'N/A')
        ? result.time!
        : '-';
    final margin =
        result.btn ?? result.ovrBtn ?? (position == 1 ? 'KAZANDI' : '-');
    final odds =
        result.sp ?? matchingEntry?.winOddsFair?.toStringAsFixed(2) ?? '-';

    Color posBgColor;
    Color posTextColor = Colors.black;
    if (position == 1) {
      posBgColor = const Color(0xFFD4AF37);
    } else if (position == 2) {
      posBgColor = const Color(0xFF94A3B8);
    } else if (position == 3) {
      posBgColor = const Color(0xFFA86D3C);
      posTextColor = Colors.white;
    } else {
      posBgColor = const Color(0xFF252A36);
      posTextColor = Colors.white60;
    }

    final activeHorse = result.horse ?? matchingEntry?.horse;
    final age = activeHorse?.age != null ? '${activeHorse!.age}yo' : '';
    final color = activeHorse?.color ?? '';
    final sex = activeHorse?.sex ?? '';

    return Obx(() {
      final isExpanded =
          controller.bulletinExpandedIndex.value == fallbackIndex;

      return Container(
        margin: EdgeInsets.only(bottom: 10.h),
        decoration: BoxDecoration(
          color: const Color(0xFF181B22),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isExpanded
                ? const Color(0xFFD4AF37).withOpacity(0.4)
                : Colors.white10,
            width: isExpanded ? 1.1 : 1.0,
          ),
        ),
        child: Column(
          children: [
            GestureDetector(
              onTap: () => controller.toggleBulletinExpand(fallbackIndex),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: EdgeInsets.all(12.w),
                child: Row(
                  children: [
                    // Position Badge
                    Container(
                      width: 26.w,
                      height: 26.w,
                      decoration: BoxDecoration(
                        color: posBgColor,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$position',
                        style: TextStyle(
                          color: posTextColor,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),

                    // Cloth Number Badge (Sleek Dark Chip)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 7.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF252A36),
                        borderRadius: BorderRadius.circular(6.r),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.08),
                        ),
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

                    // Horse Name & Subtitle
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
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            '$age $color $sex · $weight · ${'jockey_label'.tr}: $jockeyName'
                                .trim()
                                .replaceAll(RegExp(r'\s+'), ' '),
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 11.sp,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: Colors.white38,
                      size: 20.sp,
                    ),
                  ],
                ),
              ),
            ),

            // Expanded Detail Grid: JOKEY | HP | KG | DERECE | FARK | ORAN
            if (isExpanded)
              Container(
                padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 12.h),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.white.withOpacity(0.06)),
                  ),
                ),
                child: Column(
                  children: [
                    SizedBox(height: 10.h),
                    Row(
                      children: [
                        _buildResultStatCell(
                          'jockey_short'.tr,
                          jockeyName,
                          flex: 3,
                        ),
                        _buildResultStatCell('hp_short'.tr, hp, flex: 1),
                        _buildResultStatCell('kg_short'.tr, weight, flex: 2),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        _buildResultStatCell(
                          'derece_label'.tr,
                          timeStr,
                          flex: 3,
                        ),
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
        padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: const Color(0xFF121418),
          borderRadius: BorderRadius.circular(6.r),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white38,
                fontSize: 9.sp,
                fontWeight: FontWeight.w600,
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
