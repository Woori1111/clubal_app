/// 지난 알림 한 건을 나타내는 모델
class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    this.icon,
    this.isRead = false,
    /// 탭으로 이동해야 하는 알림이면 0~4 (홈, 매칭, 채팅, 커뮤니티, 메뉴), null이면 확인용(확대 효과)
    this.targetTabIndex,
  });

  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  final String? icon;
  final bool isRead;
  final int? targetTabIndex;

  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(createdAt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
    if (diff.inHours < 24) return '${diff.inHours}시간 전';
    if (diff.inDays < 7) return '${diff.inDays}일 전';
    return '${createdAt.month}/${createdAt.day}';
  }

  NotificationItem copyWith({
    String? id,
    String? title,
    String? body,
    DateTime? createdAt,
    String? icon,
    bool? isRead,
    int? targetTabIndex,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
      icon: icon ?? this.icon,
      isRead: isRead ?? this.isRead,
      targetTabIndex: targetTabIndex ?? this.targetTabIndex,
    );
  }
}
