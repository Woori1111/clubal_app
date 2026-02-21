import 'dart:async';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:clubal_app/core/theme/app_colors.dart';
import 'package:clubal_app/core/theme/app_dimensions.dart';
import 'package:clubal_app/core/widgets/clubal_page_scaffold.dart';
import 'package:clubal_app/core/widgets/bouncing_like_button.dart';
import 'package:clubal_app/core/firestore/like_service.dart';
import 'package:clubal_app/core/utils/app_dialogs.dart';
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
    this.isAuthor = false,
    this.postUserId,
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
  final bool isAuthor;
  /// 게시글 작성자 UID (본인 작성 여부 판단용, null이면 기존 isAuthor 사용)
  final String? postUserId;

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  late String _currentUserId;

  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  bool _hasCommentText = false;

  @override
  void initState() {
    super.initState();
    _currentUserId = FirebaseAuth.instance.currentUser?.uid ?? 'guest_user';

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
    _commentFocusNode.dispose();
    super.dispose();
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
        'userId': user?.uid,
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
        showMessageDialog(context, message: '댓글 작성 실패: $e', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return ClubalPageScaffold(
      title: '글 상세',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _PostContentCard(
                          userName: widget.userName,
                          userProfileImageUrl: widget.userProfileImageUrl,
                          title: widget.title,
                          content: widget.content,
                          location: widget.location,
                          viewCount: widget.viewCount,
                          commentCount: widget.commentCount,
                          imageUrl: widget.imageUrl,
                          createdAt: widget.createdAt,
                          theme: theme,
                          likeSection: _PostLikeSection(
                            postId: widget.postId,
                            userId: _currentUserId,
                            initialIsLiked: widget.likedBy.contains(_currentUserId),
                            initialLikeCount: widget.likeCount,
                          ),
                          onMoreTap: () async {
                            final isAuthorForPost = widget.postUserId != null
                                ? (widget.postUserId == _currentUserId)
                                : widget.isAuthor;
                            final result = await showMoreOptionsDialog(
                              context,
                              isAuthor: isAuthorForPost,
                            );
                            if (result != null && context.mounted) {
                              if (result == 'delete') {
                                showMessageDialog(context, message: '글이 삭제되었습니다.');
                                Navigator.of(context).pop();
                              } else if (result == 'edit') {
                                showMessageDialog(context, message: '수정 기능은 준비 중입니다.');
                              } else {
                                showMessageDialog(context, message: '처리되었습니다.');
                              }
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        _CommentsCard(
                          postId: widget.postId,
                          currentUserId: _currentUserId,
                          onFocusRequested: () => _commentFocusNode.requestFocus(),
                        ),
                      ],
                    ),
                  ),
                ),
          _CommentInputBar(
            controller: _commentController,
            focusNode: _commentFocusNode,
            hasText: _hasCommentText,
            onSubmit: _submitComment,
          ),
        ],
      ),
    );
  }

}

// ---------------------------------------------------------------------------
// 좋아요 섹션 (자체 setState만 사용 → 상단 시간/RelativeTimeWidget 리빌드 방지)
// ---------------------------------------------------------------------------

class _PostLikeSection extends StatefulWidget {
  const _PostLikeSection({
    required this.postId,
    required this.userId,
    required this.initialIsLiked,
    required this.initialLikeCount,
  });

  final String postId;
  final String userId;
  final bool initialIsLiked;
  final int initialLikeCount;

  @override
  State<_PostLikeSection> createState() => _PostLikeSectionState();
}

class _PostLikeSectionState extends State<_PostLikeSection> {
  static const Duration _debounceDuration = Duration(milliseconds: 300);

  late bool _isLiked;
  late int _likeCount;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.initialIsLiked;
    _likeCount = widget.initialLikeCount;
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
      if (_isLiked) {
        _likeCount++;
      } else {
        _likeCount--;
      }
    });
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDuration, () {
      _debounceTimer = null;
      _flushToServer();
    });
  }

  Future<void> _flushToServer() async {
    try {
      await LikeService().setLiked(
        postId: widget.postId,
        userId: widget.userId,
        wantLiked: _isLiked,
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLiked = !_isLiked;
          if (_isLiked) {
            _likeCount++;
          } else {
            _likeCount--;
          }
        });
        showMessageDialog(context, message: '좋아요 처리 실패: $e', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BouncingLikeButton(
      isLiked: _isLiked,
      likeCount: _likeCount,
      onTap: _toggleLike,
      iconSize: 22,
      textSize: 14,
      defaultColor: AppColors.bodyText,
    );
  }
}

// ---------------------------------------------------------------------------
// 게시글 본문 카드
// ---------------------------------------------------------------------------

class _PostContentCard extends StatelessWidget {
  const _PostContentCard({
    required this.userName,
    this.userProfileImageUrl,
    required this.title,
    this.content,
    this.location,
    this.viewCount,
    required this.commentCount,
    this.imageUrl,
    this.createdAt,
    required this.theme,
    required this.likeSection,
    this.onMoreTap,
  });

  final String userName;
  final String? userProfileImageUrl;
  final String title;
  final String? content;
  final String? location;
  final int? viewCount;
  final int commentCount;
  final String? imageUrl;
  final DateTime? createdAt;
  final TextTheme? theme;
  final Widget likeSection;
  final VoidCallback? onMoreTap;

  @override
  Widget build(BuildContext context) {
    final detailStyle = TextStyle(color: AppColors.bodyText, fontSize: 14);
    return ClipRRect(
      borderRadius: AppDimensions.borderRadiusPill,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: AppDimensions.borderRadiusPill,
            border: Border.all(color: AppColors.glassCardBorderLight, width: 1.2),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.glassCardGradientStartLight,
                AppColors.glassCardGradientEndLight,
              ],
            ),
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                children: [
                  ClipOval(
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: AppColors.avatarBg,
                        shape: BoxShape.circle,
                      ),
                      child: userProfileImageUrl != null
                          ? Image.network(
                              userProfileImageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.person_rounded,
                                color: Colors.black,
                                size: 22,
                              ),
                            )
                          : const Icon(Icons.person_rounded, color: Colors.black, size: 22),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: theme?.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      if (createdAt != null) ...[
                        const SizedBox(height: 2),
                        RelativeTimeWidget(
                          dateTime: createdAt!,
                          style: theme?.bodySmall?.copyWith(color: AppColors.captionText, fontSize: 12) ?? const TextStyle(),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: theme?.titleLarge?.copyWith(fontWeight: FontWeight.w700, height: 1.3),
              ),
              const SizedBox(height: 12),
              Text(
                content ?? title,
                style: theme?.bodyLarge?.copyWith(color: AppColors.bodyText, height: 1.5),
              ),
              if (imageUrl != null) ...[
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: AppDimensions.borderRadiusCardSmall,
                  child: AspectRatio(
                    aspectRatio: 3 / 4,
                    child: Image.network(
                      imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.avatarBg,
                        child: const Icon(Icons.image_rounded, size: 48, color: Colors.black54),
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  if (location != null)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.location_on_rounded, size: 18, color: AppColors.bodyText),
                        const SizedBox(width: 4),
                        Text(location!, style: detailStyle),
                      ],
                    ),
                  if (viewCount != null)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.visibility_rounded, size: 18, color: AppColors.bodyText),
                        const SizedBox(width: 4),
                        Text('조회 $viewCount', style: detailStyle),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                children: [
                  likeSection,
                  const SizedBox(width: 24),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.chat_bubble_outline_rounded, size: 22, color: AppColors.bodyText),
                      const SizedBox(width: 6),
                      Text('$commentCount', style: detailStyle.copyWith(fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        if (onMoreTap != null)
          Positioned(
            top: 4,
            right: 4,
            child: IconButton(
              icon: const Icon(Icons.more_vert, color: AppColors.captionText, size: 24),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              onPressed: onMoreTap,
            ),
          ),
      ],
    ),
  ),
),
    );
  }
}

// ---------------------------------------------------------------------------
// 답글 카드 (댓글 목록 + 빈 상태)
// ---------------------------------------------------------------------------

class _CommentsCard extends StatelessWidget {
  const _CommentsCard({
    required this.postId,
    required this.currentUserId,
    required this.onFocusRequested,
  });

  final String postId;
  final String currentUserId;
  final VoidCallback onFocusRequested;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppDimensions.borderRadiusCardLarge,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
          decoration: BoxDecoration(
            borderRadius: AppDimensions.borderRadiusCardLarge,
            border: Border.all(color: AppColors.commentsCardBorder, width: 1.2),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.commentsCardStart,
                AppColors.commentsCardEnd,
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '답글',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('community_posts')
                    .doc(postId)
                    .collection('comments')
                    .orderBy('createdAt', descending: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    );
                  }
                  final docs = snapshot.data!.docs;
                  if (docs.isEmpty) {
                    return _EmptyCommentsState(onTap: onFocusRequested);
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final isLast = doc.id == docs.last.id;
                      return _CommentTile(
                        userName: data['userName'] as String? ?? '익명',
                        profileUrl: data['userProfileImageUrl'] as String?,
                        content: data['content'] as String? ?? '',
                        createdAt: data['createdAt'] as Timestamp?,
                        likeCount: data['likeCount'] as int? ?? 0,
                        likedBy: data['likedBy'] as List<dynamic>? ?? [],
                        currentUserId: currentUserId,
                        authorId: data['userId'] as String?,
                        docRef: doc.reference,
                        isLast: isLast,
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({
    required this.userName,
    this.profileUrl,
    required this.content,
    this.createdAt,
    required this.likeCount,
    required this.likedBy,
    required this.currentUserId,
    this.authorId,
    required this.docRef,
    required this.isLast,
  });

  final String userName;
  final String? profileUrl;
  final String content;
  final Timestamp? createdAt;
  final int likeCount;
  final List<dynamic> likedBy;
  final String currentUserId;
  final String? authorId;
  final DocumentReference<Object?> docRef;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final isLiked = likedBy.contains(currentUserId);
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
                    color: AppColors.avatarBg,
                    shape: BoxShape.circle,
                  ),
                  child: profileUrl != null
                      ? Image.network(
                          profileUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.person_rounded, color: Colors.black, size: 20),
                        )
                      : const Icon(Icons.person_rounded, color: Colors.black, size: 20),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              if (createdAt != null) ...[
                                const SizedBox(height: 2),
                                RelativeTimeWidget(
                                  dateTime: createdAt!.toDate(),
                                  style: const TextStyle(color: AppColors.captionText, fontSize: 12),
                                ),
                              ],
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.more_vert, color: AppColors.captionText, size: 20),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                          onPressed: () async {
                            final isAuthor = authorId == currentUserId;
                            final result = await showMoreOptionsDialog(
                              context,
                              isAuthor: isAuthor,
                              isComment: true,
                            );
                            if (result != null && context.mounted) {
                              if (result == 'delete') {
                                showMessageDialog(context, message: '댓글이 삭제되었습니다.');
                              } else if (result == 'edit') {
                                showMessageDialog(context, message: '수정 기능은 준비 중입니다.');
                              } else {
                                showMessageDialog(context, message: '처리되었습니다.');
                              }
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      content,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.bodyText,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () async {
                            if (isLiked) {
                              await docRef.update({
                                'likedBy': FieldValue.arrayRemove([currentUserId]),
                                'likeCount': FieldValue.increment(-1),
                              });
                            } else {
                              await docRef.update({
                                'likedBy': FieldValue.arrayUnion([currentUserId]),
                                'likeCount': FieldValue.increment(1),
                              });
                            }
                          },
                          child: Row(
                            children: [
                              Icon(
                                isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                size: 16,
                                color: isLiked ? Colors.redAccent : AppColors.captionText,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '$likeCount',
                                style: TextStyle(
                                  color: isLiked ? Colors.redAccent : AppColors.captionText,
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
                            color: AppColors.captionText,
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
            child: Divider(height: 1, color: AppColors.divider),
          ),
      ],
    );
  }
}

class _EmptyCommentsState extends StatelessWidget {
  const _EmptyCommentsState({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '첫 댓글을 남겨보세요.',
              style: TextStyle(fontSize: 13, color: AppColors.captionText),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: AppDimensions.borderRadiusCardLarge,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.writeButtonStart,
                      AppColors.writeButtonEnd,
                    ],
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.shadowBrand,
                      blurRadius: 8,
                      spreadRadius: -4,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '글쓰기',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(Icons.edit_rounded, color: Colors.white, size: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 하단 댓글 입력 바
// ---------------------------------------------------------------------------

class _CommentInputBar extends StatelessWidget {
  const _CommentInputBar({
    required this.controller,
    required this.focusNode,
    required this.hasText,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool hasText;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.inputBarBg,
        border: Border(top: BorderSide(color: AppColors.inputBarBorder, width: 1)),
      ),
      child: Row(
        children: [
          const Icon(Icons.camera_alt_outlined, color: AppColors.bodyText, size: 28),
          const SizedBox(width: 12),
          const Icon(Icons.photo_outlined, color: AppColors.bodyText, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.inputFieldBg,
                borderRadius: BorderRadius.circular(AppDimensions.radiusCommentInput),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      focusNode: focusNode,
                      decoration: const InputDecoration(
                        hintText: '댓글을 입력하세요',
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  AnimatedScale(
                    scale: hasText ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.elasticOut,
                    child: AnimatedOpacity(
                      opacity: hasText ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: GestureDetector(
                        onTap: hasText ? onSubmit : null,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 14),
                          child: Icon(Icons.send_rounded, color: AppColors.brandPrimary, size: 20),
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
