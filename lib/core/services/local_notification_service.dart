import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Callback type for when a notification is tapped.
typedef NotificationTapCallback = void Function(Map<String, dynamic> payload);

class LocalNotificationService {
  static final LocalNotificationService _instance =
      LocalNotificationService._internal();
  factory LocalNotificationService() => _instance;
  LocalNotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  NotificationTapCallback? _onTap;

  static const _channelId = 'resayil_messages';
  static const _channelName = 'Messages';
  static const _channelDescription = 'Resayil chat and group message notifications';

  Future<void> initialize({NotificationTapCallback? onTap}) async {
    _onTap = onTap;

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
      ),
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    // Create Android notification channel
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(const AndroidNotificationChannel(
          _channelId,
          _channelName,
          description: _channelDescription,
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
        ));
  }

  void _onNotificationResponse(NotificationResponse response) {
    if (response.payload == null || _onTap == null) return;
    try {
      final data = jsonDecode(response.payload!) as Map<String, dynamic>;
      _onTap!(data);
    } catch (_) {}
  }

  Future<void> show({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      const NotificationDetails(
        android: androidDetails,
        iOS: darwinDetails,
      ),
      payload: data != null ? jsonEncode(data) : null,
    );
  }
}
