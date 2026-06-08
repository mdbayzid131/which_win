class ApiConstants {
  // Base URLs - Always end with a trailing slash
  static const String baseUrl = 'http://10.10.7.111:5000/api/v1/';

  // Auth Endpoints
  static const String deviceLogin = 'auth/device-login';
  static const String purchaseSubscription = 'auth/purchase-subscription';

  // Race Endpoints
  static const String getRaces = 'race';
  static const String getRaceDetails = 'race/'; // append {id}
  static const String getRaceDates = 'race/dates';
  static const String getRaceStatistics = 'race/'; // append {id}/statistics
  static const String getHorseProfile = 'horse/'; // append {id}

  // Notification Endpoints
  static const String notifications = 'notification';
  static const String markNotificationRead = 'notification/'; // append {id}/read
  static const String markAllNotificationsRead = 'notification/mark-all-read';
  static const String registerFcmToken = 'notification/register-token';

  // Subscription Endpoints
  static const String getSubscriptionPlans = 'subscription/plans';

  // Other Endpoints
  static const String contact = 'contact';
  static const String rating = 'rating';
  static const String legal = 'legal/'; // append {type}

  // Standard GetX Service refresh token
  static const String refreshToken = 'auth/refresh-token';
}


