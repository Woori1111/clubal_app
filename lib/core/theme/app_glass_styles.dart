import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppGlassStyles {
  const AppGlassStyles._();

  static BoxDecoration card({double radius = 28, EdgeInsets? padding}) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: AppColors.glassBorder, width: 1),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.glassGradientStart,
          AppColors.glassGradientEnd,
        ],
      ),
    );
  }

  static BoxDecoration innerCard({double radius = 18}) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: AppColors.innerGlassBorder, width: 1),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.innerGlassGradientStart,
          AppColors.innerGlassGradientEnd,
        ],
      ),
    );
  }
}

