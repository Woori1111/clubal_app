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
            color: Color(0x20000000),
            blurRadius: 24,
            spreadRadius: -4,
            offset: Offset(0, 12),
          ),
        ],
      );
    }
    return BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: const Color(0x66FFFFFF), width: 1.2),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0x99FFFFFF),
          Color(0x33FFFFFF),
        ],
      ),
      boxShadow: const [
        BoxShadow(
          color: Color(0x1A2A3D54),
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
      border: Border.all(color: const Color(0x4DFFFFFF), width: 1.0),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0x66FFFFFF),
          Color(0x1AFFFFFF),
        ],
      ),
    );
  }
}

