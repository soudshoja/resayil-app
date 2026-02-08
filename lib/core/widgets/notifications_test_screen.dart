import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'push_notification_widget.dart';

class NotificationsTestScreen extends ConsumerWidget {
  const NotificationsTestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Push Notifications Test'),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: const Center(
        child: PushNotificationWidget(),
      ),
    );
  }
}