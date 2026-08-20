import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:which_win/app/modules/race_details/controllers/race_details_controller.dart';

class RaceDetailsSubTabBar extends GetView<RaceDetailsController> {
  const RaceDetailsSubTabBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF121418),
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Obx(() {
        final currentTab = controller.selectedTab.value;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildSubTabItem('statistics_tab'.tr, 0, currentTab),
            _buildSubTabItem('analysis_tab'.tr, 1, currentTab),
            _buildSubTabItem('prediction_tab'.tr, 2, currentTab),
            _buildSubTabItem('result_tab'.tr, 3, currentTab),
          ],
        );
      }),
    );
  }

  Widget _buildSubTabItem(String label, int index, int selectedIndex) {
    final isSelected = index == selectedIndex;
    return GestureDetector(
      onTap: () => controller.setTab(index),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? const Color(0xFF10B981) : Colors.transparent,
              width: 2.0,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFF10B981) : Colors.white54,
            fontSize: 13.sp,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

class InnerMainTabBar extends GetView<RaceDetailsController> {
  const InnerMainTabBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1E222B),
      child: Obx(() {
        final currentMainTab = controller.selectedMainTab.value;
        return Row(
          children: [
            _buildInnerMainTabItem('race_analysis_tab'.tr, 0, currentMainTab),
            _buildInnerMainTabItem('horses_tab'.tr, 1, currentMainTab),
            _buildInnerMainTabItem('jockeys_tab'.tr, 2, currentMainTab),
          ],
        );
      }),
    );
  }

  Widget _buildInnerMainTabItem(String label, int index, int selectedIndex) {
    final isSelected = index == selectedIndex;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          controller.selectedMainTab.value = index;
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? const Color(0xFF10B981) : Colors.transparent,
                width: 2.0,
              ),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFF10B981) : Colors.white60,
              fontSize: 13.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class KosuAnaliziInnerSubTabBar extends GetView<RaceDetailsController> {
  const KosuAnaliziInnerSubTabBar({super.key});

  @override
  Widget build(BuildContext context) {
    final subTabs = [
      'horse_list_tab'.tr,
      'gallops_sprints_tab'.tr,
      'best_degree_tab'.tr,
      'last_races_tab'.tr,
      'first_places_tab'.tr,
      'who_ran_with_whom_tab'.tr,
      'who_beat_whom_tab'.tr,
    ];

    return Container(
      height: 42.h,
      color: const Color(0xFF121418),
      child: Obx(() {
        final currentSubTab = controller.selectedKosuAnaliziSubTab.value;
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          itemCount: subTabs.length,
          itemBuilder: (context, index) {
            final isSelected = index == currentSubTab;
            return GestureDetector(
              onTap: () {
                controller.selectedKosuAnaliziSubTab.value = index;
              },
              child: Container(
                margin: EdgeInsets.only(right: 6.w),
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF10B981).withValues(alpha: 0.15)
                      : const Color(0xFF1E222B),
                  borderRadius: BorderRadius.circular(6.r),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF10B981)
                        : Colors.white12,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  subTabs[index],
                  style: TextStyle(
                    color: isSelected
                        ? const Color(0xFF10B981)
                        : Colors.white70,
                    fontSize: 11.sp,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

class AtlarInnerSubTabBar extends GetView<RaceDetailsController> {
  const AtlarInnerSubTabBar({super.key});

  @override
  Widget build(BuildContext context) {
    final subTabs = [
      'horses_tab'.tr,
      'mares_tab'.tr,
      'stallions_tab'.tr,
      'dam_sires_tab'.tr,
    ];

    return Container(
      height: 42.h,
      color: const Color(0xFF121418),
      child: Obx(() {
        final currentSubTab = controller.selectedAtlarSubTab.value;
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          itemCount: subTabs.length,
          itemBuilder: (context, index) {
            final isSelected = index == currentSubTab;
            return GestureDetector(
              onTap: () {
                controller.selectedAtlarSubTab.value = index;
              },
              child: Container(
                margin: EdgeInsets.only(right: 6.w),
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF10B981).withValues(alpha: 0.15)
                      : const Color(0xFF1E222B),
                  borderRadius: BorderRadius.circular(6.r),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF10B981)
                        : Colors.white12,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  subTabs[index],
                  style: TextStyle(
                    color: isSelected
                        ? const Color(0xFF10B981)
                        : Colors.white70,
                    fontSize: 11.sp,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

class JokeylerInnerSubTabBar extends GetView<RaceDetailsController> {
  const JokeylerInnerSubTabBar({super.key});

  @override
  Widget build(BuildContext context) {
    final subTabs = ['jockeys_tab'.tr, 'apprentices_tab'.tr];

    return Container(
      height: 42.h,
      color: const Color(0xFF121418),
      child: Obx(() {
        final currentSubTab = controller.selectedJokeylerSubTab.value;
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          itemCount: subTabs.length,
          itemBuilder: (context, index) {
            final isSelected = index == currentSubTab;
            return GestureDetector(
              onTap: () {
                controller.selectedJokeylerSubTab.value = index;
              },
              child: Container(
                margin: EdgeInsets.only(right: 6.w),
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF10B981).withValues(alpha: 0.15)
                      : const Color(0xFF1E222B),
                  borderRadius: BorderRadius.circular(6.r),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF10B981)
                        : Colors.white12,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  subTabs[index],
                  style: TextStyle(
                    color: isSelected
                        ? const Color(0xFF10B981)
                        : Colors.white70,
                    fontSize: 11.sp,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
