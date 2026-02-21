import 'package:clubal_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class ClubalBackground extends StatelessWidget {
  const ClubalBackground({super.key});

  static const double _bubbleLeft = -70;
  static const double _bubbleTop = -40;
  static const double _bubbleRight = -110;
  static const double _bubbleTopRight = 220;
  static const double _bubbleBottomLeft = 40;
  static const double _bubbleBottom = 150;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.bgDarkStart,
              AppColors.bgDarkMid,
              AppColors.bgDarkStart,
            ],
          ),
        ),
        child: const Stack(
          children: [
            Positioned(
              left: _bubbleLeft,
              top: _bubbleTop,
              child: _GlowBubble(size: 230, color: AppColors.glowBlue),
            ),
            Positioned(
              right: _bubbleRight,
              top: _bubbleTopRight,
              child: _GlowBubble(size: 280, color: AppColors.glowBlueBright),
            ),
            Positioned(
              left: _bubbleBottomLeft,
              bottom: _bubbleBottom,
              child: _GlowBubble(size: 180, color: AppColors.glowGreen),
            ),
          ],
        ),
      );
    }
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.bgLightStart, AppColors.bgLightEnd],
        ),
      ),
      child: const Stack(
        children: [
          Positioned(
            left: _bubbleLeft,
            top: _bubbleTop,
            child: _GlowBubble(size: 230, color: AppColors.glowLightBlue),
          ),
          Positioned(
            right: _bubbleRight,
            top: _bubbleTopRight,
            child: _GlowBubble(size: 280, color: AppColors.glowLightPurple),
          ),
          Positioned(
            left: _bubbleBottomLeft,
            bottom: _bubbleBottom,
            child: _GlowBubble(size: 180, color: AppColors.glowLightCyan),
          ),
        ],
      ),
    );
  }
}

class _GlowBubble extends StatelessWidget {
  const _GlowBubble({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
      ),
    );
  }
}
