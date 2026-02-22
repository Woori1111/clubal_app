import 'dart:async';
import 'dart:ui';

import 'package:clubal_app/core/theme/app_glass_styles.dart';
import 'package:clubal_app/core/widgets/clubal_background.dart';
import 'package:clubal_app/core/widgets/long_press_confirm_button.dart';
import 'package:clubal_app/core/widgets/pressed_icon_action_button.dart';
import 'package:clubal_app/features/chat/widgets/chat_tab_search_sheet.dart';
import 'package:clubal_app/features/home/presentation/chat_tab_view.dart';
import 'package:clubal_app/features/home/presentation/community_tab_view.dart';
import 'package:clubal_app/features/home/presentation/home_tab_view.dart';
import 'package:clubal_app/features/home/presentation/menu_tab_view.dart';
import 'package:clubal_app/core/firestore/piece_room_service.dart';
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

/// 웹: 홈·매칭·채팅·메뉴 (커뮤니티 제외)
const _webTabs = [
  NavTab(label: '홈', icon: Icons.home_rounded),
  NavTab(label: '매칭', icon: Icons.people_alt_rounded),
  NavTab(label: '채팅', icon: Icons.chat_bubble_rounded),
  NavTab(label: '메뉴', icon: Icons.menu_rounded),
];
const _fullTabs = [
  NavTab(label: '홈', icon: Icons.home_rounded),
  NavTab(label: '매칭', icon: Icons.people_alt_rounded),
  NavTab(label: '채팅', icon: Icons.chat_bubble_rounded),
  NavTab(label: '커뮤니티', icon: Icons.groups_rounded),
  NavTab(label: '메뉴', icon: Icons.menu_rounded),
];

class ClubalHomeShell extends StatefulWidget {
  const ClubalHomeShell({super.key, this.navigatorKey});

  final GlobalKey<NavigatorState>? navigatorKey;

  @override
  State<ClubalHomeShell> createState() => _ClubalHomeShellState();
}

class _ClubalHomeShellState extends State<ClubalHomeShell> {
  int _selectedIndex = 0;

  int get _tabCount => kIsWeb ? 4 : 5;
  List<NavTab> get _tabs => kIsWeb ? _webTabs : _fullTabs;

  /// 탭별 스크롤 컨트롤러 (같은 탭 다시 탭 시 맨 위로 스크롤용)
  late List<ScrollController> _scrollControllers;

  final PieceRoomService _pieceRoomService = PieceRoomService();
  List<PieceRoom> _pieceRooms = [];
  List<PieceRoom> _myPieceRooms = [];
  List<PieceRoom> _roomsWhereIAmMember = [];
  StreamSubscription<List<PieceRoom>>? _roomsSub;
  StreamSubscription<List<PieceRoom>>? _myRoomsSub;
  StreamSubscription<List<PieceRoom>>? _memberRoomsSub;

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
    _scrollControllers = List.generate(_tabCount, (_) => ScrollController());
    try {
      final timeout = kIsWeb ? const Duration(seconds: 10) : null;
      Stream<List<PieceRoom>> streamAll = _pieceRoomService.streamAllRooms();
      if (timeout != null) {
        streamAll = streamAll.timeout(timeout, onTimeout: (sink) => sink.add([]));
      }
      _roomsSub = streamAll.listen((rooms) {
        if (mounted) setState(() => _pieceRooms = rooms);
      }, onError: (_) {
        if (mounted) setState(() => _pieceRooms = []);
      });
      Stream<List<PieceRoom>> streamMy = _pieceRoomService.streamMyRooms();
      if (timeout != null) {
        streamMy = streamMy.timeout(timeout, onTimeout: (sink) => sink.add([]));
      }
      _myRoomsSub = streamMy.listen((rooms) {
        if (mounted) setState(() => _myPieceRooms = rooms);
      }, onError: (_) {
        if (mounted) setState(() => _myPieceRooms = []);
      });
      Stream<List<PieceRoom>> streamMember = _pieceRoomService.streamRoomsWhereIAmMember();
      if (timeout != null) {
        streamMember = streamMember.timeout(timeout, onTimeout: (sink) => sink.add([]));
      }
      _memberRoomsSub = streamMember.listen((rooms) {
        if (mounted) setState(() => _roomsWhereIAmMember = rooms);
      }, onError: (_) {
        if (mounted) setState(() => _roomsWhereIAmMember = []);
      });
    } catch (_) {
      // Firebase 미초기화 등 시 빈 목록 유지
    }
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

  Future<void> _openPastNotifications() async {
    final result = await Navigator.of(context).push<int>(
      MaterialPageRoute<int>(
        builder: (_) => const PastNotificationsPage(),
      ),
    );
    if (result != null && mounted && result >= 0 && result < _tabCount) {
      _switchToTab(result);
    }
  }

  @override
  void dispose() {
    _roomsSub?.cancel();
    _myRoomsSub?.cancel();
    _memberRoomsSub?.cancel();
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
                          onNotifications: _openPastNotifications,
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
                  if (kIsWeb) _WebFloatingNav(
                    tabs: _tabs,
                    selectedIndex: _selectedIndex,
                    onTap: _onTabTapped,
                  ),
                ],
              ),
            ),
          );
        },
      ),
      // iOS: null. 웹: 플로팅 캡슐은 body Stack에 그려짐.
      bottomNavigationBar: isIOS || kIsWeb
          ? null
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
    final scrollController = index >= 0 && index < _tabCount
        ? _scrollControllers[index]
        : null;
    switch (label) {
      case '홈':
        return HomeTabView(
          scrollController: scrollController,
          onMatchTap: () => _switchToTab(1),
          onChatTap: () => _switchToTab(2),
          onExtra1Tap: _openPastNotifications,
          onExtra2Tap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const ClubalSettingsPage(),
            ),
          ),
        );
      case '매칭':
        final byId = <String, PieceRoom>{};
        for (final r in _myPieceRooms) {
          if (r.id != null) byId[r.id!] = r;
        }
        for (final r in _roomsWhereIAmMember) {
          if (r.id != null) byId[r.id!] = r;
        }
        final allParticipating = byId.values.toList();
        allParticipating.sort((a, b) => b.meetingAt.compareTo(a.meetingAt));
        final activeMatches = allParticipating.where((r) => !r.isFullOrClosed).toList();
        final completedMatches = allParticipating.where((r) => r.isFullOrClosed).toList();
        return MatchingTabView(
          rooms: _pieceRooms,
          myRooms: _myPieceRooms,
          activeMatches: activeMatches,
          completedMatches: completedMatches,
          pieceRoomService: _pieceRoomService,
          onAutoMatchTap: _openAutoMatch,
          topPadding: 8,
          scrollController: scrollController,
        );
      case '채팅':
        return ChatTabView(scrollController: scrollController);
      case '커뮤니티':
        return CommunityTabView(scrollController: scrollController);
      case '메뉴':
        return MenuTabView(
          scrollController: scrollController,
          onSwitchToMatching: () => _switchToTab(1),
        );
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
    if (!mounted) return;
    if (_isIOSNative) _navChannel.invokeMethod('setTabBarVisible', true);
    if (created == null) return;
    await _pieceRoomService.createRoom(created);
  }

  Future<void> _openAutoMatch() async {
    if (_isIOSNative) _navChannel.invokeMethod('setTabBarVisible', false);
    final created = await Navigator.of(context).push<PieceRoom>(
      MaterialPageRoute<PieceRoom>(
        builder: (_) => AutoMatchPage(pieceRoomService: _pieceRoomService),
      ),
    );
    if (!mounted) return;
    if (_isIOSNative) _navChannel.invokeMethod('setTabBarVisible', true);
    if (created == null) return;
    // 자동매치 완료 시 방은 이미 Firestore 트랜잭션으로 생성됨
    if (!created.isAutoMatch) {
      await _pieceRoomService.createRoom(created);
    }
  }
}

/// 웹 전용: 하단 플로팅 캡슐 네비 (젤리 버튼 형식, 탭 시 바운스 애니메이션).
class _WebFloatingNav extends StatefulWidget {
  const _WebFloatingNav({
    required this.tabs,
    required this.selectedIndex,
    required this.onTap,
  });

  final List<NavTab> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  State<_WebFloatingNav> createState() => _WebFloatingNavState();
}

class _WebFloatingNavState extends State<_WebFloatingNav>
    with TickerProviderStateMixin {
  late List<AnimationController> _bounceControllers;
  late List<Animation<double>> _scaleAnimations;

  @override
  void initState() {
    super.initState();
    _bounceControllers = List.generate(
      widget.tabs.length,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 520),
      ),
    );
    _scaleAnimations = _bounceControllers.map((c) {
      return TweenSequence<double>([
        TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.14), weight: 22),
        TweenSequenceItem(tween: Tween(begin: 1.14, end: 0.93), weight: 26),
        TweenSequenceItem(tween: Tween(begin: 0.93, end: 1.05), weight: 30),
        TweenSequenceItem(tween: Tween(begin: 1.05, end: 0.985), weight: 12),
        TweenSequenceItem(tween: Tween(begin: 0.985, end: 1.00), weight: 10),
      ]).animate(CurvedAnimation(parent: c, curve: Curves.linear));
    }).toList();
    _bounceControllers[widget.selectedIndex].forward();
  }

  @override
  void didUpdateWidget(covariant _WebFloatingNav oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _bounceControllers[widget.selectedIndex].forward(from: 0);
    }
  }

  @override
  void dispose() {
    for (final c in _bounceControllers) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(48, 0, 48, 20),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 32, sigmaY: 32),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [const Color(0x22FFFFFF), const Color(0x12FFFFFF)]
                        : [const Color(0x36FFFFFF), const Color(0x1CFFFFFF)],
                  ),
                  border: Border.all(
                    color: isDark ? const Color(0x33FFFFFF) : const Color(0x55FFFFFF),
                    width: 0.9,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x18000000),
                      blurRadius: 30,
                      spreadRadius: -8,
                      offset: Offset(0, 14),
                    ),
                    BoxShadow(
                      color: Color(0x0A000000),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    for (int i = 0; i < widget.tabs.length; i++)
                      Expanded(
                        child: AnimatedBuilder(
                          animation: _scaleAnimations[i],
                          builder: (context, child) {
                            return GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => widget.onTap(i),
                              child: _WebJellyNavItem(
                                tab: widget.tabs[i],
                                isSelected: widget.selectedIndex == i,
                                bounceScale: _scaleAnimations[i].value,
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WebJellyNavItem extends StatelessWidget {
  const _WebJellyNavItem({
    required this.tab,
    required this.isSelected,
    required this.bounceScale,
  });

  final NavTab tab;
  final bool isSelected;
  final double bounceScale;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDark
        ? (isSelected ? const Color(0xFFE6EDF3) : const Color(0xFF8B949E))
        : (isSelected ? const Color(0xFF1C1C1E) : const Color(0xFFA0A0A5));
    final labelColor = iconColor;

    return Center(
      child: Transform.scale(
        scale: bounceScale,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Icon(tab.icon, color: iconColor, size: 22),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOutCubic,
              style: TextStyle(
                fontFamily: 'Pretendard',
                color: labelColor,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                letterSpacing: isSelected ? 0.1 : 0.0,
              ),
              child: Text(tab.label),
            ),
          ],
        ),
      ),
    );
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
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: SizedBox(
        height: 56,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: (selectedLabel == '매칭' || selectedLabel == '메뉴')
                  ? const SizedBox.shrink()
                  : Text(
                      selectedLabel == '채팅'
                          ? '채팅'
                          : selectedLabel == '커뮤니티'
                              ? '커뮤니티'
                              : '클러버 Clubal',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                    ),
            ),
            if (selectedLabel == '채팅')
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: IconButton(
                  icon: const Icon(Icons.search_rounded, size: 24),
                  onPressed: () => showChatTabSearchSheet(context),
                  tooltip: '채팅방·메시지 검색',
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
