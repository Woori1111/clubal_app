import 'dart:ui';

import 'package:clubal_app/core/theme/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:clubal_app/core/utils/app_dialogs.dart';
import 'package:clubal_app/features/home/presentation/post_detail_page.dart';
import 'package:clubal_app/features/home/presentation/write_post_page.dart';
import 'package:clubal_app/features/chat/widgets/segment_tab.dart';
import 'package:clubal_app/features/home/widgets/post_card.dart';
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
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
          child: SegmentTab(
            labels: const ['최신', '인기'],
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
                right: 14,
                bottom: 96,
                child: _WriteFabExpanding(),
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
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
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
                      postUserId: data['userId'] as String?,
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
                  final result = await showMoreOptionsDialog(
                    context,
                    isAuthor: isAuthor,
                    showHideUserOption: false,
                  );
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

/// 매칭 탭 AutoMatchFab과 동일 디자인: 접히면 원형(아이콘), 펼치면 캡슐("글 쓰기").
class _WriteFabExpanding extends StatefulWidget {
  const _WriteFabExpanding();

  @override
  State<_WriteFabExpanding> createState() => _WriteFabExpandingState();
}

class _WriteFabExpandingState extends State<_WriteFabExpanding> {
  bool _expanded = false;
  static const double _size = 58.0;
  static const double _radius = 29.0;
  static const double _expandedWidth = 156.0;

  void _onTap() {
    if (!_expanded) {
      setState(() => _expanded = true);
    } else {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => const WritePostPage(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final width = _expanded ? _expandedWidth : _size;
    final cornerRadius = _radius;

    return GestureDetector(
      onTap: _onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        width: width,
        height: _size,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(cornerRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(cornerRadius),
                border: Border.all(
                  color: Color.fromRGBO(255, 255, 255, isDark ? 0.33 : 0.66),
                  width: 1.5,
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          const Color.fromRGBO(255, 255, 255, 0.33),
                          const Color.fromRGBO(234, 242, 250, 0.11),
                        ]
                      : [
                          const Color.fromRGBO(255, 255, 255, 0.7),
                          const Color.fromRGBO(234, 242, 250, 0.4),
                        ],
                ),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadowSoft,
                    blurRadius: 16,
                    spreadRadius: -4,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(scale: animation, child: child),
                  ),
                  child: _expanded
                      ? Text(
                          '글 쓰기',
                          key: const ValueKey('expanded_label'),
                          style: TextStyle(
                            color: onSurface,
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        )
                      : Icon(
                          Icons.edit_rounded,
                          key: const ValueKey('compact_icon'),
                          color: onSurface,
                          size: 26,
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

