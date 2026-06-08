import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import 'package:which_win/config/constants/api_constants.dart';
import 'package:which_win/core/services/api_client.dart';

class SubscriptionRepo {
  final ApiClient apiClient = Get.find<ApiClient>();

  /// ===================== GET PLANS =====================
  Future<dio.Response> getPlans() async {
    return await apiClient.getData(ApiConstants.getSubscriptionPlans);
  }
}
