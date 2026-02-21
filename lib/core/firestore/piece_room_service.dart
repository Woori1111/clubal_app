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
}
