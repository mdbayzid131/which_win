import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:which_win/app/modules/race_details/controllers/race_details_controller.dart';
import 'package:which_win/data/models/race_details_model.dart';
import 'package:which_win/core/utils/helpers.dart';
import 'package:which_win/app/modules/race_details/views/widgets/common/premium_lock_overlay.dart';

class OriginalHorseListView extends GetView<RaceDetailsController> {
  final RaceDetailsData? details;

  const OriginalHorseListView({super.key, required this.details});

  @override
  Widget build(BuildContext context) {
    final rawEntries = details?.entries ?? [];
    if (rawEntries.isEmpty) {
      return const Center(
        child: Text(
          'No horses registered',
          style: TextStyle(color: Colors.white60),
        ),
      );
    }
    final entries = List<RaceEntry>.from(rawEntries)
      ..sort((a, b) {
        final aNum = (a.number != null && a.number! > 0) ? a.number! : 999;
        final bNum = (b.number != null && b.number! > 0) ? b.number! : 999;
        return aNum.compareTo(bNum);
      });
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        final score = entry.normalizedScore?.toInt() ?? 0;

        Color scoreColor = Colors.orange;
        if (score >= 70) {
          scoreColor = const Color(0xFF268060);
        } else if (score < 50) {
          scoreColor = Colors.red;
        }

        return TurkeyStyleHorseCard(
          index: index,
          entry: entry,
          scoreColor: scoreColor,
        );
      },
    );
  }
}

class AtlarContent extends GetView<RaceDetailsController> {
  final RaceDetailsData? details;

  const AtlarContent({super.key, required this.details});

  @override
  Widget build(BuildContext context) {
    final rawEntries = details?.entries ?? [];

    if (rawEntries.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Text(
            'no_data_available'.tr,
            style: TextStyle(color: Colors.white70, fontSize: 14.sp),
          ),
        ),
      );
    }

    final entries = List<RaceEntry>.from(rawEntries)
      ..sort((a, b) {
        final aNum = a.number ?? 999;
        final bNum = b.number ?? 999;
        return aNum.compareTo(bNum);
      });

    return ListView.builder(
      padding: EdgeInsets.all(12.w),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        final horseName = entry.horse?.name ?? 'Horse ${index + 1}';
        final jockeyName = entry.jockey?.name ?? 'N/A';
        final String weight = Helpers.formatWeight(
          entry.weight,
          showBoth: true,
        );
        final hp = (entry.horsePower != null && entry.horsePower! > 0)
            ? entry.horsePower!.toInt()
            : ((entry.normalizedScore != null && entry.normalizedScore! > 0)
                  ? entry.normalizedScore!.toInt()
                  : ((entry.rawScore != null && entry.rawScore! > 0)
                        ? entry.rawScore!.toInt()
                        : ((entry.pedigreePower != null &&
                                  entry.pedigreePower! > 0)
                              ? entry.pedigreePower!.toInt()
                              : 0)));
        final pos = (entry.number != null && entry.number! > 0)
            ? entry.number!
            : ((entry.draw != null && entry.draw! > 0) ? entry.draw! : (index + 1));

        return Container(
          margin: EdgeInsets.only(bottom: 10.h),
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: const Color(0xFF1E222B),
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: Colors.white12),
          ),
          child: Row(
            children: [
              Container(
                width: 30.w,
                height: 30.w,
                decoration: BoxDecoration(
                  color: const Color(0xFF252A36),
                  borderRadius: BorderRadius.circular(6.r),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                alignment: Alignment.center,
                child: Text(
                  '$pos',
                  style: TextStyle(
                    color: const Color(0xFFD4AF37),
                    fontSize: 13.sp,
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
                      horseName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      '${'jockey_label'.tr}: $jockeyName · ${'weight_label'.tr}: $weight · HP: $hp',
                      style: TextStyle(color: Colors.white70, fontSize: 11.sp),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class JokeylerContent extends GetView<RaceDetailsController> {
  final RaceDetailsData? details;

  const JokeylerContent({super.key, required this.details});

  @override
  Widget build(BuildContext context) {
    final rawEntries = details?.entries ?? [];

    if (rawEntries.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Text(
            'no_data_available'.tr,
            style: TextStyle(color: Colors.white70, fontSize: 14.sp),
          ),
        ),
      );
    }

    final sortedEntries = List<RaceEntry>.from(rawEntries)
      ..sort((a, b) {
        final aNum = (a.number != null && a.number! > 0)
            ? a.number!
            : ((a.draw != null && a.draw! > 0) ? a.draw! : 999);
        final bNum = (b.number != null && b.number! > 0)
            ? b.number!
            : ((b.draw != null && b.draw! > 0) ? b.draw! : 999);
        return aNum.compareTo(bNum);
      });

    return Obx(() {
      final subTab = controller.selectedJokeylerSubTab.value;
      List<RaceEntry> displayList = sortedEntries;

      if (subTab == 1) {
        final appList = sortedEntries.where((e) {
          final jName = e.jockey?.name?.toLowerCase() ?? '';
          final hGear = e.headgear?.toLowerCase() ?? '';
          return jName.startsWith('ap ') ||
              jName.contains('(ap)') ||
              hGear.contains('ap');
        }).toList();
        if (appList.isNotEmpty) {
          displayList = appList;
        }
      }

      if (displayList.isEmpty) {
        return Center(
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Text(
              'no_data_available'.tr,
              style: TextStyle(color: Colors.white70, fontSize: 14.sp),
            ),
          ),
        );
      }

      return ListView.builder(
        padding: EdgeInsets.all(12.w),
        itemCount: displayList.length,
        itemBuilder: (context, index) {
          final entry = displayList[index];
          final jockeyName =
              entry.jockey?.name ?? '${'jockey_label'.tr} ${index + 1}';
          final horseName = entry.horse?.name ?? 'N/A';
          final String weight = Helpers.formatWeight(
            entry.weight,
            showBoth: true,
          );
          final pos = (entry.number != null && entry.number! > 0)
              ? entry.number!
              : ((entry.draw != null && entry.draw! > 0) ? entry.draw! : (index + 1));

          return Container(
            margin: EdgeInsets.only(bottom: 10.h),
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: const Color(0xFF1E222B),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              children: [
                Container(
                  width: 32.w,
                  height: 32.w,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$pos',
                    style: TextStyle(
                      color: Colors.black,
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
                        jockeyName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        '${'horse_label'.tr}: $horseName • ${'weight_label'.tr}: $weight',
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
          );
        },
      );
    });
  }
}

class TurkeyStyleHorseCard extends GetView<RaceDetailsController> {
  final int index;
  final RaceEntry entry;
  final Color scoreColor;

  const TurkeyStyleHorseCard({
    super.key,
    required this.index,
    required this.entry,
    required this.scoreColor,
  });

  @override
  Widget build(BuildContext context) {
    final horse = entry.horse;
    final horseName = horse?.name ?? 'Unknown Horse';
    final jockeyName = entry.jockeyName ?? 'Unknown Jockey';
    final trainerName = entry.trainerName ?? 'N/A';
    final age = horse?.age != null ? '${horse!.age}y' : 'N/A';
    final color = horse?.color ?? 'd';
    final sex = horse?.sex ?? 'k';

    // Format weight displaying both KG and LBS (e.g. "59 kg (130 lbs)")
    final String weightText = Helpers.formatWeight(
      entry.weight,
      showBoth: true,
    );

    // Left badge shows horse / saddle cloth number
    final saddleNumber = (entry.number != null && entry.number! > 0)
        ? entry.number!
        : (index + 1);
    final gateNumber = (entry.draw != null && entry.draw! > 0)
        ? entry.draw!
        : saddleNumber;

    final earnings = horse?.totalEarnings;
    final earningsText = (earnings != null && earnings > 0)
        ? 'Earnings: ${Helpers.formatCurrency(earnings)}'
        : 'Earnings: N/A';

    final stVal = gateNumber;
    final kgsVal = entry.lastRun ?? '-';

    // Fallback HP score resolution
    final int hpVal = (entry.horsePower != null && entry.horsePower! > 0)
        ? entry.horsePower!.toInt()
        : ((entry.normalizedScore != null && entry.normalizedScore! > 0)
              ? entry.normalizedScore!.toInt()
              : ((entry.rawScore != null && entry.rawScore! > 0)
                    ? entry.rawScore!.toInt()
                    : ((entry.pedigreePower != null && entry.pedigreePower! > 0)
                          ? entry.pedigreePower!.toInt()
                          : 0)));

    final equipmentText = entry.headgear ?? '';
    final bool isApprentice = jockeyName.toLowerCase().startsWith('ap ');
    final displayJockeyName = isApprentice
        ? jockeyName.substring(3).trim()
        : jockeyName;

    return Obx(() {
      final isExpanded = controller.expandedIndex.value == index;

      return Container(
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
          color: const Color(0xFF1E222B),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isExpanded ? Colors.white38 : Colors.white24,
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            GestureDetector(
              onTap: () => controller.toggleExpand(index),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: EdgeInsets.all(12.w),
                child: Row(
                  children: [
                    // Horse / Saddle Number badge
                    Container(
                      width: 36.w,
                      height: 36.w,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: Colors.white24),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$saddleNumber',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    buildJockeySilkIcon(index),
                    SizedBox(width: 10.w),
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
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (equipmentText.isNotEmpty) ...[
                                SizedBox(width: 6.w),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 6.w,
                                    vertical: 2.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white12,
                                    borderRadius: BorderRadius.circular(4.r),
                                  ),
                                  child: Text(
                                    equipmentText,
                                    style: TextStyle(
                                      color: const Color(0xFF10B981),
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          SizedBox(height: 3.h),
                          Text(
                            '$age $color $sex · $weightText${earnings != null && earnings > 0 ? " · ${Helpers.formatCurrency(earnings)}" : ""}',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12.sp,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Row(
                            children: [
                              Text(
                                displayJockeyName,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (isApprentice) ...[
                                SizedBox(width: 4.w),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 4.w,
                                    vertical: 1.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(3.r),
                                  ),
                                  child: Text(
                                    'AP',
                                    style: TextStyle(
                                      color: Colors.amber,
                                      fontSize: 9.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF10B981,
                            ).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6.r),
                            border: Border.all(
                              color: const Color(
                                0xFF10B981,
                              ).withValues(alpha: 0.5),
                            ),
                          ),
                          child: Text(
                            '$hpVal HP',
                            style: TextStyle(
                              color: const Color(0xFF10B981),
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Row(
                          children: [
                            Text(
                              'ST:$stVal  KGS:$kgsVal',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Icon(
                              isExpanded
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              color: Colors.white70,
                              size: 16.sp,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (isExpanded)
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: const BoxDecoration(
                  color: Color(0xFF161920),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(12),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(color: Colors.white12, height: 1),
                    SizedBox(height: 10.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Trainer: $trainerName',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12.sp,
                          ),
                        ),
                        Text(
                          earningsText,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        minimumSize: Size(double.infinity, 36.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      onPressed: () {
                        if (horse?.id != null) {
                          controller.fetchHorseProfile(horse!.id!);
                        }
                        showHorseDetails(
                          context,
                          horseName,
                          hpVal,
                          controller,
                          entry: entry,
                        );
                      },
                      child: Text(
                        'View Full Profile',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
    });
  }
}

Widget buildJockeySilkIcon(int index) {
  final sets = [
    [const Color(0xFFEF4444), const Color(0xFF3B82F6)],
    [const Color(0xFFF59E0B), const Color(0xFF10B981)],
    [const Color(0xFF8B5CF6), const Color(0xFFEC4899)],
    [const Color(0xFF06B6D4), const Color(0xFF84CC16)],
  ];
  final colors = sets[index % sets.length];

  return Container(
    width: 32.w,
    height: 32.w,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: colors,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      shape: BoxShape.circle,
      border: Border.all(color: Colors.white38, width: 1.5),
    ),
    child: Icon(Icons.sports_score, size: 16.sp, color: Colors.white),
  );
}
