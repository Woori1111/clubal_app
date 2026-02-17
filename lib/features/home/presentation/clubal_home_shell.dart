import 'package:clubal_app/core/widgets/clubal_background.dart';
import 'package:clubal_app/core/widgets/glass_card.dart';
import 'package:clubal_app/core/widgets/pressed_icon_action_button.dart';
import 'package:clubal_app/features/matching/presentation/matching_tab_view.dart';
import 'package:clubal_app/features/navigation/models/nav_tab.dart';
import 'package:clubal_app/features/navigation/widgets/clubal_jelly_bottom_nav.dart';
import 'package:clubal_app/features/settings/presentation/clubal_settings_page.dart';
import 'package:flutter/material.dart';

class ClubalHomeShell extends StatefulWidget {
  const ClubalHomeShell({super.key});

  @override
  State<ClubalHomeShell> createState() => _ClubalHomeShellState();
}

class _ClubalHomeShellState extends State<ClubalHomeShell> {
  int _selectedIndex = 0;

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

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          const ClubalBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 120),
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
                      onTap: () {},
                    ),
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
          if (selected.label == '매칭')
            MatchingTabView(onAutoMatchTap: _noop)
          else
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 86, 24, 120),
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
                      GlassCard(
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
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: GlassCard(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
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
                                    Text(
                                      '아직 지난 매칭 기록이 없습니다.\n매칭이 완료되면 여기에 표시돼요.',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
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
                          const SizedBox(width: 12),
                          Expanded(
                            child: GlassCard(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
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
                                    Text(
                                      '예정된 모임이 없습니다.\n모임을 예약하면 이곳에서 확인할 수 있어요.',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
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
      bottomNavigationBar: ClubalJellyBottomNav(
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
}
