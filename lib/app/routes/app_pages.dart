import 'package:get/get.dart';
import 'package:which_win/app/modules/home/bindings/home_binding.dart';
import 'package:which_win/app/modules/home/views/home_view.dart';
import 'package:which_win/app/modules/contact/bindings/contact_binding.dart';
import 'package:which_win/app/modules/contact/views/contact_view.dart';
import 'package:which_win/app/modules/rate_us/bindings/rate_us_binding.dart';
import 'package:which_win/app/modules/rate_us/views/rate_us_view.dart';
import 'package:which_win/app/modules/notifications/bindings/notifications_binding.dart';
import 'package:which_win/app/modules/notifications/views/notifications_view.dart';
import 'package:which_win/app/modules/subscription/bindings/subscription_binding.dart';
import 'package:which_win/app/modules/subscription/views/subscription_view.dart';
import 'package:which_win/app/modules/privacy_policy/bindings/privacy_policy_binding.dart';
import 'package:which_win/app/modules/privacy_policy/views/privacy_policy_view.dart';
import 'package:which_win/app/modules/terms_conditions/bindings/terms_conditions_binding.dart';
import 'package:which_win/app/modules/terms_conditions/views/terms_conditions_view.dart';
import 'package:which_win/app/modules/race_analysis/bindings/race_analysis_binding.dart';
import 'package:which_win/app/modules/race_analysis/views/race_analysis_view.dart';
import 'package:which_win/app/modules/race_bulletin/bindings/race_bulletin_binding.dart';
import 'package:which_win/app/modules/race_bulletin/views/race_bulletin_view.dart';
import 'package:which_win/app/modules/race_details/bindings/race_details_binding.dart';
import 'package:which_win/app/modules/race_details/views/race_details_view.dart';
import 'package:which_win/app/modules/splash_screen/bindings/splash_screen_binding.dart';
import 'package:which_win/app/modules/splash_screen/views/splash_screen_view.dart';
import 'package:which_win/app/modules/gift_a_friend/bindings/gift_a_friend_binding.dart';
import 'package:which_win/app/modules/gift_a_friend/views/gift_a_friend_view.dart';

class AppRoutes {
  static const SPLASH_SCREEN = '/splash-screen';
  static const HOME = '/home';
  static const RACE_BULLETIN = '/race-bulletin';
  static const RACE_ANALYSIS = '/race-analysis';
  static const RACE_DETAILS = '/race-details';
  static const NOTIFICATIONS = '/notifications';
  static const SUBSCRIPTION = '/subscription';
  static const PRIVACY_POLICY = '/privacy-policy';
  static const TERMS_CONDITIONS = '/terms-conditions';
  static const CONTACT = '/contact';
  static const RATE_US = '/rate-us';
  static const GIFT_A_FRIEND = '/gift-a-friend';

  static String get initial => SPLASH_SCREEN;
}

Transition transition = Transition.fade;

class AppPages {
  AppPages._();

  static final routes = [
    GetPage(
      name: AppRoutes.SPLASH_SCREEN,
      page: () => const SplashScreenView(),
      binding: SplashScreenBinding(),
      transition: transition,
    ),
    GetPage(
      name: AppRoutes.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
      transition: transition,
    ),
    GetPage(
      name: AppRoutes.RACE_BULLETIN,
      page: () => const RaceBulletinView(),
      binding: RaceBulletinBinding(),
      transition: transition,
    ),
    GetPage(
      name: AppRoutes.RACE_ANALYSIS,
      page: () => const RaceAnalysisView(),
      binding: RaceAnalysisBinding(),
      transition: transition,
    ),
    GetPage(
      name: AppRoutes.RACE_DETAILS,
      page: () => const RaceDetailsView(),
      binding: RaceDetailsBinding(),
      transition: transition,
    ),
    GetPage(
      name: AppRoutes.NOTIFICATIONS,
      page: () => const NotificationsView(),
      binding: NotificationsBinding(),
      transition: transition,
    ),
    GetPage(
      name: AppRoutes.SUBSCRIPTION,
      page: () => SubscriptionView(),
      binding: SubscriptionBinding(),
      transition: transition,
    ),
    GetPage(
      name: AppRoutes.PRIVACY_POLICY,
      page: () => const PrivacyPolicyView(),
      binding: PrivacyPolicyBinding(),
      transition: transition,
    ),
    GetPage(
      name: AppRoutes.TERMS_CONDITIONS,
      page: () => const TermsConditionsView(),
      binding: TermsConditionsBinding(),
      transition: transition,
    ),
    GetPage(
      name: AppRoutes.CONTACT,
      page: () => const ContactView(),
      binding: ContactBinding(),
      transition: transition,
    ),
    GetPage(
      name: AppRoutes.RATE_US,
      page: () => const RateUsView(),
      binding: RateUsBinding(),
      transition: transition,
    ),
    GetPage(
      name: AppRoutes.GIFT_A_FRIEND,
      page: () => const GiftAFriendView(),
      binding: GiftAFriendBinding(),
      transition: transition,
    ),
  ];
}
