import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import 'package:which_win/config/constants/api_constants.dart';
import 'package:which_win/core/services/api_client.dart';

class NotificationRepo {
  final ApiClient apiClient = Get.find<ApiClient>();

  /// ===================== GET NOTIFICATIONS =====================
  Future<dio.Response> getNotifications({int? page, int? limit}) async {
    final query = <String, dynamic>{};
    if (page != null) query['page'] = page;
    if (limit != null) query['limit'] = limit;
    return await apiClient.getData(ApiConstants.notifications, query: query);
  }

  /// ===================== MARK AS READ =====================
  Future<dio.Response> markRead(String id) async {
    return await apiClient.patchData('${ApiConstants.markNotificationRead}$id/read', {});
  }

  /// ===================== MARK ALL AS READ =====================
  Future<dio.Response> markAllRead() async {
    return await apiClient.patchData(ApiConstants.markAllNotificationsRead, {});
  }

  /// ===================== REGISTER FCM TOKEN =====================
  Future<dio.Response> registerFcmToken(String fcmToken, String platform) async {
    return await apiClient.patchData(ApiConstants.registerFcmToken, {
      "fcmToken": fcmToken,
      "platform": platform,
    });
  }
}
