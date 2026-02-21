import 'dart:ui';

import 'package:clubal_app/core/theme/app_glass_styles.dart';
import 'package:flutter/material.dart';

/// 리퀴드 글라스 스타일 카드 (블러 + 테두리·그라데이션). 매칭 화면 기준 앱 전역 통일.
class ClubalGlassCard extends StatelessWidget {
  const ClubalGlassCard({
    super.key,
    required this.child,
    this.radius = 16,
    this.padding,
    this.onTap,
  });

  final Widget child;
  final double radius;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectivePadding = padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 16);
    Widget inner = ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          width: double.infinity,
          padding: effectivePadding,
          decoration: AppGlassStyles.card(
            radius: radius,
            isDark: isDark,
          ),
          child: child,
        ),
      ),
    );
    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: inner,
      );
    }
    return inner;
  }
}
