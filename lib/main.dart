import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:which_win/app.dart';
import 'dart:async';

import 'package:which_win/firebase_options.dart';
import 'package:which_win/core/services/push_notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    unawaited(FirebaseNotificationService.setupInterceptors().catchError((e) {
      debugPrint('Firebase interceptors setup failed: $e');
    }));
  } catch (e) {
    // Log error or handle missing config file in local test environment
    debugPrint('Firebase initialization failed: $e');
  }
  runApp(const WhichWinApp());
}
