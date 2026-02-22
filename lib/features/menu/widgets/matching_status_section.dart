import 'package:clubal_app/features/match/presentation/match_status_card.dart';
import 'package:clubal_app/features/menu/widgets/activity_section_card.dart';
import 'package:flutter/material.dart';

/// 내 매칭 현황 섹션
class MatchingStatusSection extends StatelessWidget {
  const MatchingStatusSection({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ActivitySectionCard(
      title: '내 매칭 현황',
      icon: Icons.local_fire_department_outlined,
      onTap: onTap,
      child: const MatchStatusCard(),
    );
  }
}
