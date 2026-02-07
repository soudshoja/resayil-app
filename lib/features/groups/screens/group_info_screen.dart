import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/theme/app_colors.dart';
import '../../../core/models/group.dart';
import '../../../core/widgets/chat_avatar.dart';
import '../providers/groups_provider.dart';
import '../repository/groups_repository.dart';

class GroupInfoScreen extends ConsumerStatefulWidget {
  final String groupId;
  final String groupName;

  const GroupInfoScreen({
    super.key,
    required this.groupId,
    required this.groupName,
  });

  @override
  ConsumerState<GroupInfoScreen> createState() => _GroupInfoScreenState();
}

class _GroupInfoScreenState extends ConsumerState<GroupInfoScreen> {
  @override
  Widget build(BuildContext context) {
    final groupAsync = ref.watch(groupDetailProvider(widget.groupId));
    final participantsAsync =
        ref.watch(groupParticipantsProvider(widget.groupId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Collapsing app bar with group avatar
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: AppColors.appBar,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppColors.accent, AppColors.background],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 48),
                    ChatAvatar(
                      name: widget.groupName,
                      size: 80,
                      isGroup: true,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.groupName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    groupAsync.when(
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                      data: (group) => Text(
                        'Group · ${group?.participantCount ?? 0} participants',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Actions row
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _actionButton(Icons.message, 'Message', () {
                    context.go(
                        '/groups/${widget.groupId}?name=${Uri.encodeComponent(widget.groupName)}');
                  }),
                  _actionButton(Icons.call, 'Audio', () {}),
                  _actionButton(Icons.videocam, 'Video', () {}),
                  _actionButton(Icons.search, 'Search', () {}),
                ],
              ),
            ),
          ),

          // Description
          groupAsync.when(
            loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
            error: (_, __) => const SliverToBoxAdapter(child: SizedBox.shrink()),
            data: (group) {
              if (group?.description == null || group!.description!.isEmpty) {
                return const SliverToBoxAdapter(child: SizedBox.shrink());
              }
              return SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Description',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        group.description!,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Invite link section
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading:
                        const Icon(Icons.link, color: AppColors.accent),
                    title: const Text('Invite link'),
                    subtitle: const Text(
                      'Tap to copy invite link',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 12),
                    ),
                    onTap: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      final repo = ref.read(groupsRepositoryProvider);
                      final link =
                          await repo.getInviteLink(widget.groupId);
                      if (link != null) {
                        await Clipboard.setData(ClipboardData(text: link));
                        if (mounted) {
                          messenger.showSnackBar(
                            const SnackBar(
                                content: Text('Invite link copied!')),
                          );
                        }
                      }
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.refresh,
                        color: AppColors.textSecondary),
                    title: const Text('Reset invite link'),
                    onTap: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      final repo = ref.read(groupsRepositoryProvider);
                      final link = await repo
                          .regenerateInviteLink(widget.groupId);
                      if (link != null && mounted) {
                        await Clipboard.setData(ClipboardData(text: link));
                        messenger.showSnackBar(
                          const SnackBar(
                              content:
                                  Text('New invite link copied!')),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),

          // Participants section header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  participantsAsync.when(
                    loading: () => const Text(
                      'Participants',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    error: (_, __) => const Text('Participants'),
                    data: (participants) => Text(
                      '${participants.length} participants',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Add participant button
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12)),
              ),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppColors.accent,
                  child:
                      Icon(Icons.person_add, color: Colors.white, size: 20),
                ),
                title: const Text('Add participants'),
                onTap: () {
                  context.go(
                      '/groups/${widget.groupId}/add-participants?name=${Uri.encodeComponent(widget.groupName)}');
                },
              ),
            ),
          ),

          // Participant list
          participantsAsync.when(
            loading: () => const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child:
                      CircularProgressIndicator(color: AppColors.accent),
                ),
              ),
            ),
            error: (error, _) => SliverToBoxAdapter(
              child: Center(
                child: Text(error.toString(),
                    style:
                        const TextStyle(color: AppColors.textSecondary)),
              ),
            ),
            data: (participants) => SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final participant = participants[index];
                  final isLast = index == participants.length - 1;
                  return Container(
                    margin: EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: isLast ? 0 : 0,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: isLast
                          ? const BorderRadius.vertical(
                              bottom: Radius.circular(12))
                          : null,
                    ),
                    child: ListTile(
                      leading: ChatAvatar(
                        name: participant.name,
                        imageUrl: participant.avatar,
                        size: 40,
                      ),
                      title: Text(participant.name),
                      subtitle: participant.phone != null
                          ? Text(
                              participant.phone!,
                              style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13),
                            )
                          : null,
                      trailing: participant.role == 'admin'
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.accent
                                    .withValues(alpha: 0.2),
                                borderRadius:
                                    BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Admin',
                                style: TextStyle(
                                  color: AppColors.accent,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                          : null,
                      onLongPress: () =>
                          _showParticipantActions(participant),
                    ),
                  );
                },
                childCount: participants.length,
              ),
            ),
          ),

          // Bottom actions
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.exit_to_app,
                        color: AppColors.error),
                    title: const Text('Leave group',
                        style: TextStyle(color: AppColors.error)),
                    onTap: _confirmLeaveGroup,
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  Widget _actionButton(
      IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.accent, size: 22),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }

  void _showParticipantActions(Participant participant) {
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                participant.name,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            if (participant.role == 'member')
              ListTile(
                leading: const Icon(Icons.admin_panel_settings,
                    color: AppColors.accent),
                title: const Text('Make admin'),
                onTap: () async {
                  Navigator.pop(context);
                  final repo = ref.read(groupsRepositoryProvider);
                  await repo.promoteParticipant(
                      widget.groupId, participant.id);
                  ref.invalidate(
                      groupParticipantsProvider(widget.groupId));
                },
              ),
            if (participant.role == 'admin')
              ListTile(
                leading: const Icon(Icons.person,
                    color: AppColors.textSecondary),
                title: const Text('Remove as admin'),
                onTap: () async {
                  Navigator.pop(context);
                  final repo = ref.read(groupsRepositoryProvider);
                  await repo.demoteParticipant(
                      widget.groupId, participant.id);
                  ref.invalidate(
                      groupParticipantsProvider(widget.groupId));
                },
              ),
            ListTile(
              leading:
                  const Icon(Icons.remove_circle, color: AppColors.error),
              title: const Text('Remove from group',
                  style: TextStyle(color: AppColors.error)),
              onTap: () async {
                Navigator.pop(context);
                _confirmRemoveParticipant(participant);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _confirmRemoveParticipant(Participant participant) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Remove participant?'),
        content: Text(
            'Remove ${participant.name} from this group?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final repo = ref.read(groupsRepositoryProvider);
              await repo.removeParticipant(
                  widget.groupId, participant.id);
              ref.invalidate(
                  groupParticipantsProvider(widget.groupId));
            },
            child: const Text('Remove',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _confirmLeaveGroup() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Leave group?'),
        content: Text(
            'Are you sure you want to leave "${widget.groupName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final repo = ref.read(groupsRepositoryProvider);
              final router = GoRouter.of(context);
              await repo.leaveGroup(widget.groupId);
              ref.read(groupsProvider.notifier).removeGroup(widget.groupId);
              if (mounted) router.go('/groups');
            },
            child: const Text('Leave',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
