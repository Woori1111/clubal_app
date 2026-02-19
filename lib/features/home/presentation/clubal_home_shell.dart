import 'package:clubal_app/core/widgets/clubal_background.dart';
import 'package:clubal_app/core/widgets/pressed_icon_action_button.dart';
import 'package:clubal_app/features/home/presentation/chat_tab_view.dart';
import 'package:clubal_app/features/home/presentation/community_tab_view.dart';
import 'package:clubal_app/features/home/presentation/home_tab_view.dart';
import 'package:clubal_app/features/home/presentation/menu_tab_view.dart';
import 'package:clubal_app/features/matching/models/piece_room.dart';
import 'package:clubal_app/features/matching/presentation/create_piece_room_page.dart';
import 'package:clubal_app/features/matching/presentation/matching_tab_view.dart';
import 'package:clubal_app/features/navigation/models/nav_tab.dart';
import 'package:clubal_app/features/navigation/widgets/clubal_jelly_bottom_nav.dart';
import 'package:clubal_app/features/notifications/presentation/past_notifications_page.dart';
import 'package:clubal_app/features/search/presentation/search_page.dart';
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
  final List<PieceRoom> _pieceRooms = [];

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
                              icon: Icons.search_rounded,
                              tooltip: '검색',
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => const SearchPage(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
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
                          ],
                        ),
                    ],
                  ),
                ),

                // 탭별 컨텐츠 (Expanded로 남은 공간 채움)
                Expanded(child: _buildTabBody(selected.label)),
              ],
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

  Widget _buildTabBody(String label) {
    switch (label) {
      case '홈':
        return const HomeTabView();
      case '매칭':
        return MatchingTabView(
          rooms: _pieceRooms,
          onAutoMatchTap: () {},
          topPadding: 8,
        );
      case '채팅':
        return const ChatTabView();
      case '커뮤니티':
        return const CommunityTabView();
      case '메뉴':
        return const MenuTabView();
      default:
        return const SizedBox.shrink();
    }
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