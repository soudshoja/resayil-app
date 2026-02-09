import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

import '../api/api_constants.dart';
import 'local_notification_service.dart';

class PushNotificationService {
  PushNotificationService({
    required Dio dio,
    required GoRouter router,
    required LocalNotificationService localNotifications,
  })  : _dio = dio,
        _router = router,
        _localNotifications = localNotifications;

  final Dio _dio;
  final GoRouter _router;
  final LocalNotificationService _localNotifications;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  String? _token;
  String? _lastMessage;

  bool get hasToken => _token != null;
  String? get token => _token;
  String? get lastMessage => _lastMessage;

  Future<void> initialize() async {
    try {
      // Request permission
      await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      // Initialize local notifications with tap handler
      await _localNotifications.initialize(onTap: _navigateFromPayload);

      // Get FCM token and send to backend
      _token = await _messaging.getToken();
      if (_token != null) {
        await _sendTokenToBackend(_token!);
      }

      // Re-send token whenever it refreshes
      _messaging.onTokenRefresh.listen((newToken) async {
        _token = newToken;
        await _sendTokenToBackend(newToken);
        if (kDebugMode) {
          print('FCM token refreshed and sent to backend');
        }
      });

      // Handle foreground messages — show local notification
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle background tap (app was in background)
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageTap);

      // Handle terminated-app tap (app was killed)
      // 500ms delay so the GoRouter has time to fully initialise
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        Future.delayed(const Duration(milliseconds: 500), () {
          _handleMessageTap(initialMessage);
        });
      }

      // Subscribe to topics
      await _subscribeToTopics();
    } catch (e) {
      if (kDebugMode) {
        print('Firebase initialization error: $e');
      }
    }
  }

  // ── Gap 1: Token → backend ──────────────────────────────────────────

  Future<void> _sendTokenToBackend(String token) async {
    try {
      await _dio.post(
        ApiConstants.deviceToken,
        data: {
          'token': token,
          'platform': defaultTargetPlatform.name,
        },
      );
      if (kDebugMode) {
        print('FCM token sent to backend');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to send FCM token to backend: $e');
      }
    }
  }

  // ── Gap 2: Notification tap handling ────────────────────────────────

  /// Called when a user taps a notification from background/terminated state.
  void _handleMessageTap(RemoteMessage message) {
    _lastMessage = message.notification?.title;
    _navigateFromPayload(message.data);
  }

  /// Navigate to the correct screen based on the notification data payload.
  /// Expected keys: `type` ("chat" | "group"), `chatId`/`groupId`, `name`.
  void _navigateFromPayload(Map<String, dynamic> data) {
    final type = data['type'] as String?;
    final name = data['name'] as String? ?? '';

    switch (type) {
      case 'chat':
        final chatId = data['chatId'] as String?;
        if (chatId != null) {
          _router.go('/chats/$chatId?name=${Uri.encodeComponent(name)}');
        }
      case 'group':
        final groupId = data['groupId'] as String?;
        if (groupId != null) {
          _router.go('/groups/$groupId?name=${Uri.encodeComponent(name)}');
        }
      default:
        if (kDebugMode) {
          print('Unknown notification type: $type');
        }
    }
  }

  // ── Gap 3: Local notification for foreground messages ───────────────

  void _handleForegroundMessage(RemoteMessage message) {
    _lastMessage = message.notification?.title;

    if (kDebugMode) {
      print('Foreground notification: ${message.notification?.title}');
    }

    final notification = message.notification;
    if (notification == null) return;

    _localNotifications.show(
      title: notification.title ?? '',
      body: notification.body ?? '',
      data: message.data,
    );
  }

  // ── Gap 4: Background handler (static, called from main.dart) ──────

  /// Must be a top-level or static function for Firebase background handler.
  static Future<void> handleBackgroundMessage(RemoteMessage message) async {
    if (kDebugMode) {
      print('Background message received:');
      print('  Title: ${message.notification?.title}');
      print('  Body: ${message.notification?.body}');
      print('  Data: ${message.data}');
    }

    // To show a local notification for data-only messages in the background,
    // initialise the local notification plugin here:
    //
    // final localNotifications = LocalNotificationService();
    // await localNotifications.initialize();
    // await localNotifications.show(
    //   title: message.data['title'] ?? 'New message',
    //   body: message.data['body'] ?? '',
    //   data: message.data,
    // );
  }

  // ── Topics ──────────────────────────────────────────────────────────

  Future<void> _subscribeToTopics() async {
    try {
      await _messaging.subscribeToTopic('all_users');
      await _messaging.subscribeToTopic('updates');
      if (kDebugMode) {
        print('Subscribed to FCM topics');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Subscribe to topics error: $e');
      }
    }
  }
}
