import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:clubal_app/features/matching/models/piece_room.dart';

/// 자동매치 슬롯(날짜+장소) 단위로 대기열 관리. 6명 모이면 매칭완료 + 조각방·채팅방 생성.
class AutoMatchService {
  AutoMatchService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  static const String _collection = 'auto_match_slots';
  static const int _targetCount = 6;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection(_collection);

  String? get _currentUid => _auth.currentUser?.uid;

  /// 슬롯 문서 ID 생성 (날짜 + 장소 라벨로 유일)
  static String slotId(String date, String placeLabel) {
    final safe = placeLabel
        .replaceAll(RegExp(r'[·\s•]'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .trim();
    return '${date}_$safe';
  }

  /// 자동매치 슬롯에 참가. 6명이 되면 조각방 생성 후 완료 처리.
  /// 반환: (생성된 조각방 ID or null, 현재 슬롯 인원 수)
  Future<AutoMatchJoinResult> joinSlot({
    required String date,
    required String placeLabel,
    required DateTime meetingAt,
    String? userName,
  }) async {
    final uid = _currentUid;
    if (uid == null) {
      return AutoMatchJoinResult(error: '로그인이 필요합니다.');
    }

    final id = slotId(date, placeLabel);
    final ref = _col.doc(id);

    return _firestore.runTransaction<AutoMatchJoinResult>((tx) async {
      final snap = await tx.get(ref);
      final now = FieldValue.serverTimestamp();

      List<String> userIds;
      String status;
      if (!snap.exists || snap.data() == null) {
        userIds = [uid];
        status = 'waiting';
        tx.set(ref, {
          'date': date,
          'placeLabel': placeLabel,
          'userIds': userIds,
          'status': status,
          'createdAt': now,
          'updatedAt': now,
        });
      } else {
        final data = snap.data()!;
        status = data['status'] as String? ?? 'waiting';
        if (status == 'completed') {
          return AutoMatchJoinResult(error: '이미 매칭이 완료된 슬롯입니다.');
        }
        userIds = List<String>.from(data['userIds'] as List<dynamic>? ?? []);
        if (userIds.contains(uid)) {
          return AutoMatchJoinResult(
            pieceRoomId: null,
            currentCount: userIds.length,
            slotId: id,
          );
        }
        userIds = [...userIds, uid];
        tx.update(ref, {
          'userIds': userIds,
          'updatedAt': now,
        });
      }

      if (userIds.length < _targetCount) {
        return AutoMatchJoinResult(
          pieceRoomId: null,
          currentCount: userIds.length,
          slotId: id,
        );
      }

      // 6명 도달 → 조각방 생성, 슬롯 완료
      final room = PieceRoom(
        title: '$placeLabel · $date',
        currentMembers: _targetCount,
        maxMembers: _targetCount,
        creator: userName ?? '알 수 없음',
        creatorUid: userIds.first,
        location: placeLabel,
        meetingAt: meetingAt,
        description: '자동매치로 만난 6인 방입니다.',
        isRecruitmentClosed: true,
        memberIds: userIds,
        isAutoMatch: true,
      );

      final roomRef = _firestore.collection('piece_rooms').doc();
      tx.set(roomRef, room.toMap()..['creatorUid'] = userIds.first);

      tx.update(ref, {
        'status': 'completed',
        'completedPieceRoomId': roomRef.id,
        'userIds': userIds,
        'updatedAt': now,
      });

      return AutoMatchJoinResult(
        pieceRoomId: roomRef.id,
        currentCount: _targetCount,
        slotId: id,
        memberIds: userIds,
        completedRoom: room.copyWith(id: roomRef.id),
      );
    });
  }

  /// 슬롯 실시간 인원 수 스트림
  Stream<AutoMatchSlotState> streamSlot(String slotId) {
    return _col.doc(slotId).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) {
        return AutoMatchSlotState(slotId: slotId, count: 0, status: 'waiting');
      }
      final d = doc.data()!;
      final userIds = List<String>.from(d['userIds'] as List<dynamic>? ?? []);
      final status = d['status'] as String? ?? 'waiting';
      return AutoMatchSlotState(
        slotId: slotId,
        count: userIds.length,
        status: status,
        completedPieceRoomId: d['completedPieceRoomId'] as String?,
      );
    });
  }

  /// 슬롯 참가 취소 (대기 중일 때만)
  Future<void> leaveSlot(String slotId) async {
    final uid = _currentUid;
    if (uid == null) return;
    final ref = _col.doc(slotId);
    await _firestore.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (!snap.exists) return;
      final d = snap.data()!;
      if (d['status'] == 'completed') return;
      final userIds = List<String>.from(d['userIds'] as List<dynamic>? ?? []);
      final next = userIds.where((id) => id != uid).toList();
      if (next.isEmpty) {
        tx.delete(ref);
      } else {
        tx.update(ref, {
          'userIds': next,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    });
  }
}

class AutoMatchJoinResult {
  const AutoMatchJoinResult({
    this.pieceRoomId,
    this.currentCount = 0,
    this.slotId,
    this.memberIds,
    this.completedRoom,
    this.error,
  });

  final String? pieceRoomId;
  final int currentCount;
  final String? slotId;
  final List<String>? memberIds;
  final PieceRoom? completedRoom;
  final String? error;
}

class AutoMatchSlotState {
  const AutoMatchSlotState({
    required this.slotId,
    required this.count,
    required this.status,
    this.completedPieceRoomId,
  });

  final String slotId;
  final int count;
  final String status;
  final String? completedPieceRoomId;
}
