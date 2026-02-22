import 'package:flutter/material.dart';

/// 매칭 화면 기준 앱 전역 레이아웃 상수.
/// 모든 탭/리스트에서 동일한 패딩·간격을 사용해 UI/UX 통일.
class AppLayout {
  const AppLayout._();

  /// 화면 좌우 패딩 (매칭 탭 14)
  static const double screenHorizontal = 14;

  /// 리스트 상단 패딩
  static const double listTop = 12;

  /// 리스트 하단 패딩 (탭바 위 여유)
  static const double listBottom = 100;

  /// 섹션 간 간격 (매칭 _sectionSpacing 14)
  static const double sectionSpacing = 14;

  /// 카드 간 간격
  static const double cardSpacing = 10;

  /// 카드 모서리 반경 (매칭 GlassCard 16)
  static const double cardRadius = 16;

  /// 내부 칩/셀 모서리 반경 (매칭 innerCard 12)
  static const double innerRadius = 12;

  /// 글라스 블러 강도 (매칭 24)
  static const double glassBlur = 24;

  /// 카드 내부 패딩 (매칭 16)
  static const double cardPadding = 16;

  static EdgeInsets get listPadding => const EdgeInsets.fromLTRB(
    screenHorizontal,
    listTop,
    screenHorizontal,
    listBottom,
  );

  static EdgeInsets get screenPadding =>
      const EdgeInsets.symmetric(horizontal: screenHorizontal);
}
