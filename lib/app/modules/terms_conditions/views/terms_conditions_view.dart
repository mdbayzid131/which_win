import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controllers/terms_conditions_controller.dart';

class TermsConditionsView extends GetView<TermsConditionsController> {
  const TermsConditionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Row(
            children: [
              Icon(Icons.arrow_back_ios, color: Colors.white, size: 16.sp),
              Text('back'.tr, style: TextStyle(color: Colors.white, fontSize: 14.sp)),
            ],
          ),
          onPressed: () => Get.back(),
        ),
        leadingWidth: 80.w,
        title: Text(
          'terms_conditions'.tr,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.h),
          child: Container(color: Colors.white12, height: 1.h),
        ),
      ),
      body: SafeArea(
        top: false,
        bottom: true,
        child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4DB6AC)),
            ),
          );
        }

        if (controller.content.value.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: Colors.white24, size: 60.sp),
                SizedBox(height: 16.h),
                Text(
                  'failed_load_terms'.tr,
                  style: TextStyle(color: Colors.white70, fontSize: 16.sp),
                ),
                SizedBox(height: 24.h),
                ElevatedButton(
                  onPressed: () => controller.fetchTerms(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4DB6AC),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Text('retry'.tr, style: TextStyle(color: Colors.black, fontSize: 14.sp)),
                ),
              ],
            ),
          );
        }

        final paragraphs = controller.content.value.split('\n\n');

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: paragraphs.map((para) {
              final trimmed = para.trim();
              if (trimmed.isEmpty) return const SizedBox();

              final lines = trimmed.split('\n');
              final title = lines.first;
              final hasBody = lines.length > 1;

              final isHeader = title.length < 60 &&
                  !title.endsWith('.') &&
                  (title.contains(RegExp(r'^[0-9]+[.)]')) ||
                      title.toLowerCase().contains('collect') ||
                      title.toLowerCase().contains('use') ||
                      title.toLowerCase().contains('security') ||
                      title.toLowerCase().contains('information') ||
                      title.toLowerCase().contains('acceptance') ||
                      title.toLowerCase().contains('license') ||
                      title.toLowerCase().contains('disclaimer') ||
                      title.toUpperCase() == title);

              if (isHeader) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 24.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          height: 1.4,
                        ),
                      ),
                      if (hasBody) ...[
                        SizedBox(height: 12.h),
                        Text(
                          lines.sublist(1).join('\n'),
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 15.sp,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }

              return Padding(
                padding: EdgeInsets.only(bottom: 24.h),
                child: Text(
                  trimmed,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 15.sp,
                    height: 1.6,
                  ),
                ),
              );
            }).toList(),
          ),
        );
      }),
    ),
    );
  }
}
