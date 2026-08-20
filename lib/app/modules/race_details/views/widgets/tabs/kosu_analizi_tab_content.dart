import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:which_win/app/modules/race_details/controllers/race_details_controller.dart';
import 'package:which_win/data/models/race_details_model.dart';
import 'package:which_win/app/modules/race_details/views/widgets/tabs/atlar_jokeyler_tab_content.dart';

class KosuAnaliziTabContent extends GetView<RaceDetailsController> {
  final RaceDetailsData? details;

  const KosuAnaliziTabContent({super.key, required this.details});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final subTab = controller.selectedKosuAnaliziSubTab.value;
      switch (subTab) {
        case 0:
          return OriginalHorseListView(details: details);
        case 1:
        case 2:
          return buildEnIyiDereceTab(controller);
        case 3:
          return buildSonKosularTab(controller);
        case 4:
          return buildBirinciliklerTab(controller);
        case 5:
          return buildKimKiminleKostuTab(controller);
        case 6:
          return buildKimKimiGectiTab(controller);
        default:
          return const SizedBox.shrink();
      }
    });
  }
}

Widget buildEnIyiDereceTab(RaceDetailsController controller) {
  final details = controller.raceDetails.value;
  final entries = details?.entries ?? [];

  if (entries.isEmpty) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Text(
          'no_data_available'.tr,
          style: TextStyle(color: Colors.white60, fontSize: 14.sp),
        ),
      ),
    );
  }

  return ListView.builder(
    padding: EdgeInsets.all(12.w),
    itemCount: entries.length,
    itemBuilder: (context, index) {
      final entry = entries[index];
      final horseName = entry.horse?.name ?? 'Horse ${index + 1}';
      final jockeyName = entry.jockey?.name ?? 'N/A';
      final weight = entry.weight != null ? '${entry.weight} kg' : 'N/A';
      final hp = entry.horsePower?.toInt() ?? entry.normalizedScore?.toInt() ?? 0;
      final pos = entry.rank != null ? '${entry.rank}' : '${index + 1}';

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
                pos,
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

Widget buildSonKosularTab(RaceDetailsController controller) {
  final details = controller.raceDetails.value;
  final entries = details?.entries ?? [];

  if (entries.isEmpty) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Text(
          'no_data_available'.tr,
          style: TextStyle(color: Colors.white60, fontSize: 14.sp),
        ),
      ),
    );
  }

  return ListView.builder(
    padding: EdgeInsets.all(12.w),
    itemCount: entries.length,
    itemBuilder: (context, index) {
      final entry = entries[index];
      final horseName = entry.horse?.name ?? 'Horse ${index + 1}';
      final jockeyName = entry.jockey?.name ?? 'N/A';
      final weight = entry.weight != null ? '${entry.weight} kg' : 'N/A';
      final lastRun = entry.lastRun != null ? '${entry.lastRun} days ago' : 'N/A';

      return Container(
        margin: EdgeInsets.only(bottom: 12.h),
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
                '${index + 1}',
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
                    horseName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    '${'jockey_label'.tr}: $jockeyName · ${'weight_label'.tr}: $weight · ${'last_run_label'.tr}: $lastRun',
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

Widget buildFilterDropdown(String label) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
    decoration: BoxDecoration(
      color: const Color(0xFF1E222B),
      borderRadius: BorderRadius.circular(4.r),
      border: Border.all(color: Colors.white24),
    ),
    child: Row(
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.white, fontSize: 12.sp),
        ),
        SizedBox(width: 4.w),
        Icon(Icons.keyboard_arrow_down, color: Colors.white70, size: 14.sp),
      ],
    ),
  );
}

Widget buildBirinciliklerTab(RaceDetailsController controller) {
  final details = controller.raceDetails.value;
  final entries = details?.entries ?? [];

  if (entries.isEmpty) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Text(
          'no_data_available'.tr,
          style: TextStyle(color: Colors.white60, fontSize: 14.sp),
        ),
      ),
    );
  }

  return ListView.builder(
    padding: EdgeInsets.all(12.w),
    itemCount: entries.length,
    itemBuilder: (context, index) {
      final entry = entries[index];
      final horseName = entry.horse?.name ?? 'Horse ${index + 1}';
      final jockeyName = entry.jockey?.name ?? 'N/A';
      final weight = entry.weight != null ? '${entry.weight} kg' : 'N/A';

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
                '${index + 1}',
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
                    horseName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    '${'jockey_label'.tr}: $jockeyName · ${'weight_label'.tr}: $weight',
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

Widget buildKimKiminleKostuTab(RaceDetailsController controller) {
  final details = controller.raceDetails.value;
  final entries = details?.entries ?? [];

  if (entries.isEmpty) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Text(
          'no_data_available'.tr,
          style: TextStyle(color: Colors.white60, fontSize: 14.sp),
        ),
      ),
    );
  }

  return ListView.builder(
    padding: EdgeInsets.all(12.w),
    itemCount: entries.length,
    itemBuilder: (context, index) {
      final entry = entries[index];
      final horseName = entry.horse?.name ?? 'Horse ${index + 1}';
      final jockeyName = entry.jockey?.name ?? 'N/A';
      final weight = entry.weight != null ? '${entry.weight} kg' : 'N/A';
      final pos = entry.rank != null ? '${entry.rank}' : '${index + 1}';

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
                pos,
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
                    horseName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    '${'jockey_label'.tr}: $jockeyName · ${'weight_label'.tr}: $weight',
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

Widget buildKimKimiGectiTab(RaceDetailsController controller) {
  final details = controller.raceDetails.value;
  final entries = details?.entries ?? [];

  if (entries.isEmpty) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Text(
          'no_data_available'.tr,
          style: TextStyle(color: Colors.white60, fontSize: 14.sp),
        ),
      ),
    );
  }

  return ListView.builder(
    padding: EdgeInsets.all(12.w),
    itemCount: entries.length,
    itemBuilder: (context, index) {
      final entry = entries[index];
      final horseName = entry.horse?.name ?? 'Horse ${index + 1}';
      final jockeyName = entry.jockey?.name ?? 'N/A';
      final pos = entry.rank != null ? '${entry.rank}' : '${index + 1}';

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
                pos,
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
                    horseName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    '${'jockey_label'.tr}: $jockeyName',
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
