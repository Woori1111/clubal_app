import 'dart:io';

import 'package:clubal_app/core/widgets/clubal_background.dart';
import 'package:clubal_app/core/widgets/glass_card.dart';
import 'package:clubal_app/core/widgets/pressed_icon_action_button.dart';
import 'package:clubal_app/features/matching/models/piece_room.dart';
import 'package:clubal_app/features/matching/presentation/create_piece_room_page.dart';
import 'package:clubal_app/features/matching/presentation/matching_tab_view.dart';
import 'package:clubal_app/features/notifications/presentation/past_notifications_page.dart';
import 'package:clubal_app/features/navigation/models/nav_tab.dart';
import 'package:clubal_app/features/navigation/widgets/clubal_jelly_bottom_nav.dart';
import 'package:clubal_app/features/profile/presentation/profile_detail_page.dart';
import 'package:clubal_app/features/settings/presentation/clubal_settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ClubalHomeShell extends StatefulWidget {
  const ClubalHomeShell({super.key});

  @override
  State<ClubalHomeShell> createState() => _ClubalHomeShellState();
}

class _ClubalHomeShellState extends State<ClubalHomeShell> {
  static const _navChannel = MethodChannel('com.clubal.app/navigation');

  int _selectedIndex = 0;
  final List<PieceRoom> _pieceRooms = [
    PieceRoom(
      title: '네온밤의 조각 방',
      currentMembers: 3,
      maxMembers: 6,
      creator: '민준',
      location: '강남역',
      meetingAt: DateTime(2026, 2, 20, 21),
    ),
    PieceRoom(
      title: '파도소리의 조각 방',
      currentMembers: 2,
      maxMembers: 6,
      creator: '지우',
      location: '이태원',
      meetingAt: DateTime(2026, 2, 21, 22),
    ),
    PieceRoom(
      title: '보라빛의 조각 방',
      currentMembers: 5,
      maxMembers: 6,
      creator: '수아',
      location: '홍대입구',
      meetingAt: DateTime(2026, 2, 22, 21),
    ),
    PieceRoom(
      title: '달빛런의 조각 방',
      currentMembers: 1,
      maxMembers: 6,
      creator: '현우',
      location: '건대입구',
      meetingAt: DateTime(2026, 2, 23, 20),
    ),
    PieceRoom(
      title: '새벽무드의 조각 방',
      currentMembers: 4,
      maxMembers: 6,
      creator: '서연',
      location: '합정',
      meetingAt: DateTime(2026, 2, 24, 23),
    ),
    PieceRoom(
      title: '하이텐션의 조각 방',
      currentMembers: 3,
      maxMembers: 6,
      creator: '도윤',
      location: '잠실',
      meetingAt: DateTime(2026, 2, 25, 21),
    ),
    PieceRoom(
      title: '레트로밤의 조각 방',
      currentMembers: 6,
      maxMembers: 6,
      creator: '예린',
      location: '신촌',
      meetingAt: DateTime(2026, 2, 26, 22),
    ),
    PieceRoom(
      title: '바이브온의 조각 방',
      currentMembers: 2,
      maxMembers: 6,
      creator: '태윤',
      location: '성수',
      meetingAt: DateTime(2026, 2, 27, 21),
    ),
    PieceRoom(
      title: '시티라이트의 조각 방',
      currentMembers: 4,
      maxMembers: 6,
      creator: '하은',
      location: '청담',
      meetingAt: DateTime(2026, 2, 28, 23),
    ),
    PieceRoom(
      title: '핑크플로우의 조각 방',
      currentMembers: 3,
      maxMembers: 6,
      creator: '유진',
      location: '종로3가',
      meetingAt: DateTime(2026, 3, 1, 20),
    ),
  ];

  @override
  void initState() {
    super.initState();
    if (Platform.isIOS) {
      _navChannel.setMethodCallHandler(_handleNativeNavCall);
    }
  }

  @override
  void dispose() {
    if (Platform.isIOS) {
      _navChannel.setMethodCallHandler(null);
    }
    super.dispose();
  }

  Future<void> _handleNativeNavCall(MethodCall call) async {
    if (call.method == 'setTab') {
      final index = call.arguments as int;
      if (mounted) setState(() => _selectedIndex = index);
    }
  }

  final List<NavTab> _tabs = const [
    NavTab(label: '홈', icon: Icons.home_rounded),
    NavTab(label: '매칭', icon: Icons.people_alt_rounded),
    NavTab(label: '채팅', icon: Icons.chat_bubble_rounded),
    NavTab(label: '파티', icon: Icons.celebration_rounded),
    NavTab(label: '메뉴', icon: Icons.menu_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final selected = _tabs[_selectedIndex];

    final isIOS = Platform.isIOS;

    return Scaffold(
      extendBody: !isIOS,
      body: Stack(
        children: [
          const ClubalBackground(),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(24, 28, 24, isIOS ? 16 : 120),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: (selected.label == '매칭' || selected.label == '메뉴')
                        ? const SizedBox.shrink()
                        : Text(
                            '클러버 Clubal',
                            style: Theme.of(context).textTheme.headlineSmall,
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
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => const PastNotificationsPage(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 8),
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
                ],
              ),
            ),
          ),
          if (selected.label == '매칭')
            MatchingTabView(onAutoMatchTap: _noop, rooms: _pieceRooms)
          else
            SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(24, 86, 24, isIOS ? 12 : 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    if (selected.label == '메뉴') ...[
                      Text(
                        '프로필',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const ProfileDetailPage(),
                            ),
                          );
                        },
                        child: GlassCard(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 24,
                              horizontal: 20,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 32,
                                  backgroundColor:
                                      Colors.white.withOpacity(0.25),
                                  child: const Icon(
                                    Icons.person_rounded,
                                    color: Color(0xFF243244),
                                    size: 32,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  '주지훈',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '나는 주지훈 입니다. 1000만 영화배우입니다!!',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: const Color(0xD9EAF6FF),
                                        height: 1.4,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 122,
                              child: GlassCard(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    14,
                                    14,
                                    14,
                                    12,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '지난 매칭 기록',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall
                                            ?.copyWith(
                                                fontWeight: FontWeight.w700),
                                      ),
                                      const SizedBox(height: 8),
                                      Expanded(
                                        child: Align(
                                          alignment: Alignment.topLeft,
                                          child: Text(
                                            '아직 지난 매칭 기록이 없습니다.\n매칭이 완료되면 여기에 표시돼요.',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  color:
                                                      const Color(0xD9EAF6FF),
                                                  height: 1.35,
                                                ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SizedBox(
                              height: 122,
                              child: GlassCard(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    14,
                                    14,
                                    14,
                                    12,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '예정된 모임',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall
                                            ?.copyWith(
                                                fontWeight: FontWeight.w700),
                                      ),
                                      const SizedBox(height: 8),
                                      Expanded(
                                        child: Align(
                                          alignment: Alignment.topLeft,
                                          child: Text(
                                            '예정된 모임이 없습니다.\n모임을 예약하면 이곳에서 확인할 수 있어요.',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  color:
                                                      const Color(0xD9EAF6FF),
                                                  height: 1.35,
                                                ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                    ] else ...[
                      Text(
                        '동성 친구들과 클럽 테이블비를 1/N으로,\n가볍게 매칭하고 안전하게 함께 가요.',
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(height: 1.4),
                      ),
                      const Spacer(),
                      GlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              selected.label,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _tabDescription(selected.label),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                      color: const Color(0xD9EAF6FF)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
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

  String _tabDescription(String label) {
    switch (label) {
      case '홈':
        return '오늘의 클럽 조각 현황과 추천 모임을 확인합니다.';
      case '매칭':
        return '함께 갈 인원을 찾고 1/N 조건을 맞춰 매칭합니다.';
      case '채팅':
        return '매칭된 인원과 입장 시간, 복장, 비용을 조율합니다.';
      case '파티':
        return '진행 중인 파티와 인기 클럽 일정을 탐색합니다.';
      case '메뉴':
        return '내 프로필, 인증, 결제, 알림 설정을 관리합니다.';
      default:
        return '';
    }
  }

  static void _noop() {}

  Future<void> _openCreatePieceRoom() async {
    final created = await Navigator.of(context).push<PieceRoom>(
      MaterialPageRoute<PieceRoom>(
        builder: (_) => const CreatePieceRoomPage(),
      ),
    );
    if (created == null) {
      return;
    }
    setState(() => _pieceRooms.insert(0, created));
  }
}
