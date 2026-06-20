import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:which_win/app/routes/app_pages.dart';
import 'package:which_win/data/models/race_model.dart';
import '../controllers/race_bulletin_controller.dart';

class RaceBulletinView extends GetView<RaceBulletinController> {
  const RaceBulletinView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              controller.race.value?.location ?? 'Race Bulletin',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            Obx(() => Text(
              '${controller.raceList.length} races · ${controller.race.value?.date?.split('T').first ?? ''}',
              style: TextStyle(
                color: Colors.white38,
                fontSize: 12.sp,
              ),
            )),
          ],
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4DB6AC)),
            ),
          );
        }

        if (controller.raceList.isEmpty) {
          return Center(
            child: Text(
              'No races found for this meeting',
              style: TextStyle(color: Colors.white38, fontSize: 16.sp),
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(16.w),
          itemCount: controller.raceList.length,
          itemBuilder: (context, index) {
            final raceModel = controller.raceList[index];
            return GestureDetector(
              onTap: () {
                if (raceModel.status == 'FINISHED') {
                  Get.toNamed(AppRoutes.RACE_ANALYSIS, arguments: raceModel);
                } else {
                  Get.toNamed(AppRoutes.RACE_DETAILS, arguments: raceModel);
                }
              },
              child: _buildRaceItem(raceModel, index + 1),
            );
          },
        );
      }),
    );
  }

  Widget _buildRaceItem(RaceModel raceModel, int raceNumber) {
    final trackType = raceModel.trackType ?? 'Turf';
    final entriesCount = raceModel.entriesCount ?? 0;
    
    String restMessage = '';
    if (raceModel.predictionMessage != null && raceModel.predictionMessage!.isNotEmpty) {
      final msg = raceModel.predictionMessage!;
      if (msg.toLowerCase().startsWith('who beat whom:')) {
        restMessage = msg.substring(14).trim();
      } else {
        restMessage = msg;
      }
    }

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1419),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Race Number Circle
                Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: const Color(0xFF003D33),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$raceNumber',
                    style: TextStyle(
                      color: const Color(0xFF4DB6AC),
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                // Race Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              raceModel.name ?? 'Race $raceNumber',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            raceModel.time ?? '',
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: 14.sp,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          _buildTag(raceModel.status ?? 'UPCOMING', const Color(0xFF1E293B)),
                          SizedBox(width: 4.w),
                          _buildTag(trackType, const Color(0xFF003D33),
                              textColor: const Color(0xFF4DB6AC)),
                          SizedBox(width: 8.w),
                          Text(
                            raceModel.distance ?? '',
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Horses count
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFF003D33),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        '$entriesCount runners',
                        style: TextStyle(
                          color: const Color(0xFF4DB6AC),
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
          if (restMessage.isNotEmpty) ...[
            const Divider(color: Colors.white12, height: 1),
            // Footer Text
            Padding(
              padding: EdgeInsets.all(12.w),
              child: RichText(
                text: TextSpan(
                  style: TextStyle(color: Colors.white38, fontSize: 13.sp),
                  children: [
                    const TextSpan(text: 'Who beat whom: '),
                    TextSpan(
                      text: restMessage,
                      style: const TextStyle(color: Colors.orange),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color bgColor, {Color textColor = Colors.white70}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 10.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
