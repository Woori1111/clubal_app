import 'package:clubal_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class SystemMessageBubble extends StatelessWidget {
  const SystemMessageBubble({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? AppColors.captionTextDark : AppColors.captionText;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
      child: Center(
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color.withValues(alpha: 0.9),
                fontSize: 12,
              ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
