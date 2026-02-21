import 'package:clubal_app/features/menu/dummy/menu_dummy_data.dart';
import 'package:clubal_app/features/menu/widgets/activity_row_item.dart';
import 'package:clubal_app/features/menu/widgets/activity_section_card.dart';
import 'package:flutter/material.dart';

/// 내 매칭 현황 섹션
class MatchingStatusSection extends StatelessWidget {
  const MatchingStatusSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ActivitySectionCard(
      title: '내 매칭 현황',
      icon: Icons.local_fire_department_outlined,
      child: Column(
        children: [
          ActivityRowItem(
            label: '진행 중 매칭',
            value: '${MenuDummyData.matchingInProgress}건',
            badge: '진행',
          ),
          ActivityRowItem(
            label: '대기 중 요청',
            value: '${MenuDummyData.matchingWaiting}건',
            badge: '대기',
          ),
        ],
      ),
    );
  }
}
