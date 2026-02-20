class PieceRoom {
  const PieceRoom({
    required this.title,
    required this.currentMembers,
    required this.maxMembers,
    required this.creator,
    required this.location,
    required this.meetingAt,
    this.description,
    this.creatorProfileImageUrl,
    this.isRecruitmentClosed = false,
  });

  final String title;
  final int currentMembers;
  final int maxMembers;
  final String creator;
  final String location;
  final DateTime meetingAt;
  final String? description;
  /// 만든 유저 프로필 사진 URL (없으면 creator 첫 글자로 표시)
  final String? creatorProfileImageUrl;
  /// 모집완료로 상태 변경했을 때 true (꽉 찼거나 이 값이 true면 빨간색 표시)
  final bool isRecruitmentClosed;

  String get capacityLabel => '$currentMembers/$maxMembers';

  /// 화면에 표시할 장소: 지역명, 클럽이름만. "A · B · C" 형태면 "A, C"로, 이미 "지역, 클럽"이면 그대로.
  String get locationDisplay {
    final parts = location.split(' · ').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    if (parts.length >= 3) return '${parts.first}, ${parts.last}';
    if (parts.length == 2) return parts.join(', ');
    return location;
  }

  /// 꽉 찼거나 모집완료 상태면 true
  bool get isFullOrClosed => isRecruitmentClosed || currentMembers >= maxMembers;

  PieceRoom copyWith({
    String? title,
    int? currentMembers,
    int? maxMembers,
    String? creator,
    String? location,
    DateTime? meetingAt,
    String? description,
    String? creatorProfileImageUrl,
    bool? isRecruitmentClosed,
  }) {
    return PieceRoom(
      title: title ?? this.title,
      currentMembers: currentMembers ?? this.currentMembers,
      maxMembers: maxMembers ?? this.maxMembers,
      creator: creator ?? this.creator,
      location: location ?? this.location,
      meetingAt: meetingAt ?? this.meetingAt,
      description: description ?? this.description,
      creatorProfileImageUrl: creatorProfileImageUrl ?? this.creatorProfileImageUrl,
      isRecruitmentClosed: isRecruitmentClosed ?? this.isRecruitmentClosed,
    );
  }
}
