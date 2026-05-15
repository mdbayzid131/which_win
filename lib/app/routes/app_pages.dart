import 'package:get/get.dart';
import 'package:which_win/app/modules/home/bindings/home_binding.dart';
import 'package:which_win/app/modules/home/views/home_view.dart';
import 'package:which_win/app/modules/race_analysis/bindings/race_analysis_binding.dart';
import 'package:which_win/app/modules/race_analysis/views/race_analysis_view.dart';
import 'package:which_win/app/modules/race_bulletin/bindings/race_bulletin_binding.dart';
import 'package:which_win/app/modules/race_bulletin/views/race_bulletin_view.dart';
import 'package:which_win/app/modules/splash_screen/bindings/splash_screen_binding.dart';
import 'package:which_win/app/modules/splash_screen/views/splash_screen_view.dart';

class AppRoutes {
  static const SPLASH_SCREEN = '/splash-screen';
  static const HOME = '/home';
  static const RACE_BULLETIN = '/race-bulletin';
  static const RACE_ANALYSIS = '/race-analysis';
  
  static String get initial => SPLASH_SCREEN;
}

class AppPages {
  AppPages._();

  static final routes = [
    GetPage(
      name: AppRoutes.SPLASH_SCREEN,
      page: () => const SplashScreenView(),
      binding: SplashScreenBinding(),
    ),
    GetPage(
      name: AppRoutes.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.RACE_BULLETIN,
      page: () => const RaceBulletinView(),
      binding: RaceBulletinBinding(),
    ),
    GetPage(
      name: AppRoutes.RACE_ANALYSIS,
      page: () => const RaceAnalysisView(),
      binding: RaceAnalysisBinding(),
    ),
  ];
}
