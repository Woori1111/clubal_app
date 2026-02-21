import 'package:clubal_app/features/menu/dummy/menu_dummy_data.dart';
import 'package:clubal_app/features/menu/widgets/activity_row_item.dart';
import 'package:clubal_app/features/menu/widgets/activity_section_card.dart';
import 'package:flutter/material.dart';

/// 즐겨찾기 장소 섹션
class FavoritePlacesSection extends StatelessWidget {
  const FavoritePlacesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ActivitySectionCard(
      title: '즐겨찾기 장소',
      icon: Icons.star_outline_rounded,
      child: Column(
        children: [
          ActivityRowItem(
            label: '저장한 클럽',
            value: '${MenuDummyData.savedClubs}곳',
          ),
          ActivityRowItem(
            label: '헌팅포차',
            value: '${MenuDummyData.savedHuntingPocha}곳',
          ),
          ActivityRowItem(
            label: '라운지',
            value: '${MenuDummyData.savedLounge}곳',
          ),
        ],
      ),
    );
  }
}
