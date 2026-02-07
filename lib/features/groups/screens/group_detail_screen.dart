import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/config/theme/app_colors.dart';
import '../../../core/models/message.dart';
import '../../../core/widgets/chat_avatar.dart';
import '../../../core/widgets/chat_input_bar.dart';
import '../../../core/widgets/message_bubble.dart';
import '../providers/groups_provider.dart';
import '../repository/groups_repository.dart';

class GroupDetailScreen extends ConsumerStatefulWidget {
  final String groupId;
  final String groupName;

  const GroupDetailScreen({
    super.key,
    required this.groupId,
    required this.groupName,
  });

  @override
  ConsumerState<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends ConsumerState<GroupDetailScreen> {
  final _scrollController = ScrollController();
  final _imagePicker = ImagePicker();
  bool _isSending = false;

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
      final notifier =
          ref.read(groupMessagesProvider(widget.groupId).notifier);
      if (notifier.hasMore) {
        notifier.loadMore();
      }
    }
  }

  Future<void> _sendTextMessage(String text) async {
    if (_isSending) return;
    setState(() => _isSending = true);

    final localMessage = Message(
      id: 'local_${DateTime.now().millisecondsSinceEpoch}',
      chatId: widget.groupId,
      type: 'text',
      text: text,
      outgoing: true,
      status: 'sending',
      createdAt: DateTime.now(),
    );
    ref
        .read(groupMessagesProvider(widget.groupId).notifier)
        .addMessage(localMessage);

    try {
      final repo = ref.read(groupsRepositoryProvider);
      final sent = await repo.sendTextMessage(widget.groupId, text);
      if (sent != null) {
        ref
            .read(groupMessagesProvider(widget.groupId).notifier)
            .updateMessageStatus(localMessage.id, 'sent');
      }
    } catch (e) {
      ref
          .read(groupMessagesProvider(widget.groupId).notifier)
          .updateMessageStatus(localMessage.id, 'failed');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send: $e'),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: () => _sendTextMessage(text),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<void> _sendMediaMessage(String type) async {
    final XFile? file;
    if (type == 'image') {
      file = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
    } else if (type == 'video') {
      file = await _imagePicker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 5),
      );
    } else {
      file = await _imagePicker.pickImage(source: ImageSource.gallery);
    }

    if (file == null) return;

    final localMessage = Message(
      id: 'local_${DateTime.now().millisecondsSinceEpoch}',
      chatId: widget.groupId,
      type: type,
      text: file.name,
      outgoing: true,
      status: 'sending',
      fileName: file.name,
      createdAt: DateTime.now(),
    );
    ref
        .read(groupMessagesProvider(widget.groupId).notifier)
        .addMessage(localMessage);

    try {
      final repo = ref.read(groupsRepositoryProvider);
      await repo.sendMediaMessage(
        groupId: widget.groupId,
        type: type,
        filePath: file.path,
        fileName: file.name,
      );
      ref
          .read(groupMessagesProvider(widget.groupId).notifier)
          .updateMessageStatus(localMessage.id, 'sent');
    } catch (_) {
      ref
          .read(groupMessagesProvider(widget.groupId).notifier)
          .updateMessageStatus(localMessage.id, 'failed');
    }
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _attachmentOption(
                icon: Icons.photo,
                color: const Color(0xFF7c5cbf),
                label: 'Gallery',
                onTap: () {
                  Navigator.pop(context);
                  _sendMediaMessage('image');
                },
              ),
              _attachmentOption(
                icon: Icons.camera_alt,
                color: const Color(0xFFe91e63),
                label: 'Camera',
                onTap: () async {
                  Navigator.pop(context);
                  final file = await _imagePicker.pickImage(
                    source: ImageSource.camera,
                    maxWidth: 1920,
                    maxHeight: 1920,
                    imageQuality: 85,
                  );
                  if (file != null) {
                    final localMessage = Message(
                      id: 'local_${DateTime.now().millisecondsSinceEpoch}',
                      chatId: widget.groupId,
                      type: 'image',
                      text: file.name,
                      outgoing: true,
                      status: 'sending',
                      createdAt: DateTime.now(),
                    );
                    ref
                        .read(
                            groupMessagesProvider(widget.groupId).notifier)
                        .addMessage(localMessage);
                    try {
                      final repo = ref.read(groupsRepositoryProvider);
                      await repo.sendMediaMessage(
                        groupId: widget.groupId,
                        type: 'image',
                        filePath: file.path,
                        fileName: file.name,
                      );
                      ref
                          .read(groupMessagesProvider(widget.groupId)
                              .notifier)
                          .updateMessageStatus(localMessage.id, 'sent');
                    } catch (_) {
                      ref
                          .read(groupMessagesProvider(widget.groupId)
                              .notifier)
                          .updateMessageStatus(localMessage.id, 'failed');
                    }
                  }
                },
              ),
              _attachmentOption(
                icon: Icons.videocam,
                color: const Color(0xFFe97451),
                label: 'Video',
                onTap: () {
                  Navigator.pop(context);
                  _sendMediaMessage('video');
                },
              ),
              _attachmentOption(
                icon: Icons.insert_drive_file,
                color: const Color(0xFF1a73e8),
                label: 'Document',
                onTap: () {
                  Navigator.pop(context);
                  _sendMediaMessage('document');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _attachmentOption({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: color,
            child: Icon(icon, color: Colors.white, size: 26),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync =
        ref.watch(groupMessagesProvider(widget.groupId));

    return Scaffold(
      backgroundColor: AppColors.chatBg,
      appBar: AppBar(
        backgroundColor: AppColors.appBar,
        titleSpacing: 0,
        title: GestureDetector(
          onTap: () {
            context.go(
                '/groups/${widget.groupId}/info?name=${Uri.encodeComponent(widget.groupName)}');
          },
          child: Row(
            children: [
              ChatAvatar(
                  name: widget.groupName, size: 38, isGroup: true),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.groupName,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Text(
                      'tap here for group info',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
              icon: const Icon(Icons.videocam), onPressed: () {}),
          IconButton(icon: const Icon(Icons.call), onPressed: () {}),
          PopupMenuButton<String>(
            onSelected: (value) async {
              final messenger = ScaffoldMessenger.of(context);
              final router = GoRouter.of(context);
              switch (value) {
                case 'info':
                  router.go(
                      '/groups/${widget.groupId}/info?name=${Uri.encodeComponent(widget.groupName)}');
                  break;
                case 'invite':
                  final repo = ref.read(groupsRepositoryProvider);
                  final link =
                      await repo.getInviteLink(widget.groupId);
                  if (link != null && mounted) {
                    await Clipboard.setData(ClipboardData(text: link));
                    messenger.showSnackBar(
                      const SnackBar(
                          content: Text('Invite link copied!')),
                    );
                  }
                  break;
                case 'leave':
                  if (mounted) _confirmLeaveGroup();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                  value: 'info', child: Text('Group info')),
              const PopupMenuItem(
                  value: 'media', child: Text('Media')),
              const PopupMenuItem(
                  value: 'invite', child: Text('Invite link')),
              const PopupMenuItem(
                  value: 'leave', child: Text('Leave group')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              loading: () => const Center(
                child:
                    CircularProgressIndicator(color: AppColors.accent),
              ),
              error: (error, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: AppColors.error),
                    const SizedBox(height: 12),
                    Text(error.toString(),
                        style: const TextStyle(
                            color: AppColors.textSecondary),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: () => ref
                          .read(groupMessagesProvider(widget.groupId)
                              .notifier)
                          .refresh(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              data: (messages) {
                if (messages.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline,
                            size: 48,
                            color: AppColors.textSecondary),
                        SizedBox(height: 12),
                        Text('No messages yet. Say hello!',
                            style: TextStyle(
                                color: AppColors.textSecondary)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg =
                        messages[messages.length - 1 - index];
                    final prevMsg = index < messages.length - 1
                        ? messages[messages.length - 2 - index]
                        : null;
                    return Column(
                      children: [
                        if (_shouldShowDate(msg, prevMsg))
                          _buildDateSeparator(msg.createdAt),
                        GestureDetector(
                          onLongPress: () =>
                              _showMessageActions(msg),
                          child: MessageBubble(message: msg),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          ChatInputBar(
            onSend: _sendTextMessage,
            onAttachment: _showAttachmentOptions,
          ),
        ],
      ),
    );
  }

  bool _shouldShowDate(Message current, Message? previous) {
    if (previous == null) return true;
    return current.createdAt.day != previous.createdAt.day ||
        current.createdAt.month != previous.createdAt.month ||
        current.createdAt.year != previous.createdAt.year;
  }

  Widget _buildDateSeparator(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    String label;
    if (diff.inDays == 0) {
      label = 'Today';
    } else if (diff.inDays == 1) {
      label = 'Yesterday';
    } else {
      label = '${date.day}/${date.month}/${date.year}';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: const TextStyle(
              color: AppColors.textSecondary, fontSize: 12),
        ),
      ),
    );
  }

  void _showMessageActions(Message message) {
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
            if (message.text != null)
              ListTile(
                leading: const Icon(Icons.copy,
                    color: AppColors.textSecondary),
                title: const Text('Copy'),
                onTap: () {
                  Clipboard.setData(
                      ClipboardData(text: message.text!));
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Copied to clipboard')),
                  );
                },
              ),
            if (message.outgoing && message.status == 'failed')
              ListTile(
                leading: const Icon(Icons.refresh,
                    color: AppColors.textSecondary),
                title: const Text('Retry'),
                onTap: () {
                  Navigator.pop(context);
                  if (message.text != null) {
                    _sendTextMessage(message.text!);
                  }
                },
              ),
            ListTile(
              leading: const Icon(Icons.info_outline,
                  color: AppColors.textSecondary),
              title: const Text('Message info'),
              subtitle: Text(
                'Status: ${message.status}${message.senderName != null ? '\nFrom: ${message.senderName}' : ''}',
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary),
              ),
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 8),
          ],
        ),
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
              ref
                  .read(groupsProvider.notifier)
                  .removeGroup(widget.groupId);
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
