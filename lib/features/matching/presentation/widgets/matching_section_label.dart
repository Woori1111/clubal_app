import 'package:clubal_app/core/widgets/section_label.dart';
import 'package:flutter/material.dart';

/// 매칭 탭 내 섹션 제목. core의 SectionLabel과 동일.
class MatchingSectionLabel extends StatelessWidget {
  const MatchingSectionLabel({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return SectionLabel(title: title);
  }
}
