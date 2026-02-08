import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/push_notification_provider.dart';
import '../widgets/push_notification_widget.dart';

class NotificationsTestScreen extends ConsumerStatefulWidget {
  const NotificationsTestScreen({super.key});

  @override
  ConsumerState<NotificationsTestScreen> createState() => _NotificationsTestScreenState();
}

class _NotificationsTestScreenState extends ConsumerState<NotificationsTestScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize push notifications when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(pushNotificationProvider.notifier).refreshToken();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Push Notifications Test'),
        elevation: 0,
      ),
      body: const PushNotificationWidget(),
    );
  }
}