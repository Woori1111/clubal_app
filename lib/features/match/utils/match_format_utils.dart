/// 매칭 관련 포맷 유틸.
/// 남은 시간, 날짜 포맷 함수 분리.
class MatchFormatUtils {
  const MatchFormatUtils._();

  /// createdAt 기준 24시간 내 남은 시간 텍스트.
  /// 예: "23시간 남음", "1시간 남음", "만료"
  static String remainingTimeFromCreated(DateTime createdAt) {
    final deadline = createdAt.add(const Duration(hours: 24));
    final now = DateTime.now();
    if (now.isAfter(deadline)) return '만료';
    final diff = deadline.difference(now);
    if (diff.inHours > 0) return '${diff.inHours}시간 남음';
    if (diff.inMinutes > 0) return '${diff.inMinutes}분 남음';
    return '곧 만료';
  }

  /// 확정 매칭 날짜/시간 강조 포맷.
  /// 예: "2월 25일 19:00"
  static String formatDateTime(DateTime dt) {
    return '${dt.month}월 ${dt.day}일 ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
