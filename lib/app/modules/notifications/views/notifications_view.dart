import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/notifications_controller.dart';

class NotificationsView extends GetView<NotificationsController> {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Row(
            children: [
              Icon(Icons.arrow_back_ios, color: Colors.white, size: 16.sp),
              Text('Back', style: TextStyle(color: Colors.white, fontSize: 14.sp)),
            ],
          ),
          onPressed: () => Get.back(),
        ),
        leadingWidth: 80.w,
        title: Text(
          'Notifications',
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
      body: Obx(() => ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: controller.notifications.length,
        itemBuilder: (context, index) {
          final notification = controller.notifications[index];
          return _buildNotificationCard(notification);
        },
      )),
    );
  }

  Widget _buildNotificationCard(Map<String, String> notification) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1419),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.white12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Side Indicator Bar
            Container(
              width: 4.w,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF4DB6AC),
                    const Color(0xFF4DB6AC).withOpacity(0.5),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          notification['title']!,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        _getIconForType(notification['type']!),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      notification['description']!,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14.sp,
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      notification['time']!,
                      style: TextStyle(
                        color: Colors.white24,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getIconForType(String type) {
    IconData iconData;
    Color iconColor;

    switch (type) {
      case 'match':
        iconData = Icons.sports_soccer;
        iconColor = Colors.greenAccent;
        break;
      case 'prediction':
        iconData = Icons.psychology;
        iconColor = Colors.blueAccent;
        break;
      case 'subscription':
        iconData = Icons.card_membership;
        iconColor = Colors.orangeAccent;
        break;
      case 'alert':
        iconData = Icons.notification_important;
        iconColor = Colors.redAccent;
        break;
      default:
        iconData = Icons.notifications;
        iconColor = Colors.white38;
    }

    return Icon(iconData, color: iconColor.withOpacity(0.5), size: 18.sp);
  }
}
