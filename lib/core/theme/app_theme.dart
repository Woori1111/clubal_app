import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData dark() {
    final base = ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF4F7FB),
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
          fontWeight: FontWeight.w700, // Pretendard Bold
          color: const Color(0xFF1D2630),
        ),
        titleLarge: base.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700, // Pretendard Bold
          color: const Color(0xFF1E2732),
        ),
        titleSmall: base.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w500, // Pretendard Medium
          color: const Color(0xFF243242),
        ),
        bodyMedium: base.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w400, // Pretendard Regular
          color: const Color(0xCC2C3D50),
        ),
        bodySmall: base.textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w400, // Pretendard Regular
          color: const Color(0xCC415469),
        ),
        labelLarge: base.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w700, // Pretendard Bold
          color: const Color(0xFF1D2630),
        ),
        labelSmall: base.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w500, // Pretendard Medium
          color: const Color(0xFF324357),
        ),
      ),
    );
  }
}
