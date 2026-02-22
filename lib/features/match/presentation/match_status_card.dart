import 'package:clubal_app/core/theme/app_glass_styles.dart';
import 'package:clubal_app/features/match/data/match_model.dart';
import 'package:clubal_app/features/match/data/mock_match_repository.dart';
import 'package:clubal_app/features/match/presentation/match_timeline_widget.dart';
import 'package:clubal_app/features/match/utils/match_format_utils.dart';
import 'package:flutter/material.dart';

/// 내 매칭 현황 카드 내부 컨텐츠.
/// 요약 영역 + 진행중/대기중/확정 매칭 표시.
class MatchStatusCard extends StatelessWidget {
  const MatchStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = MockMatchRepository.instance;

    return FutureBuilder<List<Match>>(
      future: repository.fetchMatches(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )),
          );
        }
        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              '매칭 정보를 불러올 수 없습니다.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
            ),
          );
        }
        final list = snapshot.data ?? [];
        final activeCount = list.where((m) => m.status == 'active').length;
        final pendingCount = list.where((m) => m.status == 'pending').length;
        final confirmedCount = list.where((m) => m.status == 'confirmed').length;
        final active = list.where((m) => m.status == 'active').toList();
        final pending = list.where((m) => m.status == 'pending').toList();
        final confirmed = list.where((m) => m.status == 'confirmed').toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SummaryRow(
              activeCount: activeCount,
              pendingCount: pendingCount,
              confirmedCount: confirmedCount,
            ),
            if (active.isNotEmpty) ...[
              const SizedBox(height: 16),
              ...active.map((m) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: MatchTimelineWidget(match: m),
                  )),
            ],
            if (pending.isNotEmpty) ...[
              const SizedBox(height: 12),
              ...pending.map((m) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _PendingMatchCard(match: m),
                  )),
            ],
            if (confirmed.isNotEmpty) ...[
              const SizedBox(height: 12),
              ...confirmed.map((m) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _ConfirmedMatchCard(match: m),
                  )),
            ],
          ],
        );
      },
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.activeCount,
    required this.pendingCount,
    required this.confirmedCount,
  });

  final int activeCount;
  final int pendingCount;
  final int confirmedCount;

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final onSurfaceVariant = Theme.of(context).colorScheme.onSurfaceVariant;

    return Row(
      children: [
        _SummaryItem(
          label: '진행중',
          count: activeCount,
          onSurface: onSurface,
          onSurfaceVariant: onSurfaceVariant,
        ),
        const SizedBox(width: 16),
        _SummaryItem(
          label: '대기중',
          count: pendingCount,
          onSurface: onSurface,
          onSurfaceVariant: onSurfaceVariant,
        ),
        const SizedBox(width: 16),
        _SummaryItem(
          label: '확정',
          count: confirmedCount,
          onSurface: onSurface,
          onSurfaceVariant: onSurfaceVariant,
        ),
      ],
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.label,
    required this.count,
    required this.onSurface,
    required this.onSurfaceVariant,
  });

  final String label;
  final int count;
  final Color onSurface;
  final Color onSurfaceVariant;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$count건',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: onSurface,
              ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: onSurfaceVariant,
                fontSize: 11,
              ),
        ),
      ],
    );
  }
}

class _PendingMatchCard extends StatelessWidget {
  const _PendingMatchCard({required this.match});

  final Match match;

  void _onCancel(BuildContext context) {
    // mock: 취소 동작
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('취소 요청이 전송되었습니다.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final onSurfaceVariant = Theme.of(context).colorScheme.onSurfaceVariant;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: AppGlassStyles.innerCard(radius: 12, isDark: isDark),
      child: Row(
        children: [
          Expanded(
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
                const SizedBox(height: 4),
                Text(
                  '응답 대기중',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: onSurfaceVariant,
                        fontSize: 12,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  MatchFormatUtils.remainingTimeFromCreated(match.createdAt),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: onSurfaceVariant,
                        fontSize: 11,
                      ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => _onCancel(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              '취소',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: onSurfaceVariant,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfirmedMatchCard extends StatelessWidget {
  const _ConfirmedMatchCard({required this.match});

  final Match match;

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
          Row(
            children: [
              Icon(Icons.check_circle_rounded, size: 18, color: primary),
              const SizedBox(width: 6),
              Text(
                '매칭 확정',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: primary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            MatchFormatUtils.formatDateTime(match.dateTime),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: onSurface,
                  fontSize: 15,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            match.clubName,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: onSurface,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            match.location,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: onSurfaceVariant,
                  fontSize: 12,
                ),
          ),
        ],
      ),
    );
  }
}
