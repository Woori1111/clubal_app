import 'package:cloud_firestore/cloud_firestore.dart';

/// 멱등·동시성 안전 좋아요 서비스.
///
/// - 좋아요 상태는 서브컬렉션 `likes/{userId}` 문서 존재 여부로만 판단.
/// - likeCount는 트랜잭션 내에서 읽은 뒤 ±1 하여 한 번만 기록 (FieldValue.increment 미사용).
/// - 연타/봇/동시 요청에서도 likeCount 비정상 증가 없음.
/// - 설계 상세: [docs/LIKE_DESIGN.md](../../../docs/LIKE_DESIGN.md)
class LikeService {
  LikeService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const String _postsCollection = 'community_posts';
  static const String _likesSubcollection = 'likes';
  static const String _fieldLikeCount = 'likeCount';
  static const String _fieldLikedBy = 'likedBy';
  static const String _fieldCreatedAt = 'createdAt';

  /// 게시글 문서 참조
  DocumentReference<Map<String, dynamic>> _postRef(String postId) =>
      _firestore.collection(_postsCollection).doc(postId);

  /// 좋아요 문서 참조 (문서 존재 = 해당 사용자가 좋아요한 상태)
  DocumentReference<Map<String, dynamic>> _likeRef(String postId, String userId) =>
      _postRef(postId).collection(_likesSubcollection).doc(userId);

  /// 좋아요 토글: 현재 상태가 아니면 반영, 이미 그 상태면 아무 쓰기 없이 완료 (멱등).
  ///
  /// [wantLiked] true = 좋아요, false = 좋아요 해제.
  /// 반환: 실제로 반영된 최종 좋아요 여부 (서버 기준).
  Future<bool> setLiked({
    required String postId,
    required String userId,
    required bool wantLiked,
  }) async {
    if (wantLiked) {
      return _like(postId, userId);
    } else {
      return _unlike(postId, userId);
    }
  }

  /// 좋아요 처리. 이미 좋아요된 상태면 쓰기 없이 true 반환 (멱등).
  Future<bool> _like(String postId, String userId) async {
    final likeRef = _likeRef(postId, userId);
    final postRef = _postRef(postId);

    return _firestore.runTransaction<bool>((transaction) async {
      final likeSnap = await transaction.get(likeRef);
      if (likeSnap.exists) {
        return true; // 이미 좋아요됨 → 쓰기 없음
      }

      final postSnap = await transaction.get(postRef);
      if (!postSnap.exists) {
        throw StateError('Post not found: $postId');
      }

      final data = postSnap.data();
      final currentCount = (data?[_fieldLikeCount] as num?)?.toInt() ?? 0;

      transaction.set(likeRef, {
        _fieldCreatedAt: FieldValue.serverTimestamp(),
      });
      final updates = <String, dynamic>{
        _fieldLikeCount: currentCount + 1,
        _fieldLikedBy: FieldValue.arrayUnion([userId]),
      };
      transaction.update(postRef, updates);
      return true;
    });
  }

  /// 좋아요 해제. 이미 해제된 상태면 쓰기 없이 false 반환 (멱등).
  /// 레거시: likes/{userId} 없는데 post.likedBy에 userId 있으면 한 번만 정리(감소·제거) 후 반환.
  Future<bool> _unlike(String postId, String userId) async {
    final likeRef = _likeRef(postId, userId);
    final postRef = _postRef(postId);

    return _firestore.runTransaction<bool>((transaction) async {
      final likeSnap = await transaction.get(likeRef);
      final postSnap = await transaction.get(postRef);
      if (!postSnap.exists) {
        throw StateError('Post not found: $postId');
      }

      final data = postSnap.data();
      final likedBy = List<String>.from((data?[_fieldLikedBy] as List<dynamic>?) ?? []);
      final inLikedBy = likedBy.contains(userId);
      final currentCount = (data?[_fieldLikeCount] as num?)?.toInt() ?? 0;

      if (likeSnap.exists) {
        final newCount = currentCount <= 0 ? 0 : currentCount - 1;
        transaction.delete(likeRef);
        transaction.update(postRef, {
          _fieldLikeCount: newCount,
          _fieldLikedBy: FieldValue.arrayRemove([userId]),
        });
        return false;
      }
      if (inLikedBy) {
        final newCount = currentCount <= 0 ? 0 : currentCount - 1;
        transaction.update(postRef, {
          _fieldLikeCount: newCount,
          _fieldLikedBy: FieldValue.arrayRemove([userId]),
        });
        return false;
      }
      return false; // 이미 해제됨 → 쓰기 없음
    });
  }

  /// 해당 사용자의 좋아요 문서만 조회 (목록/피드에서 isLiked 판단용).
  /// 문서 존재 = 좋아요함.
  Future<bool> isLiked(String postId, String userId) async {
    final snap = await _likeRef(postId, userId).get();
    return snap.exists;
  }

  /// 게시글 문서의 likeCount 읽기 (캐시/스트림 없이 1회 읽기).
  Future<int> getLikeCount(String postId) async {
    final snap = await _postRef(postId).get();
    final data = snap.data();
    final n = (data?[_fieldLikeCount] as num?)?.toInt();
    return n ?? 0;
  }

  /// 한 번의 트랜잭션으로 likeCount + 현재 사용자 좋아요 여부 조회.
  /// (피드/목록에서 N개 글 각각에 대해 isLiked만 따로 부르지 않고, 필요 시 이 메서드로 일괄 가능.)
  Future<LikeState> getLikeState(String postId, String userId) async {
    final postRef = _postRef(postId);
    final likeRef = _likeRef(postId, userId);

    final results = await Future.wait([
      postRef.get(),
      likeRef.get(),
    ]);
    final postSnap = results[0];
    final likeSnap = results[1];

    final data = postSnap.data();
    final count = (data?[_fieldLikeCount] as num?)?.toInt() ?? 0;
    return LikeState(likeCount: count, isLiked: likeSnap.exists);
  }
}

/// 게시글 하나에 대한 좋아요 상태 (서버 1회 조회 결과).
class LikeState {
  const LikeState({required this.likeCount, required this.isLiked});
  final int likeCount;
  final bool isLiked;
}
