import 'package:clubal_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class DateSeparator extends StatelessWidget {
  const DateSeparator({super.key, required this.date});

  final DateTime date;

  static String format(DateTime dt) {
    return '${dt.year}년 ${dt.month}월 ${dt.day}일';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? AppColors.captionTextDark : AppColors.captionText;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 1,
              color: color.withValues(alpha: 0.3),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              format(date),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color,
                    fontSize: 12,
                  ),
            ),
          ),
          Expanded(
            child: Container(
              height: 1,
              color: color.withValues(alpha: 0.3),
            ),
          ),
        ],
      ),
    );
  }
}
