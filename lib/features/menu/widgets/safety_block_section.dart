import 'package:clubal_app/features/menu/dummy/menu_dummy_data.dart';
import 'package:clubal_app/features/menu/widgets/activity_row_item.dart';
import 'package:clubal_app/features/menu/widgets/activity_section_card.dart';
import 'package:flutter/material.dart';

/// 안전 & 차단 관리 섹션
class SafetyBlockSection extends StatelessWidget {
  const SafetyBlockSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ActivitySectionCard(
      title: '안전 & 차단 관리',
      icon: Icons.shield_outlined,
      child: Column(
        children: [
          ActivityRowItem(
            label: '차단 목록',
            value: '${MenuDummyData.blockedCount}명',
          ),
          ActivityRowItem(
            label: '신고 내역',
            value: '${MenuDummyData.reportHistoryCount}건',
          ),
          ActivityRowItem(
            label: '안전 가이드',
            value: '보기',
          ),
        ],
      ),
    );
  }
}
