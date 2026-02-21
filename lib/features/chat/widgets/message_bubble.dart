import 'package:clubal_app/core/theme/app_colors.dart';
import 'package:clubal_app/core/utils/date_utils.dart' as app_date_utils;
import 'package:clubal_app/features/chat/models/message.dart';
import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    this.showSenderName = false,
  });

  final Message message;
  final bool showSenderName;

  static const _duration = Duration(milliseconds: 170);
  static const _radiusMine = 22.0;
  static const _radiusOther = 19.0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final captionColor = isDark ? AppColors.captionTextDark : AppColors.captionText;
    final isMe = message.isMe;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: _duration,
      builder: (context, value, child) {
        final slideOffset = isMe ? 24.0 * (1 - value) : -24.0 * (1 - value);
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(slideOffset, 6 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Padding(
        padding: EdgeInsets.only(
          left: isMe ? 40 : 8,
          right: isMe ? 8 : 40,
          top: 4,
          bottom: 4,
        ),
        child: Row(
          mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(
              flex: isMe ? 0 : 1,
              child: SizedBox(
                width: isMe ? null : double.infinity,
                child: Column(
                  crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    if (showSenderName && message.senderName != null && !message.isMe)
                      Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 2),
                        child: Text(
                          message.senderName!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: captionColor,
                                fontSize: 11,
                              ),
                        ),
                      ),
                    Material(
                      color: isMe
                          ? (isDark
                              ? AppColors.glassBorderDark.withValues(alpha: 0.4)
                              : AppColors.brandPrimary.withValues(alpha: 0.24))
                          : Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest
                              .withValues(alpha: 0.85),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(isMe ? _radiusMine : 6),
                        topRight: Radius.circular(isMe ? 6 : _radiusMine),
                        bottomLeft: Radius.circular(isMe ? _radiusMine : _radiusOther),
                        bottomRight: Radius.circular(isMe ? _radiusOther : _radiusMine),
                      ),
                      elevation: 1,
                      shadowColor: Colors.black.withValues(alpha: 0.04),
                      child: InkWell(
                        onTap: message.type == MessageType.image && message.imageUrl != null
                            ? () => _showImageModal(context, message.imageUrl!)
                            : null,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(isMe ? _radiusMine : 6),
                          topRight: Radius.circular(isMe ? 6 : _radiusMine),
                          bottomLeft: Radius.circular(isMe ? _radiusMine : _radiusOther),
                          bottomRight: Radius.circular(isMe ? _radiusOther : _radiusMine),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          child: _buildContent(context, isDark, isMe),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                      children: [
                        Text(
                          app_date_utils.formatRelativeTime(message.createdAt),
                          style: TextStyle(
                            fontSize: 11,
                            color: captionColor,
                          ),
                        ),
                        if (isMe && message.isRead) ...[
                          const SizedBox(width: 4),
                          Text(
                            '읽음',
                            style: TextStyle(
                              fontSize: 10,
                              color: captionColor.withValues(alpha: 0.75),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showImageModal(BuildContext context, String url) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: InteractiveViewer(
            minScale: 0.5,
            maxScale: 4,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                url,
                fit: BoxFit.contain,
                loadingBuilder: (_, child, progress) {
                  if (progress == null) return child;
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, bool isDark, bool isMe) {
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final effectiveColor = isMe ? textColor : textColor.withValues(alpha: 0.9);

    switch (message.type) {
      case MessageType.text:
      case MessageType.system:
        return Text(
          message.displayContent,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: effectiveColor,
                height: 1.4,
              ),
        );
      case MessageType.image:
        final url = message.imageUrl ?? '';
        if (url.isEmpty) return const SizedBox.shrink();
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.95, end: 1.0),
          duration: const Duration(milliseconds: 150),
          builder: (context, value, child) => Transform.scale(
            scale: value,
            child: child,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              url,
              width: 200,
              fit: BoxFit.cover,
              loadingBuilder: (_, child, progress) {
                if (progress == null) return child;
                return SizedBox(
                  width: 200,
                  height: 150,
                  child: Center(
                    child: CircularProgressIndicator(
                      value: progress.expectedTotalBytes != null
                          ? progress.cumulativeBytesLoaded /
                              progress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                );
              },
              errorBuilder: (_, __, ___) => Container(
                width: 200,
                height: 150,
                color: Colors.grey.shade300,
                child: Icon(Icons.broken_image_outlined, color: Colors.grey.shade600),
              ),
            ),
          ),
        );
    }
  }
}
