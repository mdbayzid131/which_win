import 'package:get/get.dart';
import 'package:which_win/core/services/api_checker.dart';
import 'package:which_win/data/models/notification_model.dart';
import 'package:which_win/data/repositories/notification_repository.dart';

class NotificationsController extends GetxController {
  final NotificationRepo _notificationRepo = Get.find<NotificationRepo>();

  final notificationList = <NotificationModel>[].obs;
  final isLoading = false.obs;
  final unreadCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  Future<void> fetchNotifications({bool isRefresh = true}) async {
    if (isRefresh) isLoading.value = true;
    try {
      final response = await _notificationRepo.getNotifications();
      ApiChecker.checkGetApi(response);

      if (response.statusCode == 200) {
        final notificationsResponse = NotificationsResponse.fromJson(response.data);
        notificationList.assignAll(notificationsResponse.data ?? []);
        _calculateUnreadCount();
      }
    } catch (e) {
      // Error handled by ApiChecker
    } finally {
      isLoading.value = false;
    }
  }

  void _calculateUnreadCount() {
    unreadCount.value = notificationList.where((n) => !(n.isRead ?? true)).length;
  }

  Future<void> markAsRead(String id) async {
    try {
      final response = await _notificationRepo.markRead(id);
      if (response.statusCode == 200) {
        final index = notificationList.indexWhere((n) => n.id == id);
        if (index != -1) {
          final updated = NotificationModel(
            id: notificationList[index].id,
            title: notificationList[index].title,
            message: notificationList[index].message,
            type: notificationList[index].type,
            isRead: true,
            createdAt: notificationList[index].createdAt,
          );
          notificationList[index] = updated;
          _calculateUnreadCount();
        }
      }
    } catch (e) {
      // Silence error
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final response = await _notificationRepo.markAllRead();
      if (response.statusCode == 200) {
        for (int i = 0; i < notificationList.length; i++) {
          final n = notificationList[i];
          notificationList[i] = NotificationModel(
            id: n.id,
            title: n.title,
            message: n.message,
            type: n.type,
            isRead: true,
            createdAt: n.createdAt,
          );
        }
        _calculateUnreadCount();
      }
    } catch (e) {
      // Silence error
    }
  }
}
