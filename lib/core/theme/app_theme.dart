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

  /// 다크 테마 — 텍스트·아이콘 밝게. canvasColor 다크 고정으로 빈 영역에서 흰색이 나오지 않게 함.
  static ThemeData dark() {
    final base = ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      canvasColor: AppColors.backgroundDark,
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
        surface: AppColors.backgroundDark,
      ).copyWith(
        onSurface: AppColors.textPrimaryDark,
        onSurfaceVariant: AppColors.textSecondaryDark,
        onPrimary: AppColors.textPrimaryDark,
        outline: AppColors.captionTextDark,
      ),
      iconTheme: const IconThemeData(
        color: AppColors.iconOnDark,
        size: 24,
      ),
    );

    return base.copyWith(
      textTheme: base.textTheme.copyWith(
        headlineSmall: base.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimaryDark,
        ),
        titleLarge: base.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimaryDark,
        ),
        titleMedium: base.textTheme.titleMedium?.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        titleSmall: base.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondaryDark,
        ),
        bodyLarge: base.textTheme.bodyLarge?.copyWith(
          color: AppColors.bodyTextDark,
        ),
        bodyMedium: base.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w400,
          color: AppColors.bodyTextDark,
        ),
        bodySmall: base.textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w400,
          color: AppColors.captionTextDark,
        ),
        labelLarge: base.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimaryDark,
        ),
        labelMedium: base.textTheme.labelMedium?.copyWith(
          color: AppColors.textSecondaryDark,
        ),
        labelSmall: base.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w500,
          color: AppColors.captionTextDark,
        ),
      ),
    );
  }
}

