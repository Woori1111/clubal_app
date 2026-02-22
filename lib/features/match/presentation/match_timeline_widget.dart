import 'package:clubal_app/core/theme/app_glass_styles.dart';
import 'package:clubal_app/features/match/data/match_model.dart';
import 'package:flutter/material.dart';

/// 진행중 매칭 타임라인 위젯.
/// 신청완료 → 상대확인중 → 조율중 → 확정
class MatchTimelineWidget extends StatelessWidget {
  const MatchTimelineWidget({
    super.key,
    required this.match,
  });

  final Match match;

  static const _steps = ['신청완료', '상대확인중', '조율중', '확정'];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final onSurfaceVariant = Theme.of(context).colorScheme.onSurfaceVariant;
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: AppGlassStyles.innerCard(radius: 12, isDark: isDark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            match.clubName,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: onSurface,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            '${match.matchType} | ${match.location}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: onSurfaceVariant,
                  fontSize: 12,
                ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              for (var i = 0; i < _steps.length; i++) ...[
                Expanded(
                  child: _TimelineStep(
                    label: _steps[i],
                    isActive: match.activeStep == i,
                    isCompleted: match.activeStep > i,
                    color: primary,
                    onSurfaceVariant: onSurfaceVariant,
                  ),
                ),
                if (i < _steps.length - 1)
                  Container(
                    width: 12,
                    height: 2,
                    color: match.activeStep > i
                        ? primary.withValues(alpha: 0.6)
                        : onSurfaceVariant.withValues(alpha: 0.3),
                  ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _TimelineStep extends StatelessWidget {
  const _TimelineStep({
    required this.label,
    required this.isActive,
    required this.isCompleted,
    required this.color,
    required this.onSurfaceVariant,
  });

  final String label;
  final bool isActive;
  final bool isCompleted;
  final Color color;
  final Color onSurfaceVariant;

  @override
  Widget build(BuildContext context) {
    final textColor = isActive || isCompleted ? color : onSurfaceVariant;
    final fontWeight = isActive ? FontWeight.w700 : FontWeight.w500;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: textColor,
                fontWeight: fontWeight,
                fontSize: 10,
              ),
        ),
      ],
    );
  }
}
