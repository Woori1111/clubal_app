import 'dart:ui';

import 'package:clubal_app/core/theme/app_glass_styles.dart';
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
                const Center(
                  child: Text(
                    '인기 컨텐츠',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                    ),
                  ),
                ),
              const Positioned(
                right: 24,
                bottom: 82,
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
    final posts = [
      {
        'userName': '김민수',
        'userProfileImageUrl': null,
        'title': '오늘 클럽 가실 분 구해요!',
        'location': '강남',
        'date': '2시간 전',
        'viewCount': 24,
        'likeCount': 3,
        'commentCount': 5,
        'imageUrl': null,
      },
      {
        'userName': '이지은',
        'userProfileImageUrl': null,
        'title': '주말에 함께 갈 사람 있나요? 정말 재밌는 클럽이에요!',
        'location': '홍대',
        'date': '5시간 전',
        'viewCount': 48,
        'likeCount': 7,
        'commentCount': 12,
        'imageUrl': 'https://picsum.photos/200/200?random=1',
      },
      {
        'userName': '박준호',
        'userProfileImageUrl': null,
        'title': '클럽 테이블비 1/N으로 나눠요',
        'location': '압구정',
        'date': '1일 전',
        'viewCount': 67,
        'likeCount': 2,
        'commentCount': 8,
        'imageUrl': null,
      },
    ];

    return ListView.separated(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      itemCount: posts.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final post = posts[index];
        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => PostDetailPage(
                  userName: post['userName'] as String,
                  userProfileImageUrl: post['userProfileImageUrl'] as String?,
                  title: post['title'] as String,
                  content: post['content'] as String?,
                  location: post['location'] as String?,
                  date: post['date'] as String?,
                  viewCount: post['viewCount'] as int?,
                  likeCount: post['likeCount'] as int? ?? 0,
                  commentCount: post['commentCount'] as int? ?? 0,
                  imageUrl: post['imageUrl'] as String?,
                ),
              ),
            );
          },
          child: PostCard(
            userName: post['userName'] as String,
            userProfileImageUrl: post['userProfileImageUrl'] as String?,
            title: post['title'] as String,
            location: post['location'] as String?,
            date: post['date'] as String?,
            viewCount: post['viewCount'] as int?,
            likeCount: post['likeCount'] as int? ?? 0,
            commentCount: post['commentCount'] as int? ?? 0,
            imageUrl: post['imageUrl'] as String?,
          ),
        );
      },
    );
  }
}

class _WriteFab extends StatelessWidget {
  const _WriteFab();

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, 4),
      child: GestureDetector(
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
              decoration: AppGlassStyles.card(radius: 28),
              child: const Center(
                child: Icon(
                  Icons.edit_rounded,
                  color: Colors.black,
                  size: 24,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

