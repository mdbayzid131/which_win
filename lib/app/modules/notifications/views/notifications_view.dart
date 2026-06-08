import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:which_win/core/utils/helpers.dart';
import 'package:which_win/data/models/notification_model.dart';
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
        actions: [
          Obx(() {
            if (controller.unreadCount.value > 0) {
              return TextButton(
                onPressed: () => controller.markAllAsRead(),
                child: Text(
                  'Mark all read',
                  style: TextStyle(
                    color: const Color(0xFF4DB6AC),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }
            return const SizedBox();
          }),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.h),
          child: Container(color: Colors.white12, height: 1.h),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.notificationList.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4DB6AC)),
            ),
          );
        }

        if (controller.notificationList.isEmpty) {
          return RefreshIndicator(
            onRefresh: () => controller.fetchNotifications(isRefresh: true),
            color: const Color(0xFF4DB6AC),
            backgroundColor: const Color(0xFF0F1419),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(height: 200.h),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_off_outlined, color: Colors.white24, size: 64.sp),
                      SizedBox(height: 16.h),
                      Text(
                        'No notifications yet',
                        style: TextStyle(color: Colors.white38, fontSize: 16.sp),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchNotifications(isRefresh: false),
          color: const Color(0xFF4DB6AC),
          backgroundColor: const Color(0xFF0F1419),
          child: ListView.builder(
            padding: EdgeInsets.all(16.w),
            itemCount: controller.notificationList.length,
            itemBuilder: (context, index) {
              final notificationModel = controller.notificationList[index];
              return _buildNotificationCard(notificationModel);
            },
          ),
        );
      }),
    );
  }

  Widget _buildNotificationCard(NotificationModel notificationModel) {
    final isRead = notificationModel.isRead ?? true;
    
    String timeString = '';
    if (notificationModel.createdAt != null) {
      try {
        final parsedDate = DateTime.parse(notificationModel.createdAt!);
        timeString = Helpers.timeAgo(parsedDate);
      } catch (e) {
        timeString = notificationModel.createdAt!;
      }
    }

    return InkWell(
      onTap: () {
        if (!isRead && notificationModel.id != null) {
          controller.markAsRead(notificationModel.id!);
        }
      },
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        decoration: BoxDecoration(
          color: isRead ? const Color(0xFF0F1419) : const Color(0xFF161E26),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isRead ? Colors.white12 : const Color(0xFF4DB6AC).withValues(alpha: 0.3),
            width: isRead ? 1.0 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
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
                    colors: isRead
                        ? [
                            Colors.white24,
                            Colors.white10,
                          ]
                        : [
                            const Color(0xFF4DB6AC),
                            const Color(0xFF4DB6AC).withValues(alpha: 0.5),
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
                          Expanded(
                            child: Text(
                              notificationModel.title ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.sp,
                                fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          _getIconForType(notificationModel.type ?? 'alert'),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        notificationModel.message ?? '',
                        style: TextStyle(
                          color: isRead ? Colors.white70 : Colors.white,
                          fontSize: 14.sp,
                          height: 1.4,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        timeString,
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
      ),
    );
  }

  Widget _getIconForType(String type) {
    IconData iconData;
    Color iconColor;

    final t = type.toLowerCase();
    if (t.contains('race')) {
      iconData = Icons.sports_score;
      iconColor = Colors.greenAccent;
    } else if (t.contains('prediction')) {
      iconData = Icons.psychology;
      iconColor = Colors.blueAccent;
    } else if (t.contains('subscription')) {
      iconData = Icons.card_membership;
      iconColor = Colors.orangeAccent;
    } else if (t.contains('system') || t.contains('alert')) {
      iconData = Icons.notification_important;
      iconColor = Colors.redAccent;
    } else {
      iconData = Icons.notifications;
      iconColor = Colors.white38;
    }

    return Icon(iconData, color: iconColor.withValues(alpha: 0.6), size: 18.sp);
  }
}
