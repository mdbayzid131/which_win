import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import 'package:which_win/config/constants/api_constants.dart';
import 'package:which_win/core/services/api_client.dart';

class RaceRepo {
  final ApiClient apiClient = Get.find<ApiClient>();

  /// ===================== GET RACES =====================
  Future<dio.Response> getRaces({
    String? date,
    String? status,
    String? location,
    String? search,
    int? page,
    int? limit,
  }) async {
    final query = <String, dynamic>{};
    if (date != null) query['date'] = date;
    if (status != null) query['status'] = status;
    if (location != null) query['location'] = location;
    if (search != null) query['search'] = search;
    if (page != null) query['page'] = page;
    if (limit != null) query['limit'] = limit;

    return await apiClient.getData(ApiConstants.getRaces, query: query);
  }

  /// ===================== GET RACE DETAILS =====================
  Future<dio.Response> getRaceDetails(String id) async {
    return await apiClient.getData('${ApiConstants.getRaceDetails}$id');
  }

  /// ===================== GET RACE DATES =====================
  Future<dio.Response> getRaceDates({String? month}) async {
    final query = <String, dynamic>{};
    if (month != null) query['month'] = month;
    return await apiClient.getData(ApiConstants.getRaceDates, query: query);
  }

  /// ===================== GET RACE STATISTICS =====================
  Future<dio.Response> getRaceStatistics(String id) async {
    return await apiClient.getData('${ApiConstants.getRaceStatistics}$id/statistics');
  }

  /// ===================== GET HORSE PROFILE =====================
  Future<dio.Response> getHorseProfile(String id) async {
    return await apiClient.getData('${ApiConstants.getHorseProfile}$id');
  }
}
