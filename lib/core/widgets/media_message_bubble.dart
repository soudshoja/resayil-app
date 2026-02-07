import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../config/theme/app_colors.dart';
import '../models/message.dart';

class MediaMessageBubble extends StatelessWidget {
  final Message message;

  const MediaMessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isOutgoing = message.outgoing;
    return Align(
      alignment: isOutgoing ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.70,
        ),
        margin: EdgeInsets.only(
          left: isOutgoing ? 64 : 12,
          right: isOutgoing ? 12 : 64,
          top: 2,
          bottom: 2,
        ),
        decoration: BoxDecoration(
          color: isOutgoing ? AppColors.outgoingBubble : AppColors.incomingBubble,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: Radius.circular(isOutgoing ? 12 : 4),
            bottomRight: Radius.circular(isOutgoing ? 4 : 12),
          ),
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sender name for group
            if (!isOutgoing && message.senderName != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                child: Text(
                  message.senderName!,
                  style: TextStyle(
                    color: _senderColor(message.senderName!),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

            // Media content
            _buildMediaContent(context),

            // Caption if present
            if (message.mediaCaption != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
                child: Text(
                  message.mediaCaption!,
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
                ),
              ),

            // Time and status
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatTime(message.createdAt),
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                  ),
                  if (isOutgoing) ...[
                    const SizedBox(width: 4),
                    _buildStatusIcon(message.status),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaContent(BuildContext context) {
    switch (message.type) {
      case 'image':
        return _buildImageContent(context);
      case 'video':
        return _buildVideoThumbnail();
      case 'document':
        return _buildDocumentContent();
      case 'audio':
        return _buildAudioContent();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildImageContent(BuildContext context) {
    if (message.mediaUrl != null) {
      return GestureDetector(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => _FullScreenImage(url: message.mediaUrl!),
          ));
        },
        child: CachedNetworkImage(
          imageUrl: message.mediaUrl!,
          width: double.infinity,
          height: 200,
          fit: BoxFit.cover,
          placeholder: (_, __) => Container(
            height: 200,
            color: AppColors.chatBg,
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accent),
            ),
          ),
          errorWidget: (_, __, ___) => Container(
            height: 200,
            color: AppColors.chatBg,
            child: const Icon(Icons.broken_image, color: AppColors.textSecondary, size: 40),
          ),
        ),
      );
    }
    return Container(
      height: 200,
      color: AppColors.chatBg,
      child: const Center(
        child: Icon(Icons.image, color: AppColors.textSecondary, size: 40),
      ),
    );
  }

  Widget _buildVideoThumbnail() {
    return Container(
      height: 200,
      color: AppColors.chatBg,
      child: const Center(
        child: CircleAvatar(
          radius: 28,
          backgroundColor: Colors.black45,
          child: Icon(Icons.play_arrow, color: Colors.white, size: 36),
        ),
      ),
    );
  }

  Widget _buildDocumentContent() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF1a73e8).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.insert_drive_file, color: Color(0xFF1a73e8), size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.fileName ?? 'Document',
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (message.mimeType != null)
                  Text(
                    message.mimeType!.toUpperCase(),
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                  ),
              ],
            ),
          ),
          const Icon(Icons.download, color: AppColors.textSecondary, size: 20),
        ],
      ),
    );
  }

  Widget _buildAudioContent() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.accent,
            child: const Icon(Icons.play_arrow, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Text('0:00', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildStatusIcon(String status) {
    switch (status) {
      case 'sending':
        return const Icon(Icons.access_time, size: 14, color: AppColors.textSecondary);
      case 'sent':
        return const Icon(Icons.check, size: 14, color: AppColors.textSecondary);
      case 'delivered':
        return const Icon(Icons.done_all, size: 14, color: AppColors.textSecondary);
      case 'read':
        return const Icon(Icons.done_all, size: 14, color: AppColors.readTicks);
      case 'failed':
        return const Icon(Icons.error_outline, size: 14, color: AppColors.error);
      default:
        return const SizedBox.shrink();
    }
  }

  String _formatTime(DateTime time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Color _senderColor(String name) {
    final colors = [
      const Color(0xFF53bdeb),
      const Color(0xFFe97451),
      const Color(0xFF00a884),
      const Color(0xFFff6b6b),
      const Color(0xFF7c5cbf),
    ];
    return colors[name.hashCode.abs() % colors.length];
  }
}

class _FullScreenImage extends StatelessWidget {
  final String url;

  const _FullScreenImage({required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: InteractiveViewer(
          child: CachedNetworkImage(
            imageUrl: url,
            fit: BoxFit.contain,
            placeholder: (_, __) => const Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            ),
            errorWidget: (_, __, ___) => const Icon(
              Icons.broken_image,
              color: Colors.white54,
              size: 60,
            ),
          ),
        ),
      ),
    );
  }
}
