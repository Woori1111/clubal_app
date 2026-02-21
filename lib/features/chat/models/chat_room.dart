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
