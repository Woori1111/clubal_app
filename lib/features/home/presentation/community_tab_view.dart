import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:clubal_app/core/utils/app_dialogs.dart';
import 'package:clubal_app/features/home/presentation/post_detail_page.dart';
import 'package:clubal_app/features/home/presentation/write_post_page.dart';
import 'package:clubal_app/features/home/widgets/post_card.dart';
import 'package:clubal_app/features/navigation/widgets/clubal_top_tab_bar.dart';
import 'package:flutter/material.dart';

class CommunityTabView extends StatefulWidget {
  const CommunityTabView({super.key, this.scrollController});

  final ScrollController? scrollController;

  @override
  State<CommunityTabView> createState() => _CommunityTabViewState();
}

class _CommunityTabViewState extends State<CommunityTabView> {
  int _topTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
          child: ClubalTopTabBar(
            tabs: const ['최신', '인기'],
            selectedIndex: _topTabIndex,
            onChanged: (index) => setState(() => _topTabIndex = index),
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              if (_topTabIndex == 0)
                _LatestPostsList(scrollController: widget.scrollController)
              else
                Center(
                  child: Text(
                    '인기 컨텐츠',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 18,
                    ),
                  ),
                ),
              const Positioned(
                right: 24,
                bottom: 96,
                child: _WriteFab(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LatestPostsList extends StatefulWidget {
  const _LatestPostsList({this.scrollController});

  final ScrollController? scrollController;

  @override
  State<_LatestPostsList> createState() => _LatestPostsListState();
}

class _LatestPostsListState extends State<_LatestPostsList> {
  static const int _limit = 20;

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _posts = [];
  bool _isLoading = true;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('community_posts')
          .orderBy('createdAt', descending: true)
          .limit(_limit)
          .get();
      if (mounted) {
        setState(() {
          _posts = snapshot.docs;
          _isLoading = false;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '데이터를 불러오는 중 오류가 발생했습니다.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _loadPosts,
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    if (_isLoading && _posts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_posts.isEmpty) {
      return Center(
        child: Text(
          '아직 작성된 글이 없습니다.\n첫 글을 작성해보세요!',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 16,
          ),
        ),
      );
    }

    final posts = _posts;
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? 'guest_user';

    return CustomRefreshIndicator(
      onRefresh: _loadPosts,
      trigger: IndicatorTrigger.leadingEdge,
      triggerMode: IndicatorTriggerMode.onEdge,
      builder: (context, child, controller) => _PillRefreshLayout(
        child: child,
        controller: controller,
      ),
      child: ListView.separated(
        controller: widget.scrollController,
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
          itemCount: posts.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final doc = posts[index];
            final data = doc.data();
            final likedBy = data['likedBy'] as List<dynamic>? ?? [];
            final isLiked = likedBy.contains(currentUserId);
            final createdAt = data['createdAt'] as Timestamp?;
            final isAuthor = data['userId'] == currentUserId;

            return GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => PostDetailPage(
                      postId: doc.id,
                      userName: data['userName'] as String? ?? '알 수 없음',
                      userProfileImageUrl: data['userProfileImageUrl'] as String?,
                      title: data['title'] as String? ?? '제목 없음',
                      content: data['content'] as String?,
                      location: data['location'] as String?,
                      createdAt: createdAt?.toDate(),
                      viewCount: data['viewCount'] as int?,
                      likeCount: data['likeCount'] as int? ?? 0,
                      commentCount: data['commentCount'] as int? ?? 0,
                      imageUrl: data['imageUrl'] as String?,
                      likedBy: likedBy,
                      isAuthor: isAuthor,
                    ),
                  ),
                );
              },
              child: PostCard(
                userName: data['userName'] as String? ?? '알 수 없음',
                userProfileImageUrl: data['userProfileImageUrl'] as String?,
                title: data['title'] as String? ?? '제목 없음',
                location: data['location'] as String?,
                createdAt: createdAt?.toDate(),
                viewCount: data['viewCount'] as int?,
                likeCount: data['likeCount'] as int? ?? 0,
                commentCount: data['commentCount'] as int? ?? 0,
                imageUrl: data['imageUrl'] as String?,
                isLiked: isLiked,
                likeButtonColoredWhenLiked: false,
                likeButtonEnabled: false,
                onMoreTap: () async {
                  final result = await showMoreOptionsDialog(context, isAuthor: isAuthor);
                  if (result != null && context.mounted) {
                    if (result == 'delete') {
                      // 실제 삭제 로직 (생략 또는 구현)
                      showMessageDialog(context, message: '글이 삭제되었습니다.');
                    } else if (result == 'edit') {
                      showMessageDialog(context, message: '수정 기능은 준비 중입니다.');
                    } else {
                      showMessageDialog(context, message: '처리되었습니다.');
                    }
                  }
                },
              ),
            );
          },
        ),
    );
  }
}

/// 목록 고정 + 알약형 로딩 인디케이터
class _PillRefreshLayout extends StatelessWidget {
  const _PillRefreshLayout({
    required this.child,
    required this.controller,
  });

  final Widget child;
  final IndicatorController controller;

  @override
  Widget build(BuildContext context) {
    final isVisible = controller.value > 0.01;
    final theme = Theme.of(context);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        if (isVisible)
          Positioned(
            top: 8 + (controller.value * 24),
            left: 0,
            right: 0,
            child: Center(
              child: Material(
                elevation: 2,
                borderRadius: BorderRadius.circular(20),
                color: theme.colorScheme.surfaceContainerHighest,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: controller.isLoading
                        ? CircularProgressIndicator(
                            strokeWidth: 2,
                            color: theme.colorScheme.primary,
                          )
                        : CircularProgressIndicator(
                            value: controller.value.clamp(0.0, 1.0),
                            strokeWidth: 2,
                            color: theme.colorScheme.primary,
                          ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _WriteFab extends StatelessWidget {
  const _WriteFab();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const WritePostPage(),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
                width: 1.2,
              ),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF9AE1FF), Color(0xFF69C6F6)],
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x5522B8FF),
                  blurRadius: 16,
                  spreadRadius: -8,
                  offset: Offset(0, 7),
                ),
              ],
            ),
            child: Icon(
              Icons.edit_rounded,
              color: Theme.of(context).colorScheme.onPrimary,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}

