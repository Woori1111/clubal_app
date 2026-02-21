import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppGlassStyles {
  const AppGlassStyles._();

  static BoxDecoration card({
    double radius = 16,
    EdgeInsets? padding,
    bool isDark = false,
  }) {
    if (isDark) {
      return BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: AppColors.glassBorderDark, width: 1.2),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.glassGradientStartDark,
            AppColors.glassGradientEndDark,
          ],
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowDark,
            blurRadius: 24,
            spreadRadius: -4,
            offset: Offset(0, 12),
          ),
        ],
      );
    }
    return BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: AppColors.glassBorderLight, width: 1.2),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.glassGradientStartLight,
          AppColors.glassGradientEndLightAlt,
        ],
      ),
      boxShadow: const [
        BoxShadow(
          color: AppColors.glassShadowLight,
          blurRadius: 24,
          spreadRadius: -4,
          offset: Offset(0, 12),
        ),
      ],
    );
  }

  static BoxDecoration innerCard({double radius = 12, bool isDark = false}) {
    if (isDark) {
      return BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: AppColors.innerGlassBorderDark, width: 1.0),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.innerGlassGradientStartDark,
            AppColors.innerGlassGradientEndDark,
          ],
        ),
      );
    }
    return BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: AppColors.innerGlassBorderLight, width: 1.0),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.innerGlassGradientStartLight,
          AppColors.innerGlassGradientEndLight,
        ],
      ),
    );
  }
}

