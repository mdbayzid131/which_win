import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import 'package:which_win/config/constants/api_constants.dart';
import 'package:which_win/core/services/api_client.dart';

class CommonRepo {
  final ApiClient apiClient = Get.find<ApiClient>();

  /// ===================== CONTACT US =====================
  Future<dio.Response> contactUs({
    required String name,
    required String email,
    required String subject,
    required String message,
  }) async {
    return await apiClient.postData(ApiConstants.contact, {
      "name": name,
      "email": email,
      "subject": subject,
      "message": message,
    });
  }

  /// ===================== GET LEGAL CONTENT =====================
  Future<dio.Response> getLegalContent(String type) async {
    // type can be 'terms' or 'privacy'
    return await apiClient.getData('${ApiConstants.legal}$type');
  }
}
