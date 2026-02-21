/// 채팅·목록 화면에서 공통으로 사용하는 상대 시간 포맷.
/// 오늘 이전이면 MM/dd, 당일이면 HH:mm 반환.
String formatRelativeTime(DateTime dt) {
  final now = DateTime.now();
  final diff = now.difference(dt);
  if (diff.inDays > 0) return '${dt.month}/${dt.day}';
  return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}
