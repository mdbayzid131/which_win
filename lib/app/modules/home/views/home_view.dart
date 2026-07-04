import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:which_win/app/modules/home/controllers/home_controller.dart';
import 'package:which_win/app/modules/calendar/controllers/calendar_controller.dart';
import 'package:which_win/app/modules/rate_us/controllers/rate_us_controller.dart';
import 'package:which_win/app/routes/app_pages.dart';
import 'package:which_win/data/models/race_model.dart';
import 'package:which_win/core/services/storage_service.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  // Image Assets Variables
  static const String logoPath = 'assets/images/logo.png';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      drawer: _buildDrawer(context),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(
          'BULLETIN',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        actions: [
          // LIVE filter button — pulses red when active
          Obx(() {
            final isLive = controller.isLiveFilterActive.value;
            return GestureDetector(
              onTap: controller.toggleLiveFilter,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.h),
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: isLive
                      ? Colors.red.withOpacity(0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: isLive
                        ? Colors.red.withOpacity(0.6)
                        : Colors.transparent,
                  ),
                  boxShadow: isLive
                      ? [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.35),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ]
                      : [],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.settings_input_antenna,
                      color: isLive ? Colors.red : Colors.white54,
                      size: 20.sp,
                    ),
                    if (isLive) ...[
                      SizedBox(width: 4.w),
                      Text(
                        'LIVE',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
          IconButton(
            icon: const Icon(
              Icons.calendar_today_outlined,
              color: Colors.white,
            ),
            onPressed: () => _showCalendarPopup(context),
          ),
          IconButton(
            icon: const Icon(Icons.tune, color: Colors.white),
            onPressed: () => _showFilterPopup(context),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // ── LIVE Filter Banner ────────────────────────────────────────────
            Obx(() {
              if (!controller.isLiveFilterActive.value) {
                return const SizedBox.shrink();
              }
              return Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.red.withOpacity(0.18),
                      Colors.red.withOpacity(0.05),
                    ],
                  ),
                  border: const Border(
                    bottom: BorderSide(color: Colors.red, width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.4, end: 1.0),
                      duration: const Duration(milliseconds: 700),
                      curve: Curves.easeInOut,
                      builder: (ctx, v, ch) => Opacity(opacity: v, child: ch),
                      onEnd: () {},
                      child: Container(
                        width: 8.w,
                        height: 8.w,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.7),
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Text(
                      'live_races'.tr,
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: controller.toggleLiveFilter,
                      child: Icon(
                        Icons.close,
                        size: 20.sp,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              );
            }),
            // Search Bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Container(
                height: 50.h,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.white12),
                ),
                child: TextField(
                  style: const TextStyle(color: Colors.white),
                  onChanged: controller.searchRaces,
                  decoration: InputDecoration(
                    hintText: 'search_country'.tr,
                    hintStyle: TextStyle(
                      color: Colors.white38,
                      fontSize: 16.sp,
                    ),
                    prefixIcon: const Icon(Icons.search, color: Colors.white38),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                ),
              ),
            ),
            // Categories
            SizedBox(
              height: 40.h,
              child: Obx(() {
                final selectedCategory = controller.selectedCategory.value;
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  itemCount: controller.categories.length,
                  itemBuilder: (context, index) {
                    final category = controller.categories[index];
                    final isSelected = selectedCategory == category;
                    return GestureDetector(
                      onTap: () => controller.selectCategory(category),
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 4.w),
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFFF6600)
                              : const Color(0xFF1A1A1A),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: isSelected
                                ? Colors.transparent
                                : Colors.white12,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          category == 'All' ? 'all'.tr : category,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
            SizedBox(height: 16.h),
            Expanded(
              child: Obx(() {
                final isLiveFilter = controller.isLiveFilterActive.value;
                final meetings = controller.filteredMeetings;
                final races = controller.raceList;

                if (isLiveFilter) {
                  if (races.isEmpty && !controller.isLoading.value) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.settings_input_antenna,
                            color: Colors.red.withOpacity(0.5),
                            size: 48.sp,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'no_live_races'.tr,
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: 16.sp,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'tap_antenna_hint'.tr,
                            style: TextStyle(
                              color: Colors.white24,
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
                    itemCount: races.length,
                    itemBuilder: (context, index) {
                      final race = races[index];
                      return GestureDetector(
                        onTap: () => Get.toNamed(
                          AppRoutes.RACE_DETAILS,
                          arguments: race,
                        ),
                        child: _buildLiveRaceCard(race),
                      );
                    },
                  );
                }

                if (meetings.isEmpty && !controller.isLoading.value) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.emoji_events_outlined,
                          color: Colors.white24,
                          size: 48.sp,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'no_races_found'.tr,
                          style: TextStyle(
                            color: Colors.white38,
                            fontSize: 16.sp,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  itemCount: meetings.length,
                  itemBuilder: (context, index) {
                    final meeting = meetings[index];
                    final race = {
                      'country': meeting.country,
                      'flag': _getFlagCode(meeting.country),
                      'race': meeting.location,
                      'isLive': meeting.isLive,
                      'racesCount': '${meeting.racesCount} races',
                    };
                    final representativeRace = RaceModel(
                      location: meeting.location,
                      country: meeting.country,
                      date: DateFormat(
                        'yyyy-MM-dd',
                      ).format(controller.selectedDate),
                    );
                    return GestureDetector(
                      onTap: () => Get.toNamed(
                        AppRoutes.RACE_BULLETIN,
                        arguments: representativeRace,
                      ),
                      child: _buildRaceCard(race),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF1E1E1E),
      child: Column(
        children: [
          // Drawer Header with Background Image
          Container(
            height: 220.h,
            width: double.infinity,
            decoration: const BoxDecoration(
              // image: DecorationImage(
              //   image: AssetImage(
              //     'assets/images/premium_race_header.png',
              //   ), // Premium generated background
              //   fit: BoxFit.cover,
              //   opacity: 0.7, // Slightly more visible for the premium image
              color: Colors.transparent,
            ),
            child: Container(
              color: Colors.transparent,
              // decoration: BoxDecoration(
              //   gradient: LinearGradient(
              //     begin: Alignment.topCenter,
              //     end: Alignment.bottomCenter,
              //     colors: [
              //       Colors.black.withOpacity(0.2),
              //       Colors.black.withOpacity(0.8),
              //     ],
              //   ),
              // ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width:
                          280.w, // Increased width so the logo can grow larger
                      height: 160.h, // Increased height to allow scaling
                      // decoration: BoxDecoration(
                      //   boxShadow: [
                      //     BoxShadow(
                      //       color: const Color(0xFF4DB6AC).withOpacity(0.1),
                      //       blurRadius: 30,
                      //       spreadRadius: 10,
                      //     ),
                      //   ],
                      // ),
                      child: Image.asset(
                        logoPath,
                        fit: BoxFit
                            .cover, // Ensures the image scales up to fit the container
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Divider(color: Colors.white12, height: 1),
          // Drawer Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  Icons.emoji_events_outlined,
                  'races'.tr,
                  () => Get.back(),
                ),
                _buildDrawerItem(
                  Icons.notifications_none_outlined,
                  'notifications'.tr,
                  () => Get.toNamed(AppRoutes.NOTIFICATIONS),
                ),
                _buildDrawerItem(
                  Icons.diamond_outlined,
                  'subscription_info'.tr,
                  () => Get.toNamed(AppRoutes.SUBSCRIPTION),
                ),
                _buildDrawerItem(
                  Icons.support_agent_outlined,
                  'contact'.tr,
                  () => Get.toNamed(AppRoutes.CONTACT),
                ),
                _buildDrawerItem(
                  Icons.description_outlined,
                  'terms_conditions'.tr,
                  () => Get.toNamed(AppRoutes.TERMS_CONDITIONS),
                ),
                _buildDrawerItem(
                  Icons.privacy_tip_outlined,
                  'privacy_policy'.tr,
                  () => Get.toNamed(AppRoutes.PRIVACY_POLICY),
                ),
                _buildDrawerItem(
                  Icons.card_giftcard_outlined,
                  'gift_a_friend'.tr,
                  () => Get.toNamed(AppRoutes.GIFT_A_FRIEND),
                  subtitle: 'gift_a_friend_subtitle'.tr,
                ),
                _buildDrawerItem(
                  Icons.thumb_up_alt_outlined,
                  'rate_us'.tr,
                  () {
                    Get.back();
                    _showRateUsDialog(context);
                  },
                ),
                _buildDrawerItem(
                  Icons.translate_outlined,
                  'language'.tr,
                  () => _showLanguageSelectionBottomSheet(),
                ),
              ],
            ),
          ),
          // Drawer Footer
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${'version'.tr} 2.1.8',
                  style: TextStyle(color: Colors.white38, fontSize: 12.sp),
                ),
                Text(
                  'er-1def2-ddoewrf-4324-sd',
                  style: TextStyle(color: Colors.white24, fontSize: 10.sp),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    IconData icon,
    String title,
    VoidCallback onTap, {
    String? subtitle,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF4DB6AC)),
      title: Text(
        title,
        style: TextStyle(color: Colors.white, fontSize: 16.sp),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(color: const Color(0xFF4DB6AC).withOpacity(0.7), fontSize: 11.sp),
            )
          : null,
      trailing: const Icon(Icons.keyboard_arrow_right, color: Colors.white38),
      onTap: onTap,
    );
  }

  void _showRateUsDialog(BuildContext context) {
    final controller = Get.put(RateUsController());
    
    Get.dialog(
      Dialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () {
                    Get.back();
                    Get.delete<RateUsController>();
                  },
                  child: const Icon(Icons.close, color: Colors.white54),
                ),
              ),
              Icon(
                Icons.star_rounded,
                size: 80.sp,
                color: Colors.amber,
              ),
              SizedBox(height: 16.h),
              Text(
                'experience_question'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'feedback_improve_hint'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 14.sp,
                ),
              ),
              SizedBox(height: 24.h),
              Obx(() => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    onPressed: () => controller.setRating(index + 1),
                    icon: Icon(
                      index < controller.rating.value
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      color: index < controller.rating.value
                          ? Colors.amber
                          : Colors.white24,
                      size: 36.sp,
                    ),
                  );
                }),
              )),
              SizedBox(height: 24.h),
              Obx(() {
                final isLoading = controller.isLoading.value;
                return SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : () async {
                      await controller.submitRating();
                      Get.delete<RateUsController>();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00CC99),
                      disabledBackgroundColor: const Color(0xFF00CC99).withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: isLoading
                        ? SizedBox(
                            width: 20.w,
                            height: 20.w,
                            child: const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'submit_rating'.tr,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    ).then((_) {
      if (Get.isRegistered<RateUsController>()) {
        Get.delete<RateUsController>();
      }
    });
  }

  Widget _buildRaceCard(Map<String, dynamic> race) {
    final bool isLive = race['isLive'] as bool;
    final String country = race['country'] as String;
    final String raceName = race['race'] as String;
    final String flagCode = race['flag'] as String;
    final String racesCount = race['racesCount'] as String;

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1419),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Background subtle gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white.withOpacity(0.02), Colors.transparent],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                // Flag with premium styling
                Container(
                  width: 50.w,
                  height: 50.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white24, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.network(
                      'https://flagcdn.com/w160/$flagCode.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[900],
                        child: Icon(
                          Icons.flag,
                          color: Colors.white24,
                          size: 20.sp,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        country,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17.sp,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        raceName,
                        style: TextStyle(
                          color: Colors.white38,
                          fontSize: 14.sp,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                // Status/Info
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (isLive)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF3D1C00), Color(0xFF2D1400)],
                          ),
                          borderRadius: BorderRadius.circular(6.r),
                          border: Border.all(
                            color: const Color(0xFFFF6600).withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6.w,
                              height: 6.w,
                              decoration: const BoxDecoration(
                                color: Color(0xFFFF6600),
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              'LIVE',
                              style: TextStyle(
                                color: const Color(0xFFFF6600),
                                fontSize: 11.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      SizedBox(height: 22.h),
                    SizedBox(height: 12.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            racesCount,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.blueAccent.withOpacity(0.7),
                            size: 10.sp,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveRaceCard(RaceModel race) {
    final String country = race.country ?? 'Unknown';
    final String raceName = race.name ?? 'Race';
    final String location = race.location ?? 'Unknown Course';
    final String flagCode = _getFlagCode(country);
    final String time = race.time ?? '';
    final String distance = race.distance ?? '';
    final String trackType = race.trackType ?? 'Turf';
    final String score = race.tahmin1X ?? '';

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1419),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.red.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.08),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Background subtle gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.red.withOpacity(0.03), Colors.transparent],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Flag
                    Container(
                      width: 44.w,
                      height: 44.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white24, width: 2),
                      ),
                      child: ClipOval(
                        child: Image.network(
                          'https://flagcdn.com/w160/$flagCode.png',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                color: Colors.grey[900],
                                child: Icon(
                                  Icons.flag,
                                  color: Colors.white24,
                                  size: 18.sp,
                                ),
                              ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    // Race course & Time
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            location.toUpperCase(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15.sp,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            '$country • $time',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Live pulsing badge
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6.r),
                        border: Border.all(color: Colors.red.withOpacity(0.6)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6.w,
                            height: 6.w,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            'LIVE',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                const Divider(color: Colors.white10, height: 1),
                SizedBox(height: 12.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            raceName,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            '$trackType · $distance',
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (score.isNotEmpty)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFE65100), Color(0xFFFF8F00)],
                          ),
                          borderRadius: BorderRadius.circular(8.r),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF8F00).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          'AI Score: $score',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCalendarPopup(BuildContext context) {
    final calendarController = Get.find<CalendarController>();

    Get.bottomSheet(
      Container(
        height: 520.h,
        decoration: BoxDecoration(
          color: const Color(0xFF0F1419),
          borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
          border: Border.all(color: Colors.white12),
        ),
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              // Handle
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 24.h),
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Obx(
                    () => Text(
                      DateFormat(
                        'MMMM yyyy',
                      ).format(calendarController.focusedDate.value),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => calendarController.prevMonth(),
                        icon: const Icon(
                          Icons.chevron_left,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        onPressed: () => calendarController.nextMonth(),
                        icon: const Icon(
                          Icons.chevron_right,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              // Week Days
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'].map((day) {
                  return SizedBox(
                    width: 40.w,
                    child: Center(
                      child: Text(
                        day,
                        style: TextStyle(
                          color: Colors.white38,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 16.h),
              // Calendar Grid
              Expanded(
                child: Obx(() {
                  final focusedDate = calendarController.focusedDate.value;
                  final daysInMonth = DateTime(
                    focusedDate.year,
                    focusedDate.month + 1,
                    0,
                  ).day;
                  final firstDayOfWeek = DateTime(
                    focusedDate.year,
                    focusedDate.month,
                    1,
                  ).weekday;

                  return GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 7,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                        ),
                    itemCount: daysInMonth + (firstDayOfWeek - 1),
                    itemBuilder: (context, index) {
                      if (index < firstDayOfWeek - 1) {
                        return const SizedBox();
                      }

                      final day = index - (firstDayOfWeek - 2);
                      final date = DateTime(
                        focusedDate.year,
                        focusedDate.month,
                        day,
                      );
                      final isSelected = DateUtils.isSameDay(
                        date,
                        calendarController.selectedDate.value,
                      );
                      final isToday = DateUtils.isSameDay(date, DateTime.now());

                      return GestureDetector(
                        onTap: () {
                          calendarController.selectDate(date);
                          Get.back(); // Close on selection
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF4DB6AC)
                                : (isToday
                                      ? Colors.white.withOpacity(0.05)
                                      : Colors.transparent),
                            borderRadius: BorderRadius.circular(12.r),
                            border: isToday && !isSelected
                                ? Border.all(
                                    color: const Color(
                                      0xFF4DB6AC,
                                    ).withOpacity(0.5),
                                  )
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '$day',
                            style: TextStyle(
                              color: isSelected ? Colors.black : Colors.white,
                              fontSize: 14.sp,
                              fontWeight: isSelected || isToday
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
              // Footer Action
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF004D40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    'Close',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showFilterPopup(BuildContext context) {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0F1419),
          borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
          border: Border.all(color: Colors.white12),
        ),
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                'filter_races'.tr,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 24.h),

              _buildFilterSection(
                'race_status'.tr,
                ['All', 'Live', 'Upcoming', 'Resulted'],
                controller.selectedStatus,
                (val) => controller.setStatus(val),
              ),

              SizedBox(height: 24.h),

              _buildFilterSection(
                'regions'.tr,
                ['All', 'UK', 'USA', 'Europe', 'Asia', 'Australia'],
                controller.selectedRegion,
                (val) => controller.setRegion(val),
              ),

              SizedBox(height: 40.h),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        controller.resetFilters();
                        Get.back();
                      },
                      child: Text(
                        'reset_all'.tr,
                        style: TextStyle(
                          color: Colors.white38,
                          fontSize: 16.sp,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 50.h,
                      child: ElevatedButton(
                        onPressed: () => Get.back(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF004D40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Text(
                          'apply_filters'.tr,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildFilterSection(
    String title,
    List<String> options,
    RxString selectedValue,
    Function(String) onSelect,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: options.map((option) {
            return Obx(() {
              final isSelected = selectedValue.value == option;
              return GestureDetector(
                onTap: () => onSelect(option),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF4DB6AC)
                        : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF4DB6AC)
                          : Colors.white10,
                    ),
                  ),
                  child: Text(
                    _getTranslatedOption(option),
                    style: TextStyle(
                      color: isSelected ? Colors.black : Colors.white70,
                      fontSize: 14.sp,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              );
            });
          }).toList(),
        ),
      ],
    );
  }

  String _getFlagCode(String country) {
    final c = country.toLowerCase();
    if (c.contains('united kingdom') ||
        c.contains('uk') ||
        c.contains('great britain') ||
        c.contains('gb')) {
      return 'gb';
    }
    if (c.contains('france') || c.contains('fr')) {
      return 'fr';
    }
    if (c.contains('turkey') || c.contains('tr') || c.contains('türkiye')) {
      return 'tr';
    }
    if (c.contains('united states') || c.contains('usa') || c.contains('us')) {
      return 'us';
    }
    if (c.contains('ireland') || c.contains('ie')) {
      return 'ie';
    }
    if (c.contains('australia') || c.contains('au')) {
      return 'au';
    }
    return 'tr';
  }

  String _getTranslatedOption(String option) {
    switch (option.toLowerCase()) {
      case 'all':
        return 'all'.tr;
      case 'live':
        return 'live'.tr;
      case 'upcoming':
        return 'upcoming'.tr;
      case 'resulted':
        return 'resulted'.tr;
      default:
        return option;
    }
  }

  void _showLanguageSelectionBottomSheet() {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: const Color(0xFF0F1419),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          border: Border.all(color: Colors.white12),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                'select_language'.tr,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 24.h),
              _buildLanguageOption('english'.tr, 'en', '🇺🇸'),
              SizedBox(height: 12.h),
              _buildLanguageOption('turkish'.tr, 'tr', '🇹🇷'),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String title, String langCode, String flag) {
    final currentLocale = Get.locale?.languageCode ?? 'en';
    final isSelected = currentLocale == langCode;

    return ListTile(
      onTap: () async {
        await StorageService.setString('language_code', langCode);
        Get.updateLocale(Locale(langCode));
        Get.back();
      },
      leading: Text(flag, style: TextStyle(fontSize: 24.sp)),
      title: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16.sp,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: Color(0xFF4DB6AC))
          : const Icon(Icons.circle_outlined, color: Colors.white24),
      tileColor: isSelected
          ? Colors.white.withOpacity(0.05)
          : Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(
          color: isSelected ? const Color(0xFF4DB6AC) : Colors.white10,
          width: 1,
        ),
      ),
    );
  }
}
