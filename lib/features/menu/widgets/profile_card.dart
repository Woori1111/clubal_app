import 'dart:ui';

import 'package:clubal_app/core/theme/app_glass_styles.dart';
import 'package:clubal_app/features/menu/dummy/menu_dummy_data.dart';
import 'package:flutter/material.dart';

/// 프로필 카드. Liquid Glass 스타일, 활동 통계 포함.
class MenuProfileCard extends StatelessWidget {
  const MenuProfileCard({
    super.key,
    required this.displayName,
    required this.bio,
    required this.onTap,
  });

  final String displayName;
  final String bio;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: AppGlassStyles.card(
              radius: 24,
              isDark: Theme.of(context).brightness == Brightness.dark,
            ),
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.15),
                  child: Icon(
                    Icons.person_rounded,
                    color: Theme.of(context).colorScheme.onSurface,
                    size: 40,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        displayName,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        bio.isNotEmpty ? bio : '내 프로필 보기',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _StatChip(
                            value: '${MenuDummyData.joinedMeetingsCount}',
                            label: '참여 모임',
                          ),
                          const SizedBox(width: 12),
                          _StatChip(
                            value: '${MenuDummyData.matchingSuccessCount}',
                            label: '매칭 성공',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.value,
    required this.label,
  });

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .onSurface
            .withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}
