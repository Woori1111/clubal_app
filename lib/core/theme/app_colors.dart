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

  /// 브랜드 강조 (버튼, FAB, 링크 등) — 앱 전역 통일
  static const Color brandPrimary = Color(0xFF2ECEF2);

  // UI semantic (설정·FAQ·문의 등에서 반복 사용)
  static const Color surfaceMuted = Color(0xFF304255);
  static const Color surfaceMutedLight = Color(0xFF455568);
  static const Color linkBlue = Color(0xFF5D90F5);
  static const Color linkBlueLight = Color(0xFF8BB5FF);
  static const Color infoBackground = Color(0xFFE8F3FF);
  static const Color warningBackground = Color(0xFFFFF0E6);
  static const Color warningAccent = Color(0xFFFF7A8A);
  static const Color chipSelected = Color(0xFF8BB5FF);
  static const Color inputBorder = Color(0x22000000);
  static const Color shadowLight = Color(0x33000000);
  static const Color shadowDark = Color(0x20000000);
  static const Color shadowSoft = Color(0x22000000);
  static const Color overlayDark = Color(0x30000000);
  // Glass (light theme) - app_glass_styles
  static const Color glassBorderLight = Color(0x66FFFFFF);
  static const Color glassGradientStartLight = Color(0x99FFFFFF);
  static const Color glassGradientEndLightAlt = Color(0x33FFFFFF);
  static const Color glassShadowLight = Color(0x1A2A3D54);
  static const Color innerGlassBorderLight = Color(0x4DFFFFFF);
  static const Color innerGlassGradientStartLight = Color(0x66FFFFFF);
  static const Color innerGlassGradientEndLight = Color(0x1AFFFFFF);

  // Background gradient (clubal_background 등)
  static const Color bgDarkStart = Color(0xFF0D1117);
  static const Color bgDarkMid = Color(0xFF161B22);
  static const Color bgLightStart = Color(0xFFF8FBFF);
  static const Color bgLightEnd = Color(0xFFEFF4FA);
  static const Color glowBlue = Color(0x28358EF0);
  static const Color glowBlueBright = Color(0x1A58A6FF);
  static const Color glowGreen = Color(0x2239D353);
  static const Color glowLightBlue = Color(0x8066C8FF);
  static const Color glowLightPurple = Color(0x555E86FF);
  static const Color glowLightCyan = Color(0x665CFFD7);

  // Glass card (PostCard·탭바 등 그라데이션)
  static const Color glassCardBorderLight = Color(0x55FFFFFF);
  static const Color glassCardBorderDark = Color(0x33FFFFFF);
  static const Color glassCardGradientStartLight = Color(0x4DF3FAFF);
  static const Color glassCardGradientEndLight = Color(0x33A7B7FF);
  static const Color glassCardGradientStartDark = Color(0x1AFFFFFF);
  static const Color glassCardGradientEndDark = Color(0x0DFFFFFF);

  // 댓글 카드·입력바 (글 상세 등)
  static const Color commentsCardBorder = Color(0x44FFFFFF);
  static const Color commentsCardStart = Color(0x33E8F4FC);
  static const Color commentsCardEnd = Color(0x22B8D4E8);
  static const Color inputBarBg = Color(0xB3FFFFFF);
  static const Color inputBarBorder = Color(0x334C6078);
  static const Color inputFieldBg = Color(0x1A314D6A);
  static const Color divider = Color(0x224C6078);
  static const Color avatarBg = Color(0x33FFFFFF);
  static const Color writeButtonStart = Color(0xFF9AE1FF);
  static const Color writeButtonEnd = Color(0xFF69C6F6);
  static const Color shadowBrand = Color(0x5522B8FF);
}

