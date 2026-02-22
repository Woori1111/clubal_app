import 'package:clubal_app/core/widgets/glass_card.dart';
import 'package:flutter/material.dart';

/// 안전 & 차단 관리 본문 (설정 > 안전 & 차단 관리)
class SafetyBlockBody extends StatelessWidget {
  const SafetyBlockBody({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GlassCard(
            child: Column(
              children: [
                _SafetyRow(
                  title: '차단 목록',
                  subtitle: '차단한 사용자 관리',
                  onTap: () {
                    // 추후 차단 목록 페이지 연결
                  },
                ),
                const SizedBox(height: 14),
                _SafetyRow(
                  title: '신고 내역',
                  subtitle: '신고 접수 내역 확인',
                  onTap: () {
                    // 추후 신고 내역 페이지 연결
                  },
                ),
                const SizedBox(height: 14),
                _SafetyRow(
                  title: '안전 가이드',
                  subtitle: '안전한 이용을 위한 가이드',
                  onTap: () {
                    // 추후 안전 가이드 페이지 연결
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SafetyRow extends StatelessWidget {
  const _SafetyRow({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ],
        ),
      ),
    );
  }
}
