import 'package:clubal_app/core/theme/app_glass_styles.dart';
import 'package:clubal_app/core/widgets/liquid_pressable.dart';
import 'package:clubal_app/features/matching/models/piece_room.dart';
import 'package:clubal_app/features/matching/presentation/widgets/matching_glass_card.dart';
import 'package:flutter/material.dart';

/// 세로로 긴 직사각형 카드: 위에 만든 유저 프로필(원형), 아래 2열 그리드의 네모 카드 1~2줄
class MatchingRoomGridCard extends StatelessWidget {
  const MatchingRoomGridCard({
    super.key,
    required this.room,
    this.onTap,
    this.profileImageUrl,
  });

  final PieceRoom room;
  final VoidCallback? onTap;
  final String? profileImageUrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return LiquidPressable(
      onTap: onTap,
      child: MatchingGlassCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: CircleAvatar(
                radius: 28,
                backgroundColor: colorScheme.surfaceContainerHighest,
                foregroundColor: colorScheme.onSurface,
                backgroundImage: profileImageUrl != null && profileImageUrl!.isNotEmpty
                    ? NetworkImage(profileImageUrl!)
                    : null,
                child: profileImageUrl == null || profileImageUrl!.isEmpty
                    ? Text(
                        room.creator.isNotEmpty ? room.creator[0].toUpperCase() : '?',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              room.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                const spacing = 8.0;
                const crossAxisCount = 2;
                final cellWidth = (constraints.maxWidth - spacing) / crossAxisCount;
                final cellHeight = cellWidth;
                final items = _buildInfoItems(room);

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: cellWidth,
                          height: cellHeight,
                          child: _GridCell(
                            icon: items[0].icon,
                            label: items[0].label,
                            isDark: isDark,
                          ),
                        ),
                        SizedBox(width: spacing),
                        SizedBox(
                          width: cellWidth,
                          height: cellHeight,
                          child: _GridCell(
                            icon: items[1].icon,
                            label: items[1].label,
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: spacing),
                    Row(
                      children: [
                        SizedBox(
                          width: cellWidth,
                          height: cellHeight,
                          child: _GridCell(
                            icon: items[2].icon,
                            label: items[2].label,
                            isDark: isDark,
                          ),
                        ),
                        SizedBox(width: spacing),
                        SizedBox(
                          width: cellWidth,
                          height: cellHeight,
                          child: _GridCell(
                            icon: items[3].icon,
                            label: items[3].label,
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  List<_GridItem> _buildInfoItems(PieceRoom room) {
    final d = room.meetingAt;
    final dateStr = '${d.month}월 ${d.day}일';
    return [
      _GridItem(Icons.group_rounded, room.capacityLabel),
      _GridItem(Icons.place_rounded, room.locationDisplay),
      _GridItem(Icons.calendar_today_rounded, dateStr),
      _GridItem(Icons.schedule_rounded, '시간 미정'),
    ];
  }
}

class _GridItem {
  const _GridItem(this.icon, this.label);
  final IconData icon;
  final String label;
}

class _GridCell extends StatelessWidget {
  const _GridCell({
    required this.icon,
    required this.label,
    required this.isDark,
  });

  final IconData icon;
  final String label;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: AppGlassStyles.innerCard(radius: 12, isDark: isDark),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
