import 'package:clubal_app/features/favorite/presentation/favorite_places_summary_card.dart';
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
      child: const FavoritePlacesSummaryCard(),
    );
  }
}
