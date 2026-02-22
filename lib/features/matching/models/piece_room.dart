import 'package:cloud_firestore/cloud_firestore.dart';

class PieceRoom {
  const PieceRoom({
    this.id,
    required this.title,
    required this.currentMembers,
    required this.maxMembers,
    required this.creator,
    this.creatorUid,
    required this.location,
    required this.meetingAt,
    this.description,
    this.creatorProfileImageUrl,
    this.isRecruitmentClosed = false,
    this.applicantIds = const [],
    this.memberIds = const [],
    this.isAutoMatch = false,
    this.autoMatchDate,
  });

  /// Firestore 문서 ID. 로컬 생성 시 null.
  final String? id;
  final String title;
  final int currentMembers;
  final int maxMembers;
  final String creator;
  /// 방 만든 사람의 Firebase UID (내 방 판별용)
  final String? creatorUid;
  final String location;
  final DateTime meetingAt;
  final String? description;
  /// 만든 유저 프로필 사진 URL (없으면 creator 첫 글자로 표시)
  final String? creatorProfileImageUrl;
  /// 모집완료로 상태 변경했을 때 true (꽉 찼거나 이 값이 true면 빨간색 표시)
  final bool isRecruitmentClosed;
  /// 신청한 사용자 UID 목록
  final List<String> applicantIds;
  /// 확정된 멤버 UID (자동매치 완료 시 6명)
  final List<String> memberIds;
  /// 자동매치로 생성된 방 여부
  final bool isAutoMatch;
  /// 자동매치 날짜 키 "YYYY-MM-DD" (같은 날짜+장소 방 찾기용)
  final String? autoMatchDate;

  String get capacityLabel => '$currentMembers/$maxMembers';

  /// 화면에 표시할 장소: 지역(또는 구분)과 클럽명만, 가운데 점(•) 구분. "A · B · C" → "A • C"
  String get locationDisplay {
    final parts = location
        .replaceAll(' • ', ' · ')
        .split(' · ')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    if (parts.length >= 3) return '${parts.first} • ${parts.last}';
    if (parts.length == 2) return '${parts[0]} • ${parts[1]}';
    return location;
  }

  /// 꽉 찼거나 모집완료 상태면 true
  bool get isFullOrClosed => isRecruitmentClosed || currentMembers >= maxMembers;

  PieceRoom copyWith({
    String? id,
    String? title,
    int? currentMembers,
    int? maxMembers,
    String? creator,
    String? creatorUid,
    String? location,
    DateTime? meetingAt,
    String? description,
    String? creatorProfileImageUrl,
    bool? isRecruitmentClosed,
    List<String>? applicantIds,
    List<String>? memberIds,
    bool? isAutoMatch,
    String? autoMatchDate,
  }) {
    return PieceRoom(
      id: id ?? this.id,
      title: title ?? this.title,
      currentMembers: currentMembers ?? this.currentMembers,
      maxMembers: maxMembers ?? this.maxMembers,
      creator: creator ?? this.creator,
      creatorUid: creatorUid ?? this.creatorUid,
      location: location ?? this.location,
      meetingAt: meetingAt ?? this.meetingAt,
      description: description ?? this.description,
      creatorProfileImageUrl: creatorProfileImageUrl ?? this.creatorProfileImageUrl,
      isRecruitmentClosed: isRecruitmentClosed ?? this.isRecruitmentClosed,
      applicantIds: applicantIds ?? this.applicantIds,
      memberIds: memberIds ?? this.memberIds,
      isAutoMatch: isAutoMatch ?? this.isAutoMatch,
      autoMatchDate: autoMatchDate ?? this.autoMatchDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'currentMembers': currentMembers,
      'maxMembers': maxMembers,
      'creator': creator,
      'creatorUid': creatorUid,
      'location': location,
      'meetingAt': Timestamp.fromDate(meetingAt),
      'description': description,
      'creatorProfileImageUrl': creatorProfileImageUrl,
      'isRecruitmentClosed': isRecruitmentClosed,
      'applicantIds': applicantIds,
      'memberIds': memberIds,
      'isAutoMatch': isAutoMatch,
      'autoMatchDate': autoMatchDate,
    };
  }

  static PieceRoom fromMap(String docId, Map<String, dynamic> map) {
    final meetingAt = map['meetingAt'];
    return PieceRoom(
      id: docId,
      title: map['title'] as String? ?? '',
      currentMembers: (map['currentMembers'] as num?)?.toInt() ?? 0,
      maxMembers: (map['maxMembers'] as num?)?.toInt() ?? 4,
      creator: map['creator'] as String? ?? '',
      creatorUid: map['creatorUid'] as String?,
      location: map['location'] as String? ?? '',
      meetingAt: meetingAt is Timestamp
          ? meetingAt.toDate()
          : DateTime.now(),
      description: map['description'] as String?,
      creatorProfileImageUrl: map['creatorProfileImageUrl'] as String?,
      isRecruitmentClosed: map['isRecruitmentClosed'] as bool? ?? false,
      applicantIds: List<String>.from(map['applicantIds'] as List<dynamic>? ?? []),
      memberIds: List<String>.from(map['memberIds'] as List<dynamic>? ?? []),
      isAutoMatch: map['isAutoMatch'] as bool? ?? false,
      autoMatchDate: map['autoMatchDate'] as String?,
    );
  }
}
