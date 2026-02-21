import 'package:clubal_app/features/menu/dummy/menu_dummy_data.dart';
import 'package:clubal_app/features/menu/widgets/activity_row_item.dart';
import 'package:clubal_app/features/menu/widgets/activity_section_card.dart';
import 'package:flutter/material.dart';

/// 내 모임 섹션
class MyMeetingsSection extends StatelessWidget {
  const MyMeetingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ActivitySectionCard(
      title: '내 모임',
      icon: Icons.place_outlined,
      child: Column(
        children: [
          ActivityRowItem(
            label: '내가 만든 모임',
            value: '${MenuDummyData.myCreatedMeetings}개',
          ),
          ActivityRowItem(
            label: '참여한 모임',
            value: '${MenuDummyData.myJoinedMeetings}개',
          ),
          ActivityRowItem(
            label: '예정된 모임',
            value: MenuDummyData.nextMeetingTitle,
            badge: 'D-${MenuDummyData.nextMeetingDDay}',
          ),
          ActivityRowItem(
            label: '종료된 모임',
            value: '${MenuDummyData.pastMeetings}개',
          ),
        ],
      ),
    );
  }
}
