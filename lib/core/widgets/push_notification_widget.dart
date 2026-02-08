import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/push_notification_provider.dart';

class PushNotificationWidget extends ConsumerWidget {
  const PushNotificationWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pushNotificationProvider);

    if (state.isInitialized) {
      return Card(
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.notifications_active,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Push Notifications',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (state.token != null) ...[
                _buildInfoTile(
                  context,
                  'FCM Token',
                  state.token!,
                  icon: Icons.token,
                ),
                const SizedBox(height: 8),
              ],
              if (state.lastMessage != null) ...[
                _buildInfoTile(
                  context,
                  'Last Message',
                  state.lastMessage!,
                  icon: Icons.message,
                ),
                const SizedBox(height: 8),
              ],
              if (state.error != null)
                _buildErrorTile(context, state.error!),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => ref.read(pushNotificationProvider.notifier).refreshToken(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh Token'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => ref.read(pushNotificationProvider.notifier).requestPermission(),
                    icon: const Icon(Icons.settings),
                    label: const Text('Request Permission'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  Icons.notifications_none,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Push Notifications',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (state.isLoading)
              const LinearProgressIndicator(),
            if (state.error != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  'Error: ${state.error}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.red,
                      ),
                ),
              ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => ref.read(pushNotificationProvider.notifier).refreshToken(),
              icon: const Icon(Icons.play_arrow),
              label: const Text('Initialize Notifications'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(BuildContext context, String title, String value, {required IconData icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey),
            const SizedBox(width: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontFamily: 'monospace',
                fontSize: 12,
              ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildErrorTile(BuildContext context, String error) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Text(
        '❌ Error: $error',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.red,
            ),
      ),
    );
  }
}