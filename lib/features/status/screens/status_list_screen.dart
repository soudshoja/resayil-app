import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/theme/app_colors.dart';
import '../../../core/widgets/chat_avatar.dart';
import '../../../core/models/status_update.dart';
import '../providers/status_provider.dart';
import 'status_viewer_screen.dart';

class StatusListScreen extends ConsumerWidget {
  const StatusListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(statusProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Status',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {},
            itemBuilder: (context) => [
              const PopupMenuItem(
                  value: 'privacy', child: Text('Status privacy')),
            ],
          ),
        ],
      ),
      body: statusAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline,
                  size: 48, color: AppColors.error),
              const SizedBox(height: 16),
              Text(error.toString(),
                  style: const TextStyle(
                      color: AppColors.textSecondary)),
              TextButton.icon(
                onPressed: () =>
                    ref.read(statusProvider.notifier).refresh(),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (statuses) {
          final recent =
              statuses.where((s) => s.hasUnviewed).toList();
          final viewed =
              statuses.where((s) => !s.hasUnviewed).toList();

          return RefreshIndicator(
            color: AppColors.accent,
            onRefresh: () =>
                ref.read(statusProvider.notifier).refresh(),
            child: ListView(
              children: [
                // My Status
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  leading: Stack(
                    children: [
                      const ChatAvatar(name: 'My Status', size: 52),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: AppColors.background,
                                width: 2),
                          ),
                          child: const Icon(Icons.add,
                              size: 14, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  title: const Text(
                    'My Status',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text(
                    'Tap to add status update',
                    style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13),
                  ),
                  onTap: () => context.go('/status/create'),
                ),

                const Divider(),

                // Recent updates
                if (recent.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Text(
                      'Recent updates',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  ...recent.map((s) => _buildStatusTile(
                      context, s, false, statuses)),
                ],

                // Viewed updates
                if (viewed.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Text(
                      'Viewed updates',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  ...viewed.map((s) => _buildStatusTile(
                      context, s, true, statuses)),
                ],

                if (statuses.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(48),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.circle_outlined,
                              size: 64,
                              color: AppColors.textSecondary
                                  .withValues(alpha: 0.5)),
                          const SizedBox(height: 16),
                          const Text(
                            'No status updates',
                            style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'edit',
            onPressed: () => context.go('/status/create'),
            backgroundColor: AppColors.surface,
            child: const Icon(Icons.edit,
                color: AppColors.textPrimary),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'camera',
            onPressed: () => context.go('/status/create'),
            child: const Icon(Icons.camera_alt),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTile(
    BuildContext context,
    ContactStatus status,
    bool viewed,
    List<ContactStatus> allStatuses,
  ) {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: viewed
                ? AppColors.textSecondary
                : AppColors.accent,
            width: 2,
          ),
        ),
        child: ChatAvatar(
          name: status.name,
          imageUrl: status.avatar,
          size: 44,
        ),
      ),
      title: Text(
        status.name,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        _formatTime(status.lastUpdateTime),
        style: const TextStyle(
            color: AppColors.textSecondary, fontSize: 13),
      ),
      onTap: () {
        final contactIndex = allStatuses.indexOf(status);
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => StatusViewerScreen(
              contacts: allStatuses,
              initialContactIndex:
                  contactIndex >= 0 ? contactIndex : 0,
            ),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(
                  opacity: animation, child: child);
            },
          ),
        );
      },
    );
  }

  String _formatTime(DateTime? time) {
    if (time == null) return '';
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return 'Yesterday';
  }
}
