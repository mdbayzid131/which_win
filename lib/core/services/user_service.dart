import 'package:get/get.dart';
import 'package:which_win/config/constants/storage_constants.dart';
import 'package:which_win/core/services/storage_service.dart';

class UserService extends GetxService {
  static UserService get to => Get.find<UserService>();

  final isPremium = false.obs;
  final subscriptionPlan = ''.obs;
  final subscriptionEndDate = ''.obs;
  final subscriptionStartDate = ''.obs;
  final subscriptionId = ''.obs;
  final deviceId = ''.obs;
  final token = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadFromStorage();
  }

  Future<void> loadFromStorage() async {
    isPremium.value = (await StorageService.getBool(StorageConstants.isPremium)) ?? false;
    subscriptionPlan.value = await StorageService.getString(StorageConstants.subscriptionPlan);
    subscriptionEndDate.value = await StorageService.getString(StorageConstants.subscriptionEndDate);
    subscriptionStartDate.value = await StorageService.getString(StorageConstants.subscriptionStartDate);
    subscriptionId.value = await StorageService.getString(StorageConstants.subscriptionId);
    deviceId.value = await StorageService.getString(StorageConstants.userId);
    token.value = await StorageService.getString(StorageConstants.bearerToken);
  }

  Future<void> updateSubscriptionData({
    required bool active,
    String? plan,
    String? endDate,
    String? startDate,
    String? id,
  }) async {
    isPremium.value = active;
    subscriptionPlan.value = plan ?? '';
    subscriptionEndDate.value = endDate ?? '';
    subscriptionStartDate.value = startDate ?? '';
    subscriptionId.value = id ?? '';

    await StorageService.setBool(StorageConstants.isPremium, active);
    await StorageService.setString(StorageConstants.subscriptionPlan, plan ?? '');
    await StorageService.setString(StorageConstants.subscriptionEndDate, endDate ?? '');
    await StorageService.setString(StorageConstants.subscriptionStartDate, startDate ?? '');
    await StorageService.setString(StorageConstants.subscriptionId, id ?? '');
  }
}
