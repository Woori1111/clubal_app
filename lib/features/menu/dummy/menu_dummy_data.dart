/// 메뉴 탭 활동 허브용 더미 데이터.
/// 추후 Firebase 등 실제 데이터 소스로 교체 가능하도록 구조 설계.

class MenuDummyData {
  const MenuDummyData._();

  /// 프로필 활동 통계
  static const int joinedMeetingsCount = 12;
  static const int matchingSuccessCount = 8;

  /// 내 매칭 현황
  static const int matchingInProgress = 2;
  static const int matchingWaiting = 1;
  static const int matchingCompleted = 8;
  static const int matchingCancelled = 1;

  /// 내 모임
  static const int myCreatedMeetings = 3;
  static const int myJoinedMeetings = 5;
  static const int upcomingMeetings = 2;
  static const int pastMeetings = 6;

  /// 예정된 모임 D-day (일수)
  static const int nextMeetingDDay = 3;
  static const String nextMeetingTitle = '강남 클럽 조각 모임';

  /// 즐겨찾기 장소
  static const int savedClubs = 4;
  static const int savedHuntingPocha = 2;
  static const int savedLounge = 1;

  /// 커뮤니티 활동
  static const int myPosts = 7;
  static const int commentedPosts = 15;
  static const int likedPosts = 32;

  /// 안전 & 차단 관리
  static const int blockedCount = 0;
  static const int reportHistoryCount = 0;

  /// 나의 평판
  static const int reviewsReceived = 12;
  static const double matchingSuccessRate = 0.87; // 87%
  static const double trustScore = 4.2; // 5점 만점
  static const double noShowRate = 0.0; // 0%
}
