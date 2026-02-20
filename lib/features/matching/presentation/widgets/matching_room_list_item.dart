import 'package:clubal_app/core/theme/app_colors.dart';
import 'package:clubal_app/core/theme/app_glass_styles.dart';
import 'package:clubal_app/core/widgets/liquid_pressable.dart';
import 'package:clubal_app/features/matching/models/piece_room.dart';
import 'package:clubal_app/features/matching/presentation/widgets/matching_glass_card.dart';
import 'package:flutter/material.dart';

/// 매칭 목록 한 항목 (글라스 카드 + 방 정보)
class MatchingRoomListItem extends StatelessWidget {
  const MatchingRoomListItem({
    super.key,
    required this.room,
    this.onTap,
  });

  final PieceRoom room;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return LiquidPressable(
      onTap: onTap,
      child: MatchingGlassCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: colorScheme.surfaceContainerHighest,
              foregroundColor: colorScheme.onSurface,
              backgroundImage: room.creatorProfileImageUrl != null &&
                      room.creatorProfileImageUrl!.isNotEmpty
                  ? NetworkImage(room.creatorProfileImageUrl!)
                  : null,
              child: room.creatorProfileImageUrl == null ||
                      room.creatorProfileImageUrl!.isEmpty
                  ? Text(
                      room.creator.isNotEmpty
                          ? room.creator[0].toUpperCase()
                          : '?',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: 6),
            Text(
              room.creator,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              room.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              room.capacityLabel,
              maxLines: 1,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: room.isFullOrClosed ? AppColors.failure : AppColors.success,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            _MatchingInfoChip(
              icon: Icons.place_rounded,
              text: room.location,
              expanded: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _MatchingInfoChip extends StatelessWidget {
  const _MatchingInfoChip({
    required this.icon,
    required this.text,
    this.expanded = false,
  });

  final IconData icon;
  final String text;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: AppGlassStyles.innerCard(
        radius: 10,
        isDark: isDark,
      ),
      child: Row(
        mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
    if (expanded) {
      return SizedBox(width: double.infinity, child: chip);
    }
    return chip;
  }
}
