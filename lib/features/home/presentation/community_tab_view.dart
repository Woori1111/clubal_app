import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:clubal_app/features/home/presentation/post_detail_page.dart';
import 'package:clubal_app/features/home/presentation/write_post_page.dart';
import 'package:clubal_app/features/home/widgets/post_card.dart';
import 'package:clubal_app/features/navigation/widgets/clubal_top_tab_bar.dart';
import 'package:flutter/material.dart';

class CommunityTabView extends StatefulWidget {
  const CommunityTabView({super.key});

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
                _LatestPostsList()
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

class _LatestPostsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('community_posts')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('데이터를 불러오는 중 오류가 발생했습니다.'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final posts = snapshot.data?.docs ?? [];

        if (posts.isEmpty) {
          return Center(
            child: Text(
              '아직 작성된 글이 없습니다.\n첫 글을 작성해보세요!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant, 
                fontSize: 16
              ),
            ),
          );
        }

        return ListView.separated(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
          itemCount: posts.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final doc = posts[index];
            final data = doc.data() as Map<String, dynamic>;
            final likedBy = data['likedBy'] as List<dynamic>? ?? [];
            final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? 'guest_user';
            final isLiked = likedBy.contains(currentUserId);

            final createdAt = data['createdAt'] as Timestamp?;

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
              ),
            );
          },
        );
      },
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

