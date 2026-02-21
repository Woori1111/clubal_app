class ChatParticipant {
  const ChatParticipant({
    required this.userId,
    required this.name,
    this.imageUrl,
    this.bio,
    this.gender,
  });

  final String userId;
  final String name;
  final String? imageUrl;
  final String? bio;
  final String? gender;
}

class ChatRoom {
  const ChatRoom({
    required this.id,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserImageUrl,
    required this.lastMessage,
    required this.lastMessageAt,
    this.unreadCount = 0,
    this.name,
    this.participants = const [],
    this.isGroup = false,
    this.groupImage,
    this.isPinned = false,
    this.locationTag,
    this.meetingDate,
    this.isMuted = false,
    this.isOnline = false,
    this.isBlocked = false,
    this.isLeft = false,
  });

  final String id;
  final String otherUserId;
  final String otherUserName;
  final String? otherUserImageUrl;
  final String lastMessage;
  final DateTime lastMessageAt;
  final int unreadCount;

  final String? name;
  final List<ChatParticipant> participants;
  final bool isGroup;
  final String? groupImage;
  final bool isPinned;
  final String? locationTag;
  final DateTime? meetingDate;
  final bool isMuted;
  final bool isOnline;
  final bool isBlocked;
  final bool isLeft;

  ChatRoom copyWith({
    String? id,
    String? otherUserId,
    String? otherUserName,
    String? otherUserImageUrl,
    String? lastMessage,
    DateTime? lastMessageAt,
    int? unreadCount,
    String? name,
    List<ChatParticipant>? participants,
    bool? isGroup,
    String? groupImage,
    bool? isPinned,
    String? locationTag,
    DateTime? meetingDate,
    bool? isMuted,
    bool? isOnline,
    bool? isBlocked,
    bool? isLeft,
  }) {
    return ChatRoom(
      id: id ?? this.id,
      otherUserId: otherUserId ?? this.otherUserId,
      otherUserName: otherUserName ?? this.otherUserName,
      otherUserImageUrl: otherUserImageUrl ?? this.otherUserImageUrl,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      unreadCount: unreadCount ?? this.unreadCount,
      name: name ?? this.name,
      participants: participants ?? this.participants,
      isGroup: isGroup ?? this.isGroup,
      groupImage: groupImage ?? this.groupImage,
      isPinned: isPinned ?? this.isPinned,
      locationTag: locationTag ?? this.locationTag,
      meetingDate: meetingDate ?? this.meetingDate,
      isMuted: isMuted ?? this.isMuted,
      isOnline: isOnline ?? this.isOnline,
      isBlocked: isBlocked ?? this.isBlocked,
      isLeft: isLeft ?? this.isLeft,
    );
  }

  /// 그룹 채팅 나가기 시스템 메시지 포맷 (실제 서버 반영 X, 구조용)
  static String formatLeaveSystemMessage(String userName) =>
      '$userName님이 채팅방을 나갔습니다';

  String get displayName => name ?? otherUserName;

  int get participantCount => isGroup ? participants.length : 1;

  String? get dDayLabel {
    if (meetingDate == null) return null;
    final diff = meetingDate!.difference(DateTime.now()).inDays;
    if (diff < 0) return 'D+${-diff}';
    if (diff == 0) return 'D-day';
    return 'D-$diff';
  }
}
