/// 매칭 데이터 모델.
/// status: pending, active, confirmed, completed
class Match {
  const Match({
    required this.id,
    required this.clubName,
    required this.location,
    required this.matchType,
    required this.dateTime,
    required this.status,
    required this.createdAt,
    this.activeStep = 0,
  });

  final String id;
  final String clubName;
  final String location;
  final String matchType;
  final DateTime dateTime;
  final String status;
  final DateTime createdAt;
  /// active 상태일 때 타임라인 현재 단계 (0: 신청완료, 1: 상대확인중, 2: 조율중, 3: 확정)
  final int activeStep;
}
