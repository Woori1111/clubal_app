import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// 커뮤니티 게시글 생성·조회용 서비스.
/// LikeService와 동일한 Firestore `community_posts` 컬렉션 사용.
class CommunityPostService {
  CommunityPostService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const String _postsCollection = 'community_posts';

  CollectionReference<Map<String, dynamic>> get _posts =>
      _firestore.collection(_postsCollection);

  /// 새 게시글 작성. 반환: 생성된 문서 ID.
  Future<String> createPost({
    required String title,
    required String content,
    String? location,
    String? userName,
    String? userProfileImageUrl,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    final doc = await _posts.add({
      'userId': user?.uid,
      'userName': userName ?? user?.displayName ?? '익명',
      'userProfileImageUrl': userProfileImageUrl ?? user?.photoURL,
      'title': title,
      'content': content,
      'location': location?.trim().isEmpty == true ? null : location,
      'date': '방금 전',
      'createdAt': FieldValue.serverTimestamp(),
      'viewCount': 0,
      'likeCount': 0,
      'commentCount': 0,
      'imageUrl': null,
      'likedBy': <String>[],
    });
    return doc.id;
  }
}
