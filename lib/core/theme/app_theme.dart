import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  const AppTheme._();

  /// 기본 라이트 테마
  static ThemeData light() {
    final base = ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.background,
      useMaterial3: true,
      fontFamily: 'Pretendard',
      fontFamilyFallback: const [
        'Pretendard',
        'SF Pro Text',
        'Apple SD Gothic Neo',
      ],
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF8ED9FF),
        brightness: Brightness.light,
      ),
    );

    return base.copyWith(
      textTheme: base.textTheme.copyWith(
        headlineSmall: base.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        titleLarge: base.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        titleSmall: base.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
        ),
        bodyMedium: base.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w400,
          color: AppColors.bodyText,
        ),
        bodySmall: base.textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w400,
          color: AppColors.captionText,
        ),
        labelLarge: base.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        labelSmall: base.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w500,
          color: AppColors.captionText,
        ),
      ),
    );
  }

  /// 향후 사용을 위한 다크 테마 스텁
  static ThemeData dark() {
    final base = ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      fontFamily: 'Pretendard',
      fontFamilyFallback: const [
        'Pretendard',
        'SF Pro Text',
        'Apple SD Gothic Neo',
      ],
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF8ED9FF),
        brightness: Brightness.dark,
      ),
    );

    return base.copyWith(
      textTheme: base.textTheme,
    );
  }
}

