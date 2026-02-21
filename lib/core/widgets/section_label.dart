import 'package:flutter/material.dart';

/// 섹션 제목 라벨 (매칭 탭 기준: 매칭중, 매칭완료, 내가 만든 조각 등). 앱 전역 통일.
class SectionLabel extends StatelessWidget {
  const SectionLabel({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w400,
              fontSize: 16,
            ),
      ),
    );
  }
}
