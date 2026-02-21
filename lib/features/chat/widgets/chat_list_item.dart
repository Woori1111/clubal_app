import 'package:clubal_app/core/theme/app_colors.dart';
import 'package:clubal_app/features/chat/models/chat_room.dart';
import 'package:clubal_app/features/chat/widgets/stacked_avatars.dart';
import 'package:flutter/material.dart';

class ChatListItem extends StatelessWidget {
  const ChatListItem({
    super.key,
    required this.room,
    required this.formatTime,
    required this.onTap,
  });

  final ChatRoom room;
  final String Function(DateTime) formatTime;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final onSurfaceVariant = Theme.of(context).colorScheme.onSurfaceVariant;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  StackedAvatars(room: room, size: 48),
                  if (room.isOnline)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).colorScheme.surface,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            room.displayName,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: onSurface,
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          formatTime(room.lastMessageAt),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: isDark
                                    ? AppColors.captionTextDark
                                    : AppColors.captionText,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Opacity(
                            opacity: room.isMuted ? 0.72 : 1,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                if (room.isGroup) ...[
                                  Icon(
                                    Icons.people_outline_rounded,
                                    size: 14,
                                    color: onSurfaceVariant.withValues(alpha: 0.8),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${room.participantCount}',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: onSurfaceVariant,
                                        ),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                Expanded(
                                  child: Row(
                                    children: [
                                      if (room.locationTag != null) ...[
                                        Flexible(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: onSurfaceVariant.withValues(alpha: 0.15),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              room.locationTag!,
                                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                    color: onSurfaceVariant,
                                                    fontSize: 10,
                                                  ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                      ],
                                      if (room.dDayLabel != null) ...[
                                        Text(
                                          room.dDayLabel!,
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                color: AppColors.failure,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 11,
                                              ),
                                        ),
                                        const SizedBox(width: 6),
                                      ],
                                      Expanded(
                                        child: Text(
                                          room.lastMessage.isEmpty ? '메시지 없음' : room.lastMessage,
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                color: onSurfaceVariant,
                                              ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (room.isMuted)
                          Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: Icon(
                              Icons.notifications_off_outlined,
                              size: 16,
                              color: onSurfaceVariant.withValues(alpha: 0.7),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
