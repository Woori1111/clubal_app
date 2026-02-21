import 'package:flutter/foundation.dart';

/// 섹션 내 개별 메뉴 항목 모델.
/// 추후 API/Firebase 응답 매핑에 활용.

class ActivitySectionItem {
  const ActivitySectionItem({
    required this.label,
    required this.value,
    this.badge,
    this.onTap,
  });

  final String label;
  final String value;
  final String? badge;
  final VoidCallback? onTap;
}
