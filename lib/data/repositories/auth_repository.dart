import 'package:dio/dio.dart' as dio;
import 'package:which_win/config/constants/api_constants.dart';
import 'package:which_win/core/services/api_client.dart';
import 'package:get/get.dart';

class AuthRepo {
  final ApiClient apiClient = Get.find<ApiClient>();

  /// ===================== DEVICE LOGIN =====================
  Future<dio.Response> deviceLogin(String deviceId) async {
    return await apiClient.postData(ApiConstants.deviceLogin, {
      "deviceId": deviceId,
    });
  }

  /// ===================== PURCHASE SUBSCRIPTION =====================
  Future<dio.Response> purchaseSubscription({
    required String deviceId,
    required String planId,
    required String duration,
  }) async {
    return await apiClient.postData(ApiConstants.purchaseSubscription, {
      "deviceId": deviceId,
      "planId": planId,
      "duration": duration,
    });
  }
}
