import 'package:get/get.dart';
import 'package:which_win/core/controllers/internet_controller.dart';
import 'package:which_win/core/services/connectivity_service.dart';
import 'package:which_win/core/services/api_client.dart';
import 'package:which_win/core/services/storage_service.dart';
import 'package:which_win/data/repositories/auth_repository.dart';
import 'package:which_win/data/repositories/race_repository.dart';
import 'package:which_win/data/repositories/notification_repository.dart';
import 'package:which_win/data/repositories/subscription_repository.dart';
import 'package:which_win/data/repositories/common_repository.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Initialize core services
    Get.put(StorageService(), permanent: true);
    Get.put(ApiClient(), permanent: true);

    // Repositories
    Get.lazyPut(() => AuthRepo(), fenix: true);
    Get.lazyPut(() => RaceRepo(), fenix: true);
    Get.lazyPut(() => NotificationRepo(), fenix: true);
    Get.lazyPut(() => SubscriptionRepo(), fenix: true);
    Get.lazyPut(() => CommonRepo(), fenix: true);
    
    // Global controllers
    Get.put(InternetController(), permanent: true);

    // Services init
    ConnectivityService.init();
  }
}
