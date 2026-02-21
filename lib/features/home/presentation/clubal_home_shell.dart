import 'dart:ui';

import 'package:clubal_app/core/theme/app_glass_styles.dart';
import 'package:clubal_app/core/widgets/clubal_background.dart';
import 'package:clubal_app/core/widgets/long_press_confirm_button.dart';
import 'package:clubal_app/core/widgets/pressed_icon_action_button.dart';
import 'package:clubal_app/features/home/presentation/chat_tab_view.dart';
import 'package:clubal_app/features/home/presentation/community_tab_view.dart';
import 'package:clubal_app/features/home/presentation/home_tab_view.dart';
import 'package:clubal_app/features/home/presentation/menu_tab_view.dart';
import 'package:clubal_app/features/matching/models/piece_room.dart';
import 'package:clubal_app/features/matching/presentation/auto_match_page.dart';
import 'package:clubal_app/features/matching/presentation/create_piece_room_page.dart';
import 'package:clubal_app/features/matching/presentation/matching_tab_view.dart';
import 'package:clubal_app/features/navigation/models/nav_tab.dart';
import 'package:clubal_app/features/navigation/widgets/clubal_jelly_bottom_nav.dart';
import 'package:clubal_app/features/notifications/presentation/past_notifications_page.dart';
import 'package:clubal_app/features/search/presentation/search_page.dart';
import 'package:clubal_app/features/settings/presentation/clubal_settings_page.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// iOS 네이티브 TabView → Flutter 탭 전환 채널
const _navChannel = MethodChannel('com.clubal.app/navigation');
const int _shellTabCount = 5;

class ClubalHomeShell extends StatefulWidget {
  const ClubalHomeShell({super.key, this.navigatorKey});

  final GlobalKey<NavigatorState>? navigatorKey;

  @override
  State<ClubalHomeShell> createState() => _ClubalHomeShellState();
}

class _ClubalHomeShellState extends State<ClubalHomeShell> {
  int _selectedIndex = 0;

  /// 탭별 스크롤 컨트롤러 (같은 탭 다시 탭 시 맨 위로 스크롤용)
  late final List<ScrollController> _scrollControllers =
      List.generate(_shellTabCount, (_) => ScrollController());

  final List<PieceRoom> _pieceRooms = [
    PieceRoom(
      title: '불금 강남 클럽 조각 구해요',
      currentMembers: 2,
      maxMembers: 4,
      creator: '강남불나방',
      location: '강남구 · 추천 · Club Arena',
      meetingAt: DateTime.now().add(const Duration(days: 1, hours: 5)),
      description: '이번주 불금에 강남 클럽 아레나 가실 분들 구합니다! 현재 남자 2명이고 추가로 2명 더 모셔요. 편하게 놀아요~',
    ),
    PieceRoom(
      title: '홍대 감성주점 -> 클럽 코스',
      currentMembers: 3,
      maxMembers: 5,
      creator: '홍대병말기',
      location: '마포구 · 홍대 · Retro Pulse',
      meetingAt: DateTime.now().add(const Duration(days: 2, hours: 2)),
      description: '홍대에서 간단히 1차 하고 클럽으로 넘어갈 분들 찾습니다. 텐션 좋으신 분들 환영해요!',
    ),
    PieceRoom(
      title: '이태원 힙합 클럽 가실분',
      currentMembers: 1,
      maxMembers: 3,
      creator: '힙스터',
      location: '용산구 · 이태원 · Noir Stage',
      meetingAt: DateTime.now().add(const Duration(hours: 10)),
      description: '이태원 힙합 클럽 좋아하시는 분들 같이가요~ N빵 깔끔하게 합니다.',
    ),
  ];
  final List<PieceRoom> _myPieceRooms = [
    PieceRoom(
      title: '이번주 토요일 성수 핫플 ㄱㄱ',
      currentMembers: 1,
      maxMembers: 4,
      creator: '유저별명',
      location: '성동구 · 성수 · Seongsu Hive',
      meetingAt: DateTime.now().add(const Duration(days: 3)),
      description: '성수동 핫플 클럽 같이 가실 분 구합니다! 제가 총대 맵니다.',
    ),
  ];
  final List<PieceRoom> _activeMatches = [];

  final List<NavTab> _tabs = const [
    NavTab(label: '홈', icon: Icons.home_rounded),
    NavTab(label: '매칭', icon: Icons.people_alt_rounded),
    NavTab(label: '채팅', icon: Icons.chat_bubble_rounded),
    NavTab(label: '커뮤니티', icon: Icons.groups_rounded),
    NavTab(label: '메뉴', icon: Icons.menu_rounded),
  ];

  bool get _isIOSNative =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  void _onTabTapped(int index) {
    final nav = widget.navigatorKey?.currentState;
    final didPop = nav != null && nav.canPop();
    if (didPop) {
      nav.popUntil((route) => route.isFirst);
      if (!mounted) return;
    }
    void apply() {
      if (!mounted) return;
      if (index == _selectedIndex) {
        _scrollToTopOfTab(index);
      } else {
        setState(() => _selectedIndex = index);
      }
    }
    if (didPop) {
      WidgetsBinding.instance.addPostFrameCallback((_) => apply());
    } else {
      apply();
    }
  }

  @override
  void initState() {
    super.initState();
    if (_isIOSNative) {
      _navChannel.setMethodCallHandler((call) async {
        if (call.method == 'setTab') {
          final index = call.arguments as int;
          if (!mounted) return;
          _onTabTapped(index);
        }
      });
    }
  }

  void _scrollToTopOfTab(int index) {
    final controller = _scrollControllers[index];
    if (controller.hasClients) {
      controller.animateTo(
        0,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _switchToTab(int index) {
    setState(() => _selectedIndex = index);
    if (_isIOSNative) _navChannel.invokeMethod('setTab', index);
  }

  @override
  void dispose() {
    if (_isIOSNative) _navChannel.setMethodCallHandler(null);
    for (final c in _scrollControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selected = _tabs[_selectedIndex];
    final isIOS = _isIOSNative;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: Builder(
        builder: (context) {
          // iOS: body가 하단 safe area까지 높이를 받아야 배경이 그 구간까지 그려짐. 하단 패딩 제거.
          final removeBottom = _isIOSNative;
          return MediaQuery.removePadding(
            context: context,
            removeBottom: removeBottom,
            child: SizedBox.expand(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: IgnorePointer(child: ClubalBackground()),
                  ),
                  SafeArea(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _ShellHeader(
                          selectedLabel: selected.label,
                          onOpenCreatePieceRoom: _openCreatePieceRoom,
                          onSearch: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const SearchPage(),
                            ),
                          ),
                          onNotifications: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const PastNotificationsPage(),
                            ),
                          ),
                          onSettings: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const ClubalSettingsPage(),
                            ),
                          ),
                        ),
                        Expanded(child: _buildTabBody(selected.label)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      // iOS: 반드시 null. 네이티브 UITabBar만 쓰고, Flutter 쪽 젤리 네비는 겹치면 안 됨.
      bottomNavigationBar: isIOS
          ? null
          : kIsWeb
              ? BottomNavigationBar(
                  type: BottomNavigationBarType.fixed,
                  currentIndex: _selectedIndex,
                  onTap: _onTabTapped,
                  items: [
                    for (final tab in _tabs)
                      BottomNavigationBarItem(
                        icon: Icon(tab.icon),
                        label: tab.label,
                      ),
                  ],
                )
              : Material(
                  color: Colors.transparent,
                  child: ClubalJellyBottomNav(
                    tabs: _tabs,
                    selectedIndex: _selectedIndex,
                    onChanged: _onTabTapped,
                  ),
                ),
    );
  }

  Widget _buildTabBody(String label) {
    final index = _tabs.indexWhere((t) => t.label == label);
    final scrollController = index >= 0 && index < _shellTabCount
        ? _scrollControllers[index]
        : null;
    switch (label) {
      case '홈':
        return HomeTabView(
          scrollController: scrollController,
          onMatchTap: () => _switchToTab(1),
          onChatTap: () => _switchToTab(2),
        );
      case '매칭':
        return MatchingTabView(
          rooms: _pieceRooms,
          myRooms: _myPieceRooms,
          activeMatches: _activeMatches,
          onAutoMatchTap: _openAutoMatch,
          topPadding: 8,
          scrollController: scrollController,
        );
      case '채팅':
        return ChatTabView(scrollController: scrollController);
      case '커뮤니티':
        return CommunityTabView(scrollController: scrollController);
      case '메뉴':
        return MenuTabView(scrollController: scrollController);
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

/// 헤더 바 (높이 56 통일). 탭에 따라 제목 / 매칭 버튼 / 메뉴 버튼 표시.
class _ShellHeader extends StatelessWidget {
  const _ShellHeader({
    required this.selectedLabel,
    required this.onOpenCreatePieceRoom,
    required this.onSearch,
    required this.onNotifications,
    required this.onSettings,
  });

  final String selectedLabel;
  final VoidCallback onOpenCreatePieceRoom;
  final VoidCallback onSearch;
  final VoidCallback onNotifications;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: SizedBox(
        height: 56,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: (selectedLabel == '매칭' || selectedLabel == '메뉴')
                  ? const SizedBox.shrink()
                  : Text(
                      '클러버 Clubal',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                    ),
            ),
            if (selectedLabel == '매칭')
              SizedBox(
                width: 52,
                height: 52,
                child: OverflowBox(
                  maxWidth: 52 * 1.15,
                  maxHeight: 52 * 1.15,
                  alignment: Alignment.center,
                  child: LongPressConfirmButton(
                    onTap: onOpenCreatePieceRoom,
                    baseWidth: 52,
                    baseHeight: 52,
                    background: ClipOval(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                        child: Container(
                          width: 52,
                          height: 52,
                          decoration: AppGlassStyles.card(
                            radius: 26,
                            isDark: Theme.of(context).brightness == Brightness.dark,
                          ),
                        ),
                      ),
                    ),
                    content: Icon(
                      Icons.add_rounded,
                      color: Theme.of(context).colorScheme.onSurface,
                      size: 28,
                    ),
                  ),
                ),
              ),
            if (selectedLabel == '메뉴')
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PressedIconActionButton(
                    icon: Icons.search_rounded,
                    tooltip: '검색',
                    onTap: onSearch,
                  ),
                  const SizedBox(width: 8),
                  PressedIconActionButton(
                    icon: Icons.notifications_none_rounded,
                    tooltip: '알림',
                    onTap: onNotifications,
                  ),
                  const SizedBox(width: 8),
                  PressedIconActionButton(
                    icon: Icons.settings_rounded,
                    tooltip: '설정',
                    onTap: onSettings,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
