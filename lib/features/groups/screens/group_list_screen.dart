import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/theme/app_colors.dart';
import '../../../core/widgets/chat_avatar.dart';
import '../../../core/widgets/search_bar_widget.dart';
import '../../../core/models/group.dart';
import '../providers/groups_provider.dart';
import '../repository/groups_repository.dart';

class GroupListScreen extends ConsumerStatefulWidget {
  const GroupListScreen({super.key});

  @override
  ConsumerState<GroupListScreen> createState() => _GroupListScreenState();
}

class _GroupListScreenState extends ConsumerState<GroupListScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final notifier = ref.read(groupsProvider.notifier);
      if (notifier.hasMore && !notifier.isLoadingMore) {
        notifier.loadMore();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredAsync = ref.watch(filteredGroupsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Groups',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'create') context.go('/groups/create');
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                  value: 'create', child: Text('Create group')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          SearchBarWidget(
            hintText: 'Search groups...',
            onChanged: (q) =>
                ref.read(groupSearchQueryProvider.notifier).state = q,
          ),
          Expanded(
            child: filteredAsync.when(
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
                        style:
                            const TextStyle(color: AppColors.textSecondary)),
                    TextButton.icon(
                      onPressed: () =>
                          ref.read(groupsProvider.notifier).refresh(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              data: (groups) {
                if (groups.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.group_outlined,
                            size: 64,
                            color: AppColors.textSecondary
                                .withValues(alpha: 0.5)),
                        const SizedBox(height: 16),
                        const Text('No groups yet',
                            style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 16)),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: () => context.go('/groups/create'),
                          icon: const Icon(Icons.add),
                          label: const Text('Create one'),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  color: AppColors.accent,
                  onRefresh: () =>
                      ref.read(groupsProvider.notifier).refresh(),
                  child: ListView.separated(
                    controller: _scrollController,
                    itemCount: groups.length +
                        (ref.read(groupsProvider.notifier).hasMore ? 1 : 0),
                    separatorBuilder: (_, __) => const Padding(
                      padding: EdgeInsets.only(left: 76),
                      child: Divider(height: 1),
                    ),
                    itemBuilder: (context, index) {
                      if (index >= groups.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(
                            child: CircularProgressIndicator(
                                color: AppColors.accent),
                          ),
                        );
                      }
                      return _buildGroupTile(groups[index]);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/groups/create'),
        child: const Icon(Icons.group_add),
      ),
    );
  }

  Widget _buildGroupTile(Group group) {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: ChatAvatar(
          name: group.name, imageUrl: group.avatar, isGroup: true),
      title: Text(
        group.name,
        style:
            const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      ),
      subtitle: Text(
        group.lastMessage ?? '${group.participantCount} participants',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
            color: AppColors.textSecondary, fontSize: 14),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (group.lastMessageTime != null)
            Text(
              _formatTime(group.lastMessageTime!),
              style: TextStyle(
                color: group.unreadCount > 0
                    ? AppColors.accent
                    : AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          const SizedBox(height: 4),
          if (group.unreadCount > 0)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.badge,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${group.unreadCount}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      onTap: () {
        context.go(
            '/groups/${group.id}?name=${Uri.encodeComponent(group.name)}');
      },
      onLongPress: () => _showGroupActions(group),
    );
  }

  void _showGroupActions(Group group) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.textSecondary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.info_outline,
                  color: AppColors.textSecondary),
              title: const Text('Group info'),
              onTap: () {
                Navigator.pop(context);
                this.context.go(
                    '/groups/${group.id}/info?name=${Uri.encodeComponent(group.name)}');
              },
            ),
            ListTile(
              leading: const Icon(Icons.link,
                  color: AppColors.textSecondary),
              title: const Text('Invite link'),
              onTap: () {
                Navigator.pop(context);
                this.context.go(
                    '/groups/${group.id}/info?name=${Uri.encodeComponent(group.name)}');
              },
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app,
                  color: AppColors.error),
              title: const Text('Leave group',
                  style: TextStyle(color: AppColors.error)),
              onTap: () {
                Navigator.pop(context);
                _confirmLeaveGroup(group);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _confirmLeaveGroup(Group group) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Leave group?'),
        content: Text('Are you sure you want to leave "${group.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final repo = ref.read(groupsRepositoryProvider);
              await repo.leaveGroup(group.id);
              ref.read(groupsProvider.notifier).removeGroup(group.id);
            },
            child: const Text('Leave',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inDays == 0) {
      final h = time.hour.toString().padLeft(2, '0');
      final m = time.minute.toString().padLeft(2, '0');
      return '$h:$m';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return days[time.weekday - 1];
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }
}
