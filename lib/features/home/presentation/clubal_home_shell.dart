import 'dart:ui';

import 'package:clubal_app/core/widgets/clubal_background.dart';
import 'package:clubal_app/core/widgets/pressed_icon_action_button.dart';
import 'package:clubal_app/features/home/widgets/post_card.dart';
import 'package:clubal_app/features/navigation/models/nav_tab.dart';
import 'package:clubal_app/features/navigation/widgets/clubal_jelly_bottom_nav.dart';
import 'package:clubal_app/features/navigation/widgets/clubal_top_tab_bar.dart';
import 'package:clubal_app/features/settings/presentation/clubal_settings_page.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;
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
  int _topTabIndex = 0; // 0: 최신, 1: 인기

  final List<NavTab> _tabs = const [
    NavTab(label: '홈', icon: Icons.home_rounded),
    NavTab(label: '매칭', icon: Icons.people_alt_rounded),
    NavTab(label: '채팅', icon: Icons.chat_bubble_rounded),
    NavTab(label: '커뮤니티', icon: Icons.groups_rounded),
    NavTab(label: '메뉴', icon: Icons.menu_rounded),
  ];

  bool get _isIOSNative =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  @override
  void initState() {
    super.initState();
    if (_isIOSNative) {
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
    if (_isIOSNative) _navChannel.setMethodCallHandler(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selected = _tabs[_selectedIndex];
    final isIOS = _isIOSNative;

    return Scaffold(
      extendBody: !isIOS,
      body: Stack(
        children: [
          // 배경 (전체 화면)
          const ClubalBackground(),
          // 상단 고정 탭 바 (커뮤니티 탭에서만 표시)
          if (selected.label == '커뮤니티')
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Spacer(),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClubalTopTabBar(
                      tabs: const ['최신', '인기'],
                      selectedIndex: _topTabIndex,
                      onChanged: (index) => setState(() => _topTabIndex = index),
                    ),
                  ],
                ),
              ),
            ),
          // 메인 컨텐츠 영역
          SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                24,
                selected.label == '커뮤니티' ? 120 : 28,
                24,
                120,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Spacer(),
                  if (selected.label == '메뉴')
                    PressedIconActionButton(
                      icon: Icons.settings_rounded,
                      tooltip: '설정',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const ClubalSettingsPage(),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
          // 탭별 컨텐츠
          if (selected.label == '커뮤니티')
            SafeArea(
              child: Builder(
                builder: (context) {
                  final mediaQuery = MediaQuery.of(context);
                  final screenHeight = mediaQuery.size.height;
                  final topPadding = mediaQuery.padding.top;
                  final bottomPadding = mediaQuery.padding.bottom;
                  
                  final topOffset = 180.0; // 상단 탭 바 포함
                  final availableHeight = screenHeight - topPadding - bottomPadding - topOffset - 120; // 하단 네비 제외
                  
                  // 카드 최소/최대 높이 (세로 길이 줄여 오버플로우 방지)
                  final minCardHeight = availableHeight / 4.8;
                  final maxCardHeight = availableHeight / 3.6;
                  
                  return Padding(
                    padding: EdgeInsets.fromLTRB(24, topOffset, 24, 120),
                    child: _buildTabContent(
                      minCardHeight: minCardHeight,
                      maxCardHeight: maxCardHeight,
                      topTabIndex: _topTabIndex,
                    ),
                  );
                },
              ),
            ),
          // 글쓰기 플로팅 버튼 (커뮤니티 탭에서만 표시)
          if (selected.label == '커뮤니티')
            Positioned(
              right: 24,
              bottom: 82, // 네비게이션 바 위
              child: GestureDetector(
                onTap: () {
                  // 글쓰기 기능 추가 예정
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
                        border: Border.all(color: const Color(0x55FFFFFF), width: 1.2),
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
              ),
            ),
        ],
      ),
      bottomNavigationBar: kIsWeb
          // Web: 단순한 기본 네비게이션으로 안전하게 렌더링
          ? BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: _selectedIndex,
              onTap: (index) => setState(() => _selectedIndex = index),
              items: [
                for (final tab in _tabs)
                  BottomNavigationBarItem(
                    icon: Icon(tab.icon),
                    label: tab.label,
                  ),
              ],
            )
          // iOS: 네이티브 탭바가 담당하므로 Flutter 쪽은 하단바 없음
          : isIOS
              ? null
              // Android 등 나머지 플랫폼: 기존 젤리 네비게이션 유지
              : ClubalJellyBottomNav(
                  tabs: _tabs,
                  selectedIndex: _selectedIndex,
                  onChanged: (index) =>
                      setState(() => _selectedIndex = index),
                ),
    );
  }

  Widget _buildTabContent({
    required double minCardHeight,
    required double maxCardHeight,
    required int topTabIndex,
  }) {
    if (topTabIndex == 0) {
      // 최신 탭 - 글 카드 리스트
      // 임시 데이터 (나중에 실제 데이터로 교체)
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
        itemCount: posts.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
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
    } else {
      // 인기 탭
      return const Center(
        child: Text(
          '인기 컨텐츠',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      );
    }
  }

  String _tabDescription(String label) {
    switch (label) {
      case '홈':
        return const HomeTabView();
      case '매칭':
        return MatchingTabView(
          rooms: _pieceRooms,
          myRooms: _myPieceRooms,
          activeMatches: _activeMatches,
          onAutoMatchTap: _openAutoMatch,
          topPadding: 8,
        );
      case '채팅':
        return '매칭된 인원과 입장 시간, 복장, 비용을 조율합니다.';
      case '커뮤니티':
        return '커뮤니티 활동과 소통을 확인합니다.';
      case '메뉴':
        return const MenuTabView();
      default:
        return const SizedBox.shrink();
    }
  }

  Future<void> _openCreatePieceRoom() async {
    if (_isIOSNative) _navChannel.invokeMethod('setTabBarVisible', false);
    final created = await Navigator.of(context).push<PieceRoom>(
      MaterialPageRoute<PieceRoom>(
        builder: (_) => const CreatePieceRoomPage(),
      ),
    );
    if (_isIOSNative) _navChannel.invokeMethod('setTabBarVisible', true);
    if (created == null) return;
    setState(() => _myPieceRooms.insert(0, created));
  }

  Future<void> _openAutoMatch() async {
    if (_isIOSNative) _navChannel.invokeMethod('setTabBarVisible', false);
    final created = await Navigator.of(context).push<PieceRoom>(
      MaterialPageRoute<PieceRoom>(
        builder: (_) => const AutoMatchPage(),
      ),
    );
    if (_isIOSNative) _navChannel.invokeMethod('setTabBarVisible', true);
    if (created == null) return;
    setState(() => _activeMatches.insert(0, created));
  }
}