import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:which_win/app/modules/home/controllers/home_controller.dart';
import 'package:which_win/app/routes/app_pages.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  // Image Assets Variables
  static const String logoPath = 'assets/images/logo.png';
  static const String drawerBgPath = 'assets/images/drawer_bg.png';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      drawer: _buildDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.black,
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
          IconButton(
            icon: const Icon(Icons.settings_input_antenna, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(
              Icons.calendar_today_outlined,
              color: Colors.white,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.tune, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
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
                decoration: InputDecoration(
                  hintText: 'Search country...',
                  hintStyle: TextStyle(color: Colors.white38, fontSize: 16.sp),
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
            child: Obx(
              () => ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                itemCount: controller.categories.length,
                itemBuilder: (context, index) {
                  final category = controller.categories[index];
                  final isSelected =
                      controller.selectedCategory.value == category;
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
                        category,
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
              ),
            ),
          ),
          SizedBox(height: 16.h),
          // List of Items
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: 8,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => Get.toNamed(AppRoutes.RACE_BULLETIN),
                  child: _buildRaceCard(index == 0, index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: Colors.black,
      child: Column(
        children: [
          // Drawer Header with Background Image
          Container(
            height: 200.h,
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(drawerBgPath),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              color: Colors.black.withOpacity(0.4), // Subtle overlay
              child: const Center(
                child: SizedBox(), // Content is already in the background image
              ),
            ),
          ),
          const Divider(color: Colors.white12, height: 1),
          // Drawer Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(Icons.pets, 'Matches', () {}),
                _buildDrawerItem(
                  Icons.notifications_outlined,
                  'Notifications',
                  () {},
                ),
                _buildDrawerItem(
                  Icons.credit_card_outlined,
                  'Subscription info',
                  () {},
                ),
                _buildDrawerItem(Icons.phone_outlined, 'Contact', () {}),
                _buildDrawerItem(
                  Icons.description_outlined,
                  'Terms and Conditions',
                  () {},
                ),
                _buildDrawerItem(Icons.lock_outline, 'Privacy Policy', () {}),
                _buildDrawerItem(Icons.star_outline, 'Rate us', () {}),
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
                  'Version 2.1.8',
                  style: TextStyle(color: Colors.white38, fontSize: 12.sp),
                ),
                Text(
                  'FFDHDJHUUJYDGGHIUUHD#@',
                  style: TextStyle(color: Colors.white24, fontSize: 10.sp),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: TextStyle(color: Colors.white, fontSize: 16.sp),
      ),
      trailing: const Icon(Icons.keyboard_arrow_right, color: Colors.white38),
      onTap: onTap,
    );
  }

  Widget _buildRaceCard(bool isLive, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          // Flag/Icon
          Container(
            width: 40.w,
            height: 40.w,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: NetworkImage('https://flagcdn.com/w80/gb.png'),
                fit: BoxFit.cover,
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
                  'United Kingdom',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Royal Ascot - Gold Cup',
                  style: TextStyle(color: Colors.white38, fontSize: 14.sp),
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
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3D1C00),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    'LIVE',
                    style: TextStyle(
                      color: const Color(0xFFFF6600),
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              SizedBox(height: 4.h),
              Row(
                children: [
                  Text(
                    index % 2 == 0 ? '1' : '2/3',
                    style: TextStyle(color: Colors.white38, fontSize: 12.sp),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.blueAccent,
                    size: 16.sp,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
