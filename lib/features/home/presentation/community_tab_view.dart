import 'dart:ui';

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
    final posts = <Map<String, dynamic>>[];
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
      itemCount: posts.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final post = posts[index];
        return PostCard(
          userName: post['userName'] as String,
          userProfileImageUrl: post['userProfileImageUrl'] as String?,
          title: post['title'] as String,
          location: post['location'] as String?,
          date: post['date'] as String?,
          viewCount: post['viewCount'] as int?,
          likeCount: post['likeCount'] as int? ?? 0,
          commentCount: post['commentCount'] as int? ?? 0,
          imageUrl: post['imageUrl'] as String?,
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
      onTap: () {},
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

