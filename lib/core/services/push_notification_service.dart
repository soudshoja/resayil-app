import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class PushNotificationService {
  static final PushNotificationService _instance = PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  String? _token;
  String? _lastMessage;

  bool get hasToken => _token != null;
  String? get token => _token;
  String? get lastMessage => _lastMessage;

  Future<void> initialize() async {
    try {
      // Request permission for iOS
      if (kIsWeb) {
        await _messaging.requestPermission();
      } else {
        await _messaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
          provisional: false,
        );
      }

      // Get FCM token
      _token = await _messaging.getToken();
      if (_token != null) {
        await _saveToken(_token!);
        if (kDebugMode) {
          print('✅ FCM Token: $_token');
        }
      }

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        _handleMessage(message);
      });

      // Handle background messages
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        _handleMessage(message);
      });

      // Handle notifications when app is terminated
      FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
        if (message != null) {
          _handleMessage(message);
        }
      });

      // Subscribe to topics
      await _subscribeToTopics();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Firebase initialization error: $e');
      }
    }
  }

  Future<void> _saveToken(String token) async {
    // TODO: Send token to your backend API
    // await apiService.saveFcmToken(token);
    _token = token;
  }

  Future<void> _subscribeToTopics() async {
    try {
      await _messaging.subscribeToTopic('all_users');
      await _messaging.subscribeToTopic('updates');
      if (kDebugMode) {
        print('✅ Subscribed to FCM topics');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Subscribe to topics error: $e');
      }
    }
  }

  void _handleMessage(RemoteMessage message) {
    _lastMessage = message.notification?.title;

    if (message.notification != null) {
      if (kDebugMode) {
        print('🔔 Notification received:');
        print('  Title: ${message.notification!.title}');
        print('  Body: ${message.notification!.body}');
        print('  Data: ${message.data}');
      }

      // TODO: Handle notification tap
      // - Navigate to appropriate screen
      // - Show bottom sheet
      // - Update UI

      // TODO: Show local notification (if needed)
      // await _showLocalNotification(message);
    }
  }
}