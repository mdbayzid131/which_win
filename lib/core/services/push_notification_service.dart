import 'package:get/get.dart';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:which_win/core/utils/helpers.dart';
import 'package:which_win/app/modules/notifications/controllers/notifications_controller.dart';

/// ===================== FIREBASE NOTIFICATION SERVICE =====================
/// Handles Firebase Cloud Messaging (FCM) push notifications.
/// Requires: firebase_core, firebase_messaging
/// Also needs google-services.json (Android) and GoogleService-Info.plist (iOS).

/// 🔥 Background handler — must be a top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  Helpers.debug('📬 Background Message: ${message.messageId}');
}

class FirebaseNotificationService {
  FirebaseNotificationService._();

  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// Callback for foreground messages
  static void Function(RemoteMessage)? onForegroundMessage;

  /// Callback for notification tap (app in background)
  static void Function(RemoteMessage)? onNotificationTap;

  /// Callback for FCM token refresh
  static void Function(String)? onTokenRefresh;

  /// Setup FCM listeners and background handlers (Does NOT request permission)
  static Future<void> setupInterceptors() async {
    // Listen for token refresh
    _messaging.onTokenRefresh.listen((newToken) {
      Helpers.info('🔄 FCM Token refreshed: $newToken');
      onTokenRefresh?.call(newToken);
    });

    // Foreground message listener
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      Helpers.info('📨 Foreground Message: ${message.notification?.title}');

      // Sync and update the UI unread notification count
      if (Get.isRegistered<NotificationsController>()) {
        // Get.find<NotificationsController>().fetchNotifications(isRefresh: true);
        Helpers.info('🔄 NotificationsController found, but fetchNotifications is not implemented in the new project yet.');
      }

      onForegroundMessage?.call(message);
    });

    // Notification tap (app in background)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      Helpers.info('🔔 Notification clicked: ${message.data}');
      onNotificationTap?.call(message);
    });

    // App opened from terminated state
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      Helpers.info('🚀 Opened from terminated: ${initialMessage.data}');
      onNotificationTap?.call(initialMessage);
    }

    // Register background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  /// Request permission and get FCM token
  static Future<String?> requestPermissionAndGetToken() async {
    // Request permission (Android auto-grants, iOS requires this)
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    Helpers.debug(
      '🔐 Push Notification Permission Status: ${settings.authorizationStatus}',
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      Helpers.warning('🚫 Push Notification Permission Denied by user');
      return null;
    }

    // Get FCM token
    String? token;
    try {
      if (Platform.isIOS) {
        String? apnsToken = await _messaging.getAPNSToken();
        int retryCount = 0;
        while (apnsToken == null && retryCount < 3) {
          await Future.delayed(const Duration(seconds: 2));
          apnsToken = await _messaging.getAPNSToken();
          retryCount++;
          Helpers.debug('⏳ Waiting for APNS Token... (Retry: $retryCount)');
        }
      }

      token = await _messaging.getToken();
      Helpers.info('🔑 FCM Token: $token');
    } catch (e) {
      Helpers.error('❌ Error getting FCM Token: $e');
    }

    return token;
  }

  /// Initialize FCM (Legacy - now split into setupInterceptors and requestPermissionAndGetToken)
  static Future<String?> initialize() async {
    await setupInterceptors();
    return await requestPermissionAndGetToken();
  }

  /// Subscribe to a topic
  static Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
    Helpers.debug('Subscribed to topic: $topic');
  }

  /// Unsubscribe from a topic
  static Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
    Helpers.debug('Unsubscribed from topic: $topic');
  }
}
