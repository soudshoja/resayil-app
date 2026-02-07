import 'package:flutter/material.dart';
import '../config/theme/app_colors.dart';
import '../models/message.dart';

class MessageBubble extends StatelessWidget {
  final Message message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isOutgoing = message.outgoing;
    return Align(
      alignment: isOutgoing ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: EdgeInsets.only(
          left: isOutgoing ? 64 : 12,
          right: isOutgoing ? 12 : 64,
          top: 2,
          bottom: 2,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isOutgoing ? AppColors.outgoingBubble : AppColors.incomingBubble,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: Radius.circular(isOutgoing ? 12 : 4),
            bottomRight: Radius.circular(isOutgoing ? 4 : 12),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Sender name for group messages
            if (!isOutgoing && message.senderName != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  message.senderName!,
                  style: TextStyle(
                    color: _senderColor(message.senderName!),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

            // Message text
            if (message.text != null)
              Text(
                message.text!,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                ),
              ),

            const SizedBox(height: 4),

            // Time and status
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatTime(message.createdAt),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
                if (isOutgoing) ...[
                  const SizedBox(width: 4),
                  _buildStatusIcon(message.status),
                ],
              ],
            ),
          ],
        ),
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
      const Color(0xFFf0a500),
    ];
    return colors[name.hashCode.abs() % colors.length];
  }
}
