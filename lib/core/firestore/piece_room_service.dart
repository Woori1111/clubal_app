import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:clubal_app/features/matching/models/piece_room.dart';

/// 조각 방(piece_room) Firestore CRUD 및 스트림
class PieceRoomService {
  PieceRoomService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  static const String _collection = 'piece_rooms';

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection(_collection);

  String? get _currentUid => _auth.currentUser?.uid;

  /// 방 생성. 반환: 문서 ID
  Future<String> createRoom(PieceRoom room) async {
    final uid = _currentUid;
    final data = room.toMap();
    if (uid != null) data['creatorUid'] = uid;
    final doc = await _col.add(data);
    return doc.id;
  }

  /// 전체 조각 목록 스트림 (최신순)
  Stream<List<PieceRoom>> streamAllRooms() {
    return _col
        .orderBy('meetingAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => PieceRoom.fromMap(d.id, d.data()))
            .toList());
  }

  /// 내가 만든 조각 스트림
  Stream<List<PieceRoom>> streamMyRooms() {
    final uid = _currentUid;
    if (uid == null) return Stream.value([]);
    return _col
        .where('creatorUid', isEqualTo: uid)
        .snapshots()
        .map((snap) {
          final list = snap.docs
              .map((d) => PieceRoom.fromMap(d.id, d.data()))
              .toList();
          list.sort((a, b) => b.meetingAt.compareTo(a.meetingAt));
          return list;
        });
  }

  /// 모집 상태 변경
  Future<void> updateRecruitmentClosed(String roomId, bool closed) async {
    await _col.doc(roomId).update({'isRecruitmentClosed': closed});
  }

  /// 방 삭제
  Future<void> deleteRoom(String roomId) async {
    await _col.doc(roomId).delete();
  }

  /// 방에 신청 (applicantIds에 현재 유저 추가)
  Future<void> applyToRoom(String roomId) async {
    final uid = _currentUid;
    if (uid == null) return;
    await _col.doc(roomId).update({
      'applicantIds': FieldValue.arrayUnion([uid]),
    });
  }

  /// 단일 방 스트림 (상세/수정 반영)
  Stream<PieceRoom?> streamRoom(String roomId) {
    return _col.doc(roomId).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return PieceRoom.fromMap(doc.id, doc.data()!);
    });
  }

  /// 내가 멤버로 포함된 방 스트림 (자동매치 완료 등, memberIds에 내 UID 포함)
  Stream<List<PieceRoom>> streamRoomsWhereIAmMember() {
    final uid = _currentUid;
    if (uid == null) return Stream.value([]);
    return _col
        .where('memberIds', arrayContains: uid)
        .snapshots()
        .map((snap) {
          final list = snap.docs
              .map((d) => PieceRoom.fromMap(d.id, d.data()))
              .toList();
          list.sort((a, b) => b.meetingAt.compareTo(a.meetingAt));
          return list;
        });
  }

  static const int _autoMatchMax = 6;

  /// 자동매치: 같은 날짜+장소 방이 있으면 참가, 없으면 새 방 생성. 매칭중에 카드로 바로 노출.
  /// 6명이 되면 isRecruitmentClosed 처리 후 채팅방은 호출측에서 생성.
  Future<AutoMatchRoomResult> findOrCreateAutoMatchRoom({
    required String placeLabel,
    required DateTime meetingAt,
    required String dateKey,
    String? userName,
  }) async {
    final uid = _currentUid;
    if (uid == null) {
      return AutoMatchRoomResult(error: '로그인이 필요합니다.');
    }

    final existingSnap = await _col
        .where('isAutoMatch', isEqualTo: true)
        .where('location', isEqualTo: placeLabel)
        .where('autoMatchDate', isEqualTo: dateKey)
        .limit(1)
        .get();

    if (existingSnap.docs.isNotEmpty) {
      final docRef = existingSnap.docs.first.reference;
      return _firestore.runTransaction<AutoMatchRoomResult>((tx) async {
        final doc = await tx.get(docRef);
        if (!doc.exists || doc.data() == null) {
          return _createAutoMatchRoomInTx(tx, placeLabel, meetingAt, dateKey, uid, userName);
        }
        final data = doc.data()!;
        final room = PieceRoom.fromMap(doc.id, data);
        if (room.currentMembers >= _autoMatchMax) {
          return AutoMatchRoomResult(error: '이미 6명이 모인 매칭입니다.');
        }
        if (room.memberIds.contains(uid)) {
          return AutoMatchRoomResult(room: room.copyWith(id: doc.id));
        }
        final newMemberIds = [...room.memberIds, uid];
        final newCount = newMemberIds.length;
        tx.update(docRef, {
          'memberIds': newMemberIds,
          'currentMembers': newCount,
          if (newCount >= _autoMatchMax) 'isRecruitmentClosed': true,
        });
        final updated = room.copyWith(
          id: doc.id,
          memberIds: newMemberIds,
          currentMembers: newCount,
          isRecruitmentClosed: newCount >= _autoMatchMax,
        );
        return AutoMatchRoomResult(
          room: updated,
          isNewlyCompleted: newCount >= _autoMatchMax,
          memberIds: newMemberIds,
        );
      });
    }

    return _firestore.runTransaction<AutoMatchRoomResult>((tx) async {
      return _createAutoMatchRoomInTx(tx, placeLabel, meetingAt, dateKey, uid, userName);
    });
  }

  Future<AutoMatchRoomResult> _createAutoMatchRoomInTx(
    Transaction tx,
    String placeLabel,
    DateTime meetingAt,
    String dateKey,
    String uid,
    String? userName,
  ) async {
    final newRoom = PieceRoom(
      title: '$placeLabel · $dateKey',
      currentMembers: 1,
      maxMembers: _autoMatchMax,
      creator: userName ?? '참여자',
      creatorUid: uid,
      location: placeLabel,
      meetingAt: meetingAt,
      description: '자동매치로 6명 모이면 매칭완료·채팅방 생성.',
      isRecruitmentClosed: false,
      memberIds: [uid],
      isAutoMatch: true,
      autoMatchDate: dateKey,
    );
    final ref = _col.doc();
    tx.set(ref, newRoom.toMap()..['creatorUid'] = uid);
    return AutoMatchRoomResult(room: newRoom.copyWith(id: ref.id));
  }
}

class AutoMatchRoomResult {
  const AutoMatchRoomResult({
    this.room,
    this.isNewlyCompleted = false,
    this.memberIds,
    this.error,
  });

  final PieceRoom? room;
  final bool isNewlyCompleted;
  final List<String>? memberIds;
  final String? error;
}
