import 'package:clubal_app/features/menu/dummy/menu_dummy_data.dart';
import 'package:clubal_app/features/menu/widgets/activity_row_item.dart';
import 'package:clubal_app/features/menu/widgets/activity_section_card.dart';
import 'package:flutter/material.dart';

/// 나의 평판 섹션
class ReputationSection extends StatelessWidget {
  const ReputationSection({super.key});

  @override
  Widget build(BuildContext context) {
    final successRate =
        (MenuDummyData.matchingSuccessRate * 100).toInt();
    final noShowRate =
        (MenuDummyData.noShowRate * 100).toInt();

    return ActivitySectionCard(
      title: '나의 평판',
      icon: Icons.analytics_outlined,
      child: Column(
        children: [
          ActivityRowItem(
            label: '받은 후기 수',
            value: '${MenuDummyData.reviewsReceived}개',
          ),
          ActivityRowItem(
            label: '매칭 성공률',
            value: '$successRate%',
          ),
          ActivityRowItem(
            label: '신뢰도 점수',
            value: '${MenuDummyData.trustScore} / 5.0',
          ),
          ActivityRowItem(
            label: '노쇼율',
            value: '$noShowRate%',
          ),
        ],
      ),
    );
  }
}
