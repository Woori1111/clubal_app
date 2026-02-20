import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:clubal_app/core/widgets/clubal_background.dart';
import 'package:clubal_app/core/widgets/pressed_icon_action_button.dart';
import 'package:clubal_app/core/widgets/bouncing_like_button.dart';
import 'package:clubal_app/core/widgets/relative_time_widget.dart';
import 'package:flutter/material.dart';

/// 커뮤니티 포스트 상세 정보를 보여주는 페이지.
class PostDetailPage extends StatefulWidget {
  const PostDetailPage({
    super.key,
    required this.postId,
    required this.userName,
    this.userProfileImageUrl,
    required this.title,
    this.content,
    this.location,
    this.createdAt,
    this.viewCount,
    this.likeCount = 0,
    this.commentCount = 0,
    this.imageUrl,
    this.likedBy = const [],
  });

  final String postId;
  final String userName;
  final String? userProfileImageUrl;
  final String title;
  final String? content;
  final String? location;
  final DateTime? createdAt;
  final int? viewCount;
  final int likeCount;
  final int commentCount;
  final String? imageUrl;
  final List<dynamic> likedBy;

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  late int _likeCount;
  late bool _isLiked;
  late String _currentUserId;

  final TextEditingController _commentController = TextEditingController();
  bool _hasCommentText = false;

  @override
  void initState() {
    super.initState();
    _likeCount = widget.likeCount;
    // 임시로 익명 uid 사용 가능하도록 처리
    _currentUserId = FirebaseAuth.instance.currentUser?.uid ?? 'guest_user';
    _isLiked = widget.likedBy.contains(_currentUserId);

    _commentController.addListener(() {
      final hasText = _commentController.text.trim().isNotEmpty;
      if (_hasCommentText != hasText) {
        setState(() {
          _hasCommentText = hasText;
        });
      }
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _toggleLike() async {
    final docRef = FirebaseFirestore.instance.collection('community_posts').doc(widget.postId);
    
    // UI 즉시 업데이트 (Optimistic UI)
    setState(() {
      _isLiked = !_isLiked;
      if (_isLiked) {
        _likeCount++;
      } else {
        _likeCount--;
      }
    });

    try {
      if (_isLiked) {
        // 좋아요 추가
        await docRef.update({
          'likedBy': FieldValue.arrayUnion([_currentUserId]),
          'likeCount': FieldValue.increment(1),
        });
      } else {
        // 좋아요 취소
        await docRef.update({
          'likedBy': FieldValue.arrayRemove([_currentUserId]),
          'likeCount': FieldValue.increment(-1),
        });
      }
    } catch (e) {
      // 에러 발생 시 롤백
      if (mounted) {
        setState(() {
          _isLiked = !_isLiked;
          if (_isLiked) {
            _likeCount++;
          } else {
            _likeCount--;
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('좋아요 처리 실패: $e')),
        );
      }
    }
  }

  Future<void> _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    _commentController.clear();
    FocusScope.of(context).unfocus();
    setState(() => _hasCommentText = false);

    try {
      final user = FirebaseAuth.instance.currentUser;
      await FirebaseFirestore.instance
          .collection('community_posts')
          .doc(widget.postId)
          .collection('comments')
          .add({
        'userName': user?.displayName ?? '익명',
        'userProfileImageUrl': user?.photoURL,
        'content': text,
        'createdAt': FieldValue.serverTimestamp(),
        'likedBy': [],
        'likeCount': 0,
      });
      await FirebaseFirestore.instance
          .collection('community_posts')
          .doc(widget.postId)
          .update({
        'commentCount': FieldValue.increment(1),
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('댓글 작성 실패: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    const detailStyle = TextStyle(color: Color(0xFF2D3E54), fontSize: 14);

    return Scaffold(
      body: Stack(
        children: [
          const ClubalBackground(),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 16, 12),
                  child: Row(
                    children: [
                      PressedIconActionButton(
                        icon: Icons.arrow_back_ios_new_rounded,
                        tooltip: '뒤로가기',
                        onTap: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '글 상세',
                          style: theme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: const Color(0x55FFFFFF),
                              width: 1.2,
                            ),
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0x4DF3FAFF),
                                Color(0x33A7B7FF),
                              ],
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 작성자
                              Row(
                                children: [
                                  ClipOval(
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: const BoxDecoration(
                                        color: Color(0x33FFFFFF),
                                        shape: BoxShape.circle,
                                      ),
                                      child: widget.userProfileImageUrl != null
                                          ? Image.network(
                                              widget.userProfileImageUrl!,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) =>
                                                  const Icon(
                                                Icons.person_rounded,
                                                color: Colors.black,
                                                size: 22,
                                              ),
                                            )
                                          : const Icon(
                                              Icons.person_rounded,
                                              color: Colors.black,
                                              size: 22,
                                            ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.userName,
                                        style: theme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      if (widget.createdAt != null) ...[
                                        const SizedBox(height: 2),
                                        RelativeTimeWidget(
                                          dateTime: widget.createdAt!,
                                          style: theme.bodySmall?.copyWith(
                                            color: const Color(0xFF6E8199),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // 제목
                              Text(
                                widget.title,
                                style: theme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  height: 1.3,
                                ),
                              ),
                              const SizedBox(height: 12),
                              // 본문 (있으면 표시, 없으면 제목으로 대체)
                              Text(
                                widget.content ?? widget.title,
                                style: theme.bodyLarge?.copyWith(
                                  color: const Color(0xFF2D3E54),
                                  height: 1.5,
                                ),
                              ),
                              if (widget.imageUrl != null) ...[
                                const SizedBox(height: 16),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: AspectRatio(
                                    aspectRatio: 3 / 4,
                                    child: Image.network(
                                      widget.imageUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        color: const Color(0x33FFFFFF),
                                        child: const Icon(
                                          Icons.image_rounded,
                                          size: 48,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 20),
                              // 위치, 날짜, 조회수
                              Wrap(
                                spacing: 16,
                                runSpacing: 8,
                                children: [
                                  if (widget.location != null)
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.location_on_rounded,
                                          size: 18,
                                          color: Color(0xFF2D3E54),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          widget.location!,
                                          style: detailStyle,
                                        ),
                                      ],
                                    ),
                                  if (widget.viewCount != null)
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.visibility_rounded,
                                          size: 18,
                                          color: Color(0xFF2D3E54),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '조회 ${widget.viewCount}',
                                          style: detailStyle,
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              const Divider(height: 1),
                              const SizedBox(height: 12),
                              // 좋아요, 댓글
                              Row(
                                children: [
                                  BouncingLikeButton(
                                    isLiked: _isLiked,
                                    likeCount: _likeCount,
                                    onTap: _toggleLike,
                                    iconSize: 22,
                                    textSize: 14,
                                    defaultColor: const Color(0xFF2D3E54),
                                  ),
                                  const SizedBox(width: 24),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.chat_bubble_outline_rounded,
                                        size: 22,
                                        color: Color(0xFF2D3E54),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '${widget.commentCount}',
                                        style: detailStyle.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              _buildCommentsList(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                _buildBottomCommentBar(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('community_posts')
          .doc(widget.postId)
          .collection('comments')
          .orderBy('createdAt', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final userName = data['userName'] as String? ?? '익명';
            final profileUrl = data['userProfileImageUrl'] as String?;
            final content = data['content'] as String? ?? '';
            final createdAt = data['createdAt'] as Timestamp?;
            final likeCount = data['likeCount'] as int? ?? 0;
            final likedBy = data['likedBy'] as List<dynamic>? ?? [];
            final isLiked = likedBy.contains(_currentUserId);
            final isLast = doc.id == docs.last.id;

            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 20 : 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipOval(
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            color: Color(0x33FFFFFF),
                            shape: BoxShape.circle,
                          ),
                          child: profileUrl != null
                              ? Image.network(
                                  profileUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.person_rounded,
                                    color: Colors.black,
                                    size: 20,
                                  ),
                                )
                              : const Icon(
                                  Icons.person_rounded,
                                  color: Colors.black,
                                  size: 20,
                                ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  userName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: Color(0xFF1D2630),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                if (createdAt != null)
                                  RelativeTimeWidget(
                                    dateTime: createdAt.toDate(),
                                    style: const TextStyle(
                                      color: Color(0xFF6E8199),
                                      fontSize: 12,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              content,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF2D3E54),
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    final commentRef = doc.reference;
                                    if (isLiked) {
                                      await commentRef.update({
                                        'likedBy': FieldValue.arrayRemove([_currentUserId]),
                                        'likeCount': FieldValue.increment(-1),
                                      });
                                    } else {
                                      await commentRef.update({
                                        'likedBy': FieldValue.arrayUnion([_currentUserId]),
                                        'likeCount': FieldValue.increment(1),
                                      });
                                    }
                                  },
                                  child: Row(
                                    children: [
                                      Icon(
                                        isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                        size: 16,
                                        color: isLiked ? Colors.redAccent : const Color(0xFF6E8199),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '$likeCount',
                                        style: TextStyle(
                                          color: isLiked ? Colors.redAccent : const Color(0xFF6E8199),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                const Text(
                                  '답글쓰기',
                                  style: TextStyle(
                                    color: Color(0xFF6E8199),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: Divider(height: 1, color: Color(0x224C6078)),
                  ),
              ],
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildBottomCommentBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xB3FFFFFF),
        border: const Border(
          top: BorderSide(color: Color(0x334C6078), width: 1),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.camera_alt_outlined, color: Color(0xFF2D3E54), size: 28),
          const SizedBox(width: 12),
          const Icon(Icons.photo_outlined, color: Color(0xFF2D3E54), size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0x1A314D6A),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: const InputDecoration(
                        hintText: '댓글을 입력하세요...',
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  AnimatedScale(
                    scale: _hasCommentText ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.elasticOut,
                    child: AnimatedOpacity(
                      opacity: _hasCommentText ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: GestureDetector(
                        onTap: _hasCommentText ? _submitComment : null,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 14),
                          child: Icon(
                            Icons.send_rounded, // 비행기 모양 (종이비행기)
                            color: Color(0xFF2ECEF2),
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
