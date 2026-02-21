import 'package:clubal_app/core/widgets/clubal_glass_card.dart';
import 'package:flutter/material.dart';

/// 매칭용 글라스 카드. core의 ClubalGlassCard와 동일.
class MatchingGlassCard extends StatelessWidget {
  const MatchingGlassCard({super.key, required this.child, this.radius = 16});

  final Widget child;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return ClubalGlassCard(radius: radius, child: child);
  }
}
