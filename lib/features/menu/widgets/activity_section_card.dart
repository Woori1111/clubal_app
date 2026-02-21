import 'dart:ui';

import 'package:clubal_app/core/theme/app_glass_styles.dart';
import 'package:flutter/material.dart';

/// 재사용 가능한 액티비티 섹션 카드.
/// 2026 미니멀 스타일, Liquid Glass 카드형 레이아웃.
class ActivitySectionCard extends StatefulWidget {
  const ActivitySectionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
    this.onTap,
  });

  final String title;
  final IconData icon;
  final Widget child;
  final VoidCallback? onTap;

  @override
  State<ActivitySectionCard> createState() => _ActivitySectionCardState();
}

class _ActivitySectionCardState extends State<ActivitySectionCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget card = ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: AnimatedScale(
          scale: _isPressed ? 0.98 : 1.0,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOutCubic,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: AppGlassStyles.card(
              radius: 20,
              isDark: isDark,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      widget.icon,
                      size: 22,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      widget.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                widget.child,
              ],
            ),
          ),
        ),
      ),
    );

    if (widget.onTap != null) {
      return GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: card,
      );
    }

    return card;
  }
}
