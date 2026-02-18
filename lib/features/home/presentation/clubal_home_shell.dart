import 'dart:io';
import 'dart:ui';

import 'package:clubal_app/core/widgets/clubal_background.dart';
import 'package:clubal_app/core/widgets/pressed_icon_action_button.dart';
import 'package:clubal_app/features/home/widgets/post_card.dart';
import 'package:clubal_app/features/matching/models/piece_room.dart';
import 'package:clubal_app/features/matching/presentation/create_piece_room_page.dart';
import 'package:clubal_app/features/matching/presentation/matching_tab_view.dart';
import 'package:clubal_app/features/navigation/models/nav_tab.dart';
import 'package:clubal_app/features/navigation/widgets/clubal_jelly_bottom_nav.dart';
import 'package:clubal_app/features/navigation/widgets/clubal_top_tab_bar.dart';
import 'package:clubal_app/features/notifications/presentation/past_notifications_page.dart';
import 'package:clubal_app/features/profile/presentation/profile_detail_page.dart';
import 'package:clubal_app/features/settings/presentation/clubal_settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// iOS 네이티브 TabView → Flutter 탭 전환 채널
const _navChannel = MethodChannel('com.clubal.app/navigation');

class ClubalHomeShell extends StatefulWidget {
  const ClubalHomeShell({super.key});

  @override
  State<ClubalHomeShell> createState() => _ClubalHomeShellState();
}

class _ClubalHomeShellState extends State<ClubalHomeShell> {
  int _selectedIndex = 0;
  int _topTabIndex = 0;
  final List<PieceRoom> _pieceRooms = [];

  final List<NavTab> _tabs = const [
    NavTab(label: '홈', icon: Icons.home_rounded),
    NavTab(label: '매칭', icon: Icons.people_alt_rounded),
    NavTab(label: '채팅', icon: Icons.chat_bubble_rounded),
    NavTab(label: '커뮤니티', icon: Icons.groups_rounded),
    NavTab(label: '메뉴', icon: Icons.menu_rounded),
  ];

  @override
  void initState() {
    super.initState();
    if (Platform.isIOS) {
      _navChannel.setMethodCallHandler((call) async {
        if (call.method == 'setTab') {
          final index = call.arguments as int;
          if (mounted) setState(() => _selectedIndex = index);
        }
      });
    }
  }

  @override
  void dispose() {
    if (Platform.isIOS) _navChannel.setMethodCallHandler(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selected = _tabs[_selectedIndex];
    final isIOS = Platform.isIOS;

    return Scaffold(
      extendBody: !isIOS,
      body: Stack(
        children: [
          // 배경 (전체 화면)
          const ClubalBackground(),

          // 메인 레이아웃: SafeArea > Column (헤더 → [탭바] → 컨텐츠)
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 헤더 바
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: (selected.label == '매칭' ||
                                selected.label == '메뉴')
                            ? const SizedBox.shrink()
                            : Text(
                                '클러버 Clubal',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall,
                              ),
                      ),
                      if (selected.label == '매칭')
                        PressedIconActionButton(
                          icon: Icons.add_rounded,
                          tooltip: '조각 방 만들기',
                          onTap: _openCreatePieceRoom,
                        ),
                      if (selected.label == '메뉴')
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            PressedIconActionButton(
                              icon: Icons.notifications_none_rounded,
                              tooltip: '알림',
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) =>
                                      const PastNotificationsPage(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            PressedIconActionButton(
                              icon: Icons.settings_rounded,
                              tooltip: '설정',
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => const ClubalSettingsPage(),
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),

                // 커뮤니티 탭 전용 최신/인기 탭 바
                if (selected.label == '커뮤니티')
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                    child: ClubalTopTabBar(
                      tabs: const ['최신', '인기'],
                      selectedIndex: _topTabIndex,
                      onChanged: (index) =>
                          setState(() => _topTabIndex = index),
                    ),
                  ),

                // 탭별 컨텐츠 (Expanded로 남은 공간 채움)
                Expanded(child: _buildTabBody(selected.label)),
              ],
            ),
          ),

          // 커뮤니티 글쓰기 플로팅 버튼
          if (selected.label == '커뮤니티')
            Positioned(
              right: 24,
              bottom: 82,
              child: _buildWriteFab(context),
            ),
        ],
      ),
      bottomNavigationBar: isIOS
          ? null
          : ClubalJellyBottomNav(
              tabs: _tabs,
              selectedIndex: _selectedIndex,
              onChanged: (index) => setState(() => _selectedIndex = index),
            ),
    );
  }

  Widget _buildTabBody(String label) {
    switch (label) {
      case '홈':
        return const Center(
          child: Text(
            '홈 화면 준비 중',
            style: TextStyle(color: Color(0xFF8A9BAF), fontSize: 16),
          ),
        );
      case '매칭':
        return MatchingTabView(
          rooms: _pieceRooms,
          onAutoMatchTap: () {},
          topPadding: 8,
        );
      case '채팅':
        return const Center(
          child: Text(
            '채팅 준비 중',
            style: TextStyle(color: Color(0xFF8A9BAF), fontSize: 16),
          ),
        );
      case '커뮤니티':
        return _buildCommunityContent();
      case '메뉴':
        return _buildMenuContent();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildCommunityContent() {
    if (_topTabIndex == 0) {
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

      return LayoutBuilder(
        builder: (context, constraints) {
          final availableHeight = constraints.maxHeight;
          final minCardHeight = availableHeight / 4.8;
          final maxCardHeight = availableHeight / 3.6;

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
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
                minHeight: minCardHeight,
                maxHeight: maxCardHeight,
              );
            },
          );
        },
      );
    }
    return const Center(
      child: Text(
        '인기 컨텐츠',
        style: TextStyle(color: Color(0xFF8A9BAF), fontSize: 18),
      ),
    );
  }

  Widget _buildMenuContent() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      children: [
        _MenuCard(
          icon: Icons.person_rounded,
          title: '내 프로필',
          subtitle: '프로필 확인 및 수정',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const ProfileDetailPage(),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _MenuCard(
          icon: Icons.settings_rounded,
          title: '설정',
          subtitle: '알림·계정·결제 관리',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const ClubalSettingsPage(),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _MenuCard(
          icon: Icons.notifications_none_rounded,
          title: '알림 내역',
          subtitle: '지난 알림 확인',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const PastNotificationsPage(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWriteFab(BuildContext context) {
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
              border:
                  Border.all(color: const Color(0x55FFFFFF), width: 1.2),
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
            child: const Icon(
              Icons.edit_rounded,
              color: Color(0xFFF5FCFF),
              size: 24,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openCreatePieceRoom() async {
    final created = await Navigator.of(context).push<PieceRoom>(
      MaterialPageRoute<PieceRoom>(
        builder: (_) => const CreatePieceRoomPage(),
      ),
    );
    if (created == null) return;
    setState(() => _pieceRooms.insert(0, created));
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0x2B3D5067), width: 1),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xD9FFFFFF), Color(0xCBEAF1FA)],
              ),
            ),
            child: Row(
              children: [
                Icon(icon, size: 26, color: const Color(0xFF304255)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(
                              color: const Color(0xFF304255),
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: const Color(0xFF304255)),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: Color(0xFF304255),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
