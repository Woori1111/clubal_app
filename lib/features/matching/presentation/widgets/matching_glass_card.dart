import 'dart:ui';

import 'package:clubal_app/core/theme/app_glass_styles.dart';
import 'package:flutter/material.dart';

/// 리퀴드 글라스 스타일 카드 (블러 + 테두리·그라데이션)
class MatchingGlassCard extends StatelessWidget {
  const MatchingGlassCard({super.key, required this.child, this.radius = 16});

  final Widget child;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: AppGlassStyles.card(
            radius: radius,
            isDark: isDark,
          ),
          child: child,
        ),
      ),
    );
  }
}
