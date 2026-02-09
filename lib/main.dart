import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'app.dart';
import 'core/firebase/firebase_options.dart';
import 'core/services/push_notification_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(
      const Duration(seconds: 30),
      onTimeout: () {
        throw TimeoutException(
          'Firebase initialization timed out in background handler',
        );
      },
    );
  } catch (e) {
    // Log background initialization error but continue
    // ignore: avoid_print
    print('Background Firebase initialization error: $e');
  }

  try {
    await PushNotificationService.handleBackgroundMessage(message).timeout(
      const Duration(seconds: 15),
      onTimeout: () {
        throw TimeoutException(
          'Background message handler timed out',
        );
      },
    );
  } catch (e) {
    // ignore: avoid_print
    print('Error handling background message: $e');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with timeout
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(
      const Duration(seconds: 30),
      onTimeout: () {
        throw TimeoutException(
          'Firebase initialization timed out after 30 seconds',
        );
      },
    );
  } catch (e) {
    // Log Firebase initialization error but continue app startup
    // ignore: avoid_print
    print('Firebase initialization error: $e');
    // App will show error screen with retry option
  }

  // Set background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF1f2c34),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const ProviderScope(child: ResayilApp()));
}
