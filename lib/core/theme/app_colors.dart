import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  // Backgrounds
  static const Color background = Color(0xFFF4F7FB);
  static const Color backgroundDark = Color(0xFF0D1117);

  // Text (light theme)
  static const Color textPrimary = Color(0xFF1D2630);
  static const Color textSecondary = Color(0xFF243242);
  static const Color bodyText = Color(0xCC2C3D50);
  static const Color captionText = Color(0xCC415469);

  // Text (dark theme) — 밝게 보이도록
  static const Color textPrimaryDark = Color(0xFFF0F6FC);
  static const Color textSecondaryDark = Color(0xFFC9D1D9);
  static const Color bodyTextDark = Color(0xFFB1BAC4);
  static const Color captionTextDark = Color(0xFF8B949E);

  // Icon (dark theme)
  static const Color iconOnDark = Color(0xFFE6EDF3);

  // Glass / card surfaces
  static const Color glassBorder = Color(0x2B3D5067);
  static const Color glassGradientStart = Color(0xD9FFFFFF);
  static const Color glassGradientEnd = Color(0xCBEAF1FA);

  static const Color innerGlassBorder = Color(0x22485B72);
  static const Color innerGlassGradientStart = Color(0xD7FFFFFF);
  static const Color innerGlassGradientEnd = Color(0xCDE9F0F8);

  // Glass (dark theme)
  static const Color glassBorderDark = Color(0x33FFFFFF);
  static const Color glassGradientStartDark = Color(0x1AFFFFFF);
  static const Color glassGradientEndDark = Color(0x0DFFFFFF);
  static const Color innerGlassBorderDark = Color(0x22FFFFFF);
  static const Color innerGlassGradientStartDark = Color(0x18FFFFFF);
  static const Color innerGlassGradientEndDark = Color(0x08FFFFFF);

  /// 성공/진행 상태 (모집중, 완료 성공 등) — 앱 전역 통일
  static const Color success = Color(0xFF3AC0A0);

  /// 실패/경고/중단 상태 (모집완료, 꽉참, 에러 등) — 앱 전역 통일
  static const Color failure = Color(0xFFED3241);
}

