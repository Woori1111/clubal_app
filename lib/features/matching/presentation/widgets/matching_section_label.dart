import 'package:flutter/material.dart';

/// 매칭 탭 내 섹션 제목 (매칭중, 매칭완료, 내가 만든 조각 등)
class MatchingSectionLabel extends StatelessWidget {
  const MatchingSectionLabel({super.key, required this.title});

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
