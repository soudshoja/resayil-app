import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/theme/app_colors.dart';
import '../../../core/widgets/chat_avatar.dart';
import '../../../core/widgets/search_bar_widget.dart';
import '../../../core/models/chat.dart';
import '../providers/chats_provider.dart';
import '../repository/chats_repository.dart';

class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({super.key});

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen> {
  final _scrollController = ScrollController();
  String _searchQuery = '';

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
      final notifier = ref.read(chatsProvider.notifier);
      if (notifier.hasMore) {
        notifier.loadMore();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatsAsync = ref.watch(filteredChatsProvider);
    final currentFilter = ref.watch(chatFilterProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Resayil',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt_outlined),
            onPressed: () {},
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'archived') {
                ref.read(chatFilterProvider.notifier).state = ChatFilter.archived;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'new_group', child: Text('New group')),
              const PopupMenuItem(value: 'labels', child: Text('Labels')),
              const PopupMenuItem(value: 'archived', child: Text('Archived')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          SearchBarWidget(
            hintText: 'Search chats...',
            onChanged: (q) => setState(() => _searchQuery = q),
          ),

          // Filter chips
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: ChatFilter.values.map((filter) {
                final isActive = currentFilter == filter;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    selected: isActive,
                    label: Text(_filterLabel(filter)),
                    labelStyle: TextStyle(
                      color: isActive ? Colors.white : AppColors.textSecondary,
                      fontSize: 13,
                    ),
                    backgroundColor: AppColors.surface,
                    selectedColor: AppColors.accent,
                    checkmarkColor: Colors.white,
                    side: BorderSide.none,
                    onSelected: (_) {
                      ref.read(chatFilterProvider.notifier).state = filter;
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 4),

          Expanded(
            child: chatsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.accent),
              ),
              error: (error, _) => _buildErrorState(error),
              data: (chats) {
                final filtered = _searchQuery.isEmpty
                    ? chats
                    : chats
                        .where((c) =>
                            c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                            (c.phone?.contains(_searchQuery) ?? false))
                        .toList();

                if (filtered.isEmpty) return _buildEmptyState();

                return RefreshIndicator(
                  color: AppColors.accent,
                  onRefresh: () => ref.read(chatsProvider.notifier).refresh(),
                  child: ListView.separated(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: filtered.length + (ref.read(chatsProvider.notifier).hasMore ? 1 : 0),
                    separatorBuilder: (_, __) => const Padding(
                      padding: EdgeInsets.only(left: 76),
                      child: Divider(height: 1),
                    ),
                    itemBuilder: (context, index) {
                      if (index >= filtered.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.accent,
                              ),
                            ),
                          ),
                        );
                      }
                      return _buildDismissibleChatTile(filtered[index]);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: navigate to contact picker / new chat
        },
        child: const Icon(Icons.chat),
      ),
    );
  }

  Widget _buildDismissibleChatTile(Chat chat) {
    return Dismissible(
      key: Key(chat.id),
      background: Container(
        color: AppColors.accent,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 24),
        child: const Icon(Icons.archive, color: Colors.white),
      ),
      secondaryBackground: Container(
        color: const Color(0xFF1a73e8),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Icon(Icons.check_circle, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        final repo = ref.read(chatsRepositoryProvider);
        if (direction == DismissDirection.startToEnd) {
          // Archive
          try {
            await repo.archiveChat(chat.id);
            ref.read(chatsProvider.notifier).removeChat(chat.id);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${chat.name} archived'),
                  action: SnackBarAction(
                    label: 'Undo',
                    onPressed: () async {
                      await repo.unarchiveChat(chat.id);
                      ref.read(chatsProvider.notifier).refresh();
                    },
                  ),
                ),
              );
            }
            return true;
          } catch (_) {
            return false;
          }
        } else {
          // Resolve
          try {
            await repo.resolveChat(chat.id);
            ref.read(chatsProvider.notifier).updateChat(
              chat.copyWith(resolved: true),
            );
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${chat.name} resolved')),
              );
            }
            return false; // don't remove from list
          } catch (_) {
            return false;
          }
        }
      },
      child: _buildChatTile(chat),
    );
  }

  Widget _buildChatTile(Chat chat) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: ChatAvatar(
        name: chat.name,
        imageUrl: chat.avatar,
        showOnlineIndicator: true,
        isOnline: chat.status == 'online',
      ),
      title: Row(
        children: [
          if (chat.resolved)
            const Padding(
              padding: EdgeInsets.only(right: 4),
              child: Icon(Icons.check_circle, size: 16, color: AppColors.accent),
            ),
          Expanded(
            child: Text(
              chat.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: chat.unreadCount > 0 ? FontWeight.bold : FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
          Text(
            _formatTime(chat.lastMessageTime),
            style: TextStyle(
              fontSize: 12,
              color: chat.unreadCount > 0
                  ? AppColors.accent
                  : AppColors.textSecondary,
            ),
          ),
        ],
      ),
      subtitle: Row(
        children: [
          // Labels
          if (chat.labels.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Icon(
                Icons.label,
                size: 14,
                color: _labelColor(chat.labels.first),
              ),
            ),
          Expanded(
            child: Text(
              chat.status == 'typing'
                  ? 'typing...'
                  : chat.lastMessage ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: chat.status == 'typing'
                    ? AppColors.accent
                    : AppColors.textSecondary,
                fontSize: 14,
                fontStyle: chat.status == 'typing'
                    ? FontStyle.italic
                    : FontStyle.normal,
              ),
            ),
          ),
          if (chat.unreadCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.badge,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                chat.unreadCount > 99 ? '99+' : '${chat.unreadCount}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          if (chat.pinned)
            const Padding(
              padding: EdgeInsets.only(left: 4),
              child: Icon(Icons.push_pin, size: 16, color: AppColors.textSecondary),
            ),
        ],
      ),
      onTap: () {
        context.go('/chats/${chat.id}?name=${Uri.encodeComponent(chat.name)}');
      },
      onLongPress: () => _showChatActions(chat),
    );
  }

  void _showChatActions(Chat chat) {
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
              leading: const Icon(Icons.archive, color: AppColors.textSecondary),
              title: Text(chat.archived ? 'Unarchive' : 'Archive'),
              onTap: () async {
                Navigator.pop(context);
                final repo = ref.read(chatsRepositoryProvider);
                if (chat.archived) {
                  await repo.unarchiveChat(chat.id);
                } else {
                  await repo.archiveChat(chat.id);
                }
                ref.read(chatsProvider.notifier).refresh();
              },
            ),
            ListTile(
              leading: const Icon(Icons.check_circle, color: AppColors.textSecondary),
              title: const Text('Resolve'),
              onTap: () async {
                Navigator.pop(context);
                final repo = ref.read(chatsRepositoryProvider);
                await repo.resolveChat(chat.id);
                ref.read(chatsProvider.notifier).updateChat(
                  chat.copyWith(resolved: true),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.label, color: AppColors.textSecondary),
              title: const Text('Labels'),
              onTap: () {
                Navigator.pop(context);
                _showLabelPicker(chat);
              },
            ),
            if (chat.pinned)
              ListTile(
                leading: const Icon(Icons.push_pin_outlined, color: AppColors.textSecondary),
                title: const Text('Unpin'),
                onTap: () => Navigator.pop(context),
              )
            else
              ListTile(
                leading: const Icon(Icons.push_pin, color: AppColors.textSecondary),
                title: const Text('Pin'),
                onTap: () => Navigator.pop(context),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showLabelPicker(Chat chat) {
    final labelsAsync = ref.read(labelsProvider);
    labelsAsync.whenData((labels) {
      final selectedLabels = List<String>.from(chat.labels);
      showModalBottomSheet(
        context: context,
        backgroundColor: AppColors.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (context) => StatefulBuilder(
          builder: (context, setSheetState) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Labels',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                ...labels.map((label) {
                  final id = label['id']?.toString() ?? '';
                  final name = label['name']?.toString() ?? '';
                  final isSelected = selectedLabels.contains(id);
                  return CheckboxListTile(
                    value: isSelected,
                    title: Text(name),
                    activeColor: AppColors.accent,
                    onChanged: (checked) {
                      setSheetState(() {
                        if (checked == true) {
                          selectedLabels.add(id);
                        } else {
                          selectedLabels.remove(id);
                        }
                      });
                    },
                  );
                }),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        final repo = ref.read(chatsRepositoryProvider);
                        await repo.setChatLabels(chat.id, selectedLabels);
                        ref.read(chatsProvider.notifier).updateChat(
                          chat.copyWith(labels: selectedLabels),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                      ),
                      child: const Text('Save'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildEmptyState() {
    final filter = ref.watch(chatFilterProvider);
    final label = filter == ChatFilter.all ? 'No chats yet' : 'No ${_filterLabel(filter).toLowerCase()} chats';
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_outlined, size: 64, color: AppColors.textSecondary.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.error),
          const SizedBox(height: 16),
          Text(error.toString(), style: const TextStyle(color: AppColors.textSecondary), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () => ref.read(chatsProvider.notifier).refresh(),
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  String _filterLabel(ChatFilter filter) {
    switch (filter) {
      case ChatFilter.all:
        return 'All';
      case ChatFilter.unread:
        return 'Unread';
      case ChatFilter.archived:
        return 'Archived';
      case ChatFilter.resolved:
        return 'Resolved';
    }
  }

  Color _labelColor(String label) {
    final colors = [
      AppColors.accent,
      const Color(0xFF53bdeb),
      const Color(0xFFe97451),
      const Color(0xFFff6b6b),
      const Color(0xFF7c5cbf),
    ];
    return colors[label.hashCode.abs() % colors.length];
  }

  String _formatTime(DateTime? time) {
    if (time == null) return '';
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inDays == 0) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) {
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return days[time.weekday - 1];
    }
    return '${time.day}/${time.month}/${time.year}';
  }
}
