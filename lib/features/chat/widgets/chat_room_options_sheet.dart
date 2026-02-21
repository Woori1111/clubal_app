import 'package:clubal_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

void showChatRoomOptionsSheet(
  BuildContext context, {
  required String roomName,
  required bool isMuted,
  required VoidCallback onReport,
  required VoidCallback onBlock,
  required VoidCallback onToggleMute,
  required VoidCallback onLeave,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _ChatRoomOptionsSheet(
      roomName: roomName,
      isMuted: isMuted,
      onReport: onReport,
      onBlock: onBlock,
      onToggleMute: onToggleMute,
      onLeave: onLeave,
    ),
  );
}

class _ChatRoomOptionsSheet extends StatelessWidget {
  const _ChatRoomOptionsSheet({
    required this.roomName,
    required this.isMuted,
    required this.onReport,
    required this.onBlock,
    required this.onToggleMute,
    required this.onLeave,
  });

  final String roomName;
  final bool isMuted;
  final VoidCallback onReport;
  final VoidCallback onBlock;
  final VoidCallback onToggleMute;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: 24 + MediaQuery.of(context).viewPadding.bottom,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '$roomName',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurfaceVariant,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 20),
            _OptionTile(
              icon: Icons.flag_outlined,
              label: '신고하기',
              onTap: () {
                Navigator.of(context).pop();
                onReport();
              },
            ),
            _OptionTile(
              icon: Icons.block_rounded,
              label: '차단하기',
              onTap: () {
                Navigator.of(context).pop();
                onBlock();
              },
            ),
            _OptionTile(
              icon: isMuted ? Icons.notifications_rounded : Icons.notifications_off_outlined,
              label: isMuted ? '알림 켜기' : '알림 끄기',
              subtitle: '이 채팅방에서만',
              onTap: () {
                Navigator.of(context).pop();
                onToggleMute();
              },
            ),
            const SizedBox(height: 12),
            Divider(height: 1, color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
            const SizedBox(height: 12),
            _OptionTile(
              icon: Icons.logout_rounded,
              label: '채팅방 나가기',
              isDestructive: true,
              onTap: () {
                Navigator.of(context).pop();
                onLeave();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.icon,
    required this.label,
    this.subtitle,
    this.isDestructive = false,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final bool isDestructive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textColor = isDestructive ? AppColors.failure : colorScheme.onSurface;
    final iconColor = isDestructive ? AppColors.failure : colorScheme.onSurfaceVariant;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
          child: Row(
            children: [
              Icon(
                icon,
                size: 22,
                color: iconColor,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isDestructive ? '🚪 $label' : label,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: textColor,
                          ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 12,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: iconColor.withValues(alpha: 0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
