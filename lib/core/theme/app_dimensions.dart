import 'package:flutter/material.dart';

/// 앱 전역 레이아웃·간격·radius 상수 (하드코딩 제거용)
class AppDimensions {
  const AppDimensions._();

  // Padding
  static const double pagePaddingHorizontal = 20.0;
  static const double listPaddingHorizontal = 14.0;
  static const EdgeInsets pagePadding = EdgeInsets.symmetric(horizontal: pagePaddingHorizontal);
  static const EdgeInsets listPadding = EdgeInsets.symmetric(horizontal: listPaddingHorizontal);
  static const EdgeInsets paddingAll16 = EdgeInsets.all(16);
  static const EdgeInsets paddingAll12 = EdgeInsets.all(12);

  // Border radius (카드·입력·버튼 통일)
  static const double radiusCard = 16.0;
  static const double radiusCardSmall = 12.0;
  static const double radiusCardLarge = 20.0;
  static const double radiusPill = 24.0;
  static const double radiusInput = 14.0;
  static const double radiusCommentInput = 22.0;
  static const double radiusFab = 28.0;
  static const double radiusImage = 8.0;

  static BorderRadius get borderRadiusCard => BorderRadius.circular(radiusCard);
  static BorderRadius get borderRadiusCardSmall => BorderRadius.circular(radiusCardSmall);
  static BorderRadius get borderRadiusCardLarge => BorderRadius.circular(radiusCardLarge);
  static BorderRadius get borderRadiusPill => BorderRadius.circular(radiusPill);
  static BorderRadius get borderRadiusInput => BorderRadius.circular(radiusInput);
  static BorderRadius get borderRadiusImage => BorderRadius.circular(radiusImage);

  // Section / list spacing
  static const double sectionSpacing = 14.0;
  static const double sectionLabelTopGap = 8.0;
  static const double listItemGap = 12.0;

  // App bar
  static const double appBarHeight = 56.0;
  static const double appBarPaddingVertical = 16.0;

  // Bottom nav / FAB
  static const double bottomNavHeight = 56.0;
  static const double fabSize = 56.0;
  static const double fabBottomGap = 28.0;
}
