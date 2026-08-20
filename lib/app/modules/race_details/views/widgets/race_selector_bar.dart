import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:which_win/app/modules/race_details/controllers/race_details_controller.dart';
import 'package:which_win/data/models/race_details_model.dart';
import 'package:which_win/data/models/race_model.dart';

class RaceSelectorBar extends GetView<RaceDetailsController> {
  const RaceSelectorBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final races = controller.siblingRaces;
      if (races.isEmpty) {
        return const SizedBox.shrink();
      }

      return Container(
        height: 62.h,
        color: const Color(0xFF121418),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          itemCount: races.length,
          itemBuilder: (context, index) {
            final sibling = races[index];
            final current = controller.race.value;
            final isSelected =
                (sibling.id != null && sibling.id == current?.id) ||
                (sibling.name != null && sibling.name == current?.name);
            final timeStr = sibling.time ?? '14:30';

            return _buildRaceSelectorTab(
              isSelected: isSelected,
              title: '${index + 1}.\n${'race_unit'.tr}',
              time: timeStr,
              onTap: () => controller.selectSiblingRace(sibling),
            );
          },
        ),
      );
    });
  }

  Widget _buildRaceSelectorTab({
    required bool isSelected,
    required String title,
    required String time,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 70.w,
        margin: EdgeInsets.symmetric(horizontal: 3.w),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF10B981) : const Color(0xFF1E222B),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isSelected ? const Color(0xFF10B981) : Colors.white24,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white70,
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
            height: 1.3,
          ),
        ),
      ),
    );
  }
}

class SelectedRaceDetailsBanner extends StatelessWidget {
  final RaceDetailsData? details;
  final RaceModel? currentRace;

  const SelectedRaceDetailsBanner({
    super.key,
    required this.details,
    required this.currentRace,
  });

  @override
  Widget build(BuildContext context) {
    final timeVal = details?.time ?? currentRace?.time ?? '';
    final distanceVal = details?.distance ?? currentRace?.distance ?? '';
    final trackType = details?.trackType ?? currentRace?.trackType ?? 'Turf';
    final surface = details?.surface ?? currentRace?.surface;
    final isTurf =
        trackType.toLowerCase().contains('turf') ||
        trackType.toLowerCase().contains('çim');
    final surfaceStr = (surface != null && surface.isNotEmpty)
        ? surface
        : (isTurf ? 'Turf' : 'Dirt');
    final raceName = details?.name ?? currentRace?.name ?? 'Race Details';
    final prize = details?.prize ?? currentRace?.prize;
    final fieldSize = details?.fieldSize ?? currentRace?.fieldSize;
    final raceType = details?.raceType ?? currentRace?.raceType;
    final ageBand = details?.ageBand ?? currentRace?.ageBand;

    final bool hasPrize = prize != null && prize.isNotEmpty && prize != 'N/A';

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF1E222B),
        border: Border(
          top: BorderSide(color: Colors.white24),
          bottom: BorderSide(color: Colors.white24),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Race Name / Title
          Text(
            raceName,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 8.h),

          // Metadata Badges Row
          Wrap(
            spacing: 8.w,
            runSpacing: 6.h,
            children: [
              if (timeVal.isNotEmpty)
                _buildInfoChip(
                  icon: Icons.access_time_rounded,
                  label: timeVal,
                  iconColor: const Color(0xFF10B981),
                ),
              if (distanceVal.isNotEmpty)
                _buildInfoChip(
                  icon: Icons.straighten_rounded,
                  label: distanceVal,
                  iconColor: const Color(0xFF10B981),
                ),
              _buildInfoChip(
                icon: isTurf ? Icons.grass_rounded : Icons.landscape_rounded,
                label: surfaceStr,
                iconColor: isTurf
                    ? const Color(0xFF4ADE80)
                    : const Color(0xFFFBBF24),
              ),
              if (fieldSize != null && fieldSize > 0)
                _buildInfoChip(
                  icon: Icons.groups_rounded,
                  label: '$fieldSize Runners',
                  iconColor: const Color(0xFF10B981),
                ),
              if (hasPrize)
                _buildInfoChip(
                  icon: Icons.emoji_events_rounded,
                  label: prize,
                  iconColor: const Color(0xFFFFC107),
                  bgColor: const Color(0xFF29210C),
                  textColor: const Color(0xFFFFC107),
                  borderColor: const Color(0xFFFFC107).withValues(alpha: 0.4),
                ),
              if (raceType != null && raceType.isNotEmpty)
                _buildInfoChip(
                  icon: Icons.sports_score_rounded,
                  label: raceType,
                  iconColor: Colors.white.withValues(alpha: 0.9),
                  bgColor: Colors.white.withValues(alpha: 0.08),
                  textColor: Colors.white,
                ),
              if (ageBand != null && ageBand.isNotEmpty)
                _buildInfoChip(
                  icon: Icons.info_outline_rounded,
                  label: ageBand,
                  iconColor: Colors.white.withValues(alpha: 0.9),
                  bgColor: Colors.white.withValues(alpha: 0.08),
                  textColor: Colors.white,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    Color iconColor = const Color(0xFF10B981),
    Color bgColor = const Color(0xFF1E222B),
    Color textColor = Colors.white,
    Color? borderColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: borderColor ?? Colors.white24, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.sp, color: iconColor),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 11.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
