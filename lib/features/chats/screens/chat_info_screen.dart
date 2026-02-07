import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/theme/app_colors.dart';
import '../../../core/widgets/chat_avatar.dart';
import '../providers/chats_provider.dart';
import '../repository/chats_repository.dart';

class ChatInfoScreen extends ConsumerWidget {
  final String chatId;
  final String chatName;

  const ChatInfoScreen({
    super.key,
    required this.chatId,
    required this.chatName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messagesAsync = ref.watch(chatMessagesProvider(chatId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Collapsing header with avatar
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: AppColors.appBar,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppColors.surface, AppColors.background],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 60),
                    ChatAvatar(name: chatName, size: 100),
                    const SizedBox(height: 16),
                    Text(
                      chatName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      chatId,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Action buttons
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(Icons.chat, 'Message', () {}),
                  _buildActionButton(Icons.call, 'Audio', () {}),
                  _buildActionButton(Icons.videocam, 'Video', () {}),
                  _buildActionButton(Icons.search, 'Search', () {}),
                ],
              ),
            ),
          ),

          // About section
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('About', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  SizedBox(height: 4),
                  Text('Hey there! I am using WhatsApp.',
                      style: TextStyle(color: AppColors.textPrimary, fontSize: 15)),
                ],
              ),
            ),
          ),

          // Media, links, docs
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.photo, color: AppColors.textSecondary),
                    title: const Text('Media, links, and docs'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        messagesAsync.when(
                          data: (msgs) {
                            final mediaCount = msgs.where((m) =>
                                m.type == 'image' || m.type == 'video' || m.type == 'document')
                                .length;
                            return Text('$mediaCount',
                                style: const TextStyle(color: AppColors.textSecondary));
                          },
                          loading: () => const SizedBox.shrink(),
                          error: (_, __) => const SizedBox.shrink(),
                        ),
                        const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                      ],
                    ),
                    onTap: () {
                      // TODO: navigate to media gallery
                    },
                  ),
                  // Media preview grid
                  messagesAsync.when(
                    data: (msgs) {
                      final mediaMessages = msgs
                          .where((m) => m.type == 'image' && m.mediaUrl != null)
                          .take(6)
                          .toList();
                      if (mediaMessages.isEmpty) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 4,
                            mainAxisSpacing: 4,
                          ),
                          itemCount: mediaMessages.length,
                          itemBuilder: (context, index) {
                            return Container(
                              decoration: BoxDecoration(
                                color: AppColors.chatBg,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Icon(Icons.image, color: AppColors.textSecondary),
                            );
                          },
                        ),
                      );
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),

          // Labels
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.label, color: AppColors.textSecondary),
                title: const Text('Labels'),
                trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                onTap: () {
                  // TODO: show label picker
                },
              ),
            ),
          ),

          // Actions
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.archive, color: AppColors.textSecondary),
                    title: const Text('Archive chat'),
                    onTap: () async {
                      final repo = ref.read(chatsRepositoryProvider);
                      await repo.archiveChat(chatId);
                      ref.read(chatsProvider.notifier).refresh();
                      if (context.mounted) {
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      }
                    },
                  ),
                  const Divider(height: 1, indent: 56),
                  ListTile(
                    leading: const Icon(Icons.check_circle, color: AppColors.textSecondary),
                    title: const Text('Resolve chat'),
                    onTap: () async {
                      final repo = ref.read(chatsRepositoryProvider);
                      await repo.resolveChat(chatId);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Chat resolved')),
                        );
                      }
                    },
                  ),
                  const Divider(height: 1, indent: 56),
                  ListTile(
                    leading: const Icon(Icons.block, color: AppColors.error),
                    title: const Text('Block', style: TextStyle(color: AppColors.error)),
                    onTap: () {},
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

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.accent),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }
}
