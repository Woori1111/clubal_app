import 'dart:ui';

import 'package:clubal_app/core/theme/app_glass_styles.dart';
import 'package:clubal_app/features/matching/models/piece_room.dart';
import 'package:clubal_app/features/matching/presentation/piece_room_detail_page.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

const _navChannel = MethodChannel('com.clubal.app/navigation');

bool get _isIOSNative => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

class MatchingTabView extends StatefulWidget {
  const MatchingTabView({
    super.key,
    required this.onAutoMatchTap,
    required this.rooms,
    required this.myRooms,
    required this.activeMatches,
    this.topPadding = 86.0,
  });

  final VoidCallback onAutoMatchTap;
  final List<PieceRoom> rooms;
  final List<PieceRoom> myRooms;
  final List<PieceRoom> activeMatches;
  final double topPadding;

  @override
  State<MatchingTabView> createState() => _MatchingTabViewState();
}

class _MatchingTabViewState extends State<MatchingTabView> {
  bool _fabCompact = false;
  static const List<String> _completedMatches = [];

  bool _handleScroll(UserScrollNotification notification) {
    if (notification.direction == ScrollDirection.reverse && !_fabCompact) {
      setState(() => _fabCompact = true);
    } else if (notification.direction == ScrollDirection.forward &&
        _fabCompact) {
      setState(() => _fabCompact = false);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(14, widget.topPadding, 14, 12),
        child: Stack(
          children: [
            NotificationListener<UserScrollNotification>(
              onNotification: _handleScroll,
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 170),
                itemCount: 1, // 데이터 유무와 상관없이 섹션 타이틀은 항상 렌더링하도록 1로 고정
                itemBuilder: (context, _) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _SectionLabel(title: '매칭중'),
                      const SizedBox(height: 8),
                      if (widget.activeMatches.isNotEmpty)
                        ...widget.activeMatches.map(
                          (room) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _PieceRoomListItem(
                              room: room,
                              onTap: () async {
                                if (_isIOSNative) _navChannel.invokeMethod('setTabBarVisible', false);
                                await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => PieceRoomDetailPage(
                                      room: room,
                                      isMyRoom: true,
                                    ),
                                  ),
                                );
                                if (_isIOSNative) _navChannel.invokeMethod('setTabBarVisible', true);
                              },
                            ),
                          ),
                        )
                      else
                        const SizedBox(height: 14),

                      const _SectionLabel(title: '매칭완료'),
                      const SizedBox(height: 8),
                      if (_completedMatches.isNotEmpty)
                        // 매칭완료 카드 목록
                        const SizedBox()
                      else
                        const SizedBox(height: 14),

                      const _SectionLabel(title: '내가 만든 조각'),
                      const SizedBox(height: 8),
                      if (widget.myRooms.isNotEmpty)
                        ...widget.myRooms.map(
                          (room) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _PieceRoomListItem(
                              room: room,
                              onTap: () async {
                                if (_isIOSNative) _navChannel.invokeMethod('setTabBarVisible', false);
                                await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => PieceRoomDetailPage(
                                      room: room,
                                      isMyRoom: true,
                                    ),
                                  ),
                                );
                                if (_isIOSNative) _navChannel.invokeMethod('setTabBarVisible', true);
                              },
                            ),
                          ),
                        )
                      else
                        const SizedBox(height: 14),

                      const _SectionLabel(title: '조각 목록'),
                      const SizedBox(height: 12),
                      if (widget.rooms.isNotEmpty)
                        ...widget.rooms.map(
                          (room) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _PieceRoomListItem(
                              room: room,
                              onTap: () async {
                                if (_isIOSNative) _navChannel.invokeMethod('setTabBarVisible', false);
                                await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => PieceRoomDetailPage(
                                      room: room,
                                      isMyRoom: false,
                                    ),
                                  ),
                                );
                                if (_isIOSNative) _navChannel.invokeMethod('setTabBarVisible', true);
                              },
                            ),
                          ),
                        )
                      else
                        const SizedBox(height: 16),
                    ],
                  );
                },
              ),
            ),
            Positioned(
              right: 2,
              bottom: 8,
              child: _AutoMatchFab(
                onTap: widget.onAutoMatchTap,
                compact: _fabCompact,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AutoMatchFab extends StatefulWidget {
  const _AutoMatchFab({required this.onTap, required this.compact});

  final VoidCallback onTap;
  final bool compact;

  @override
  State<_AutoMatchFab> createState() => _AutoMatchFabState();
}

class _AutoMatchFabState extends State<_AutoMatchFab> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) {
      return;
    }
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final scale = _pressed ? 0.94 : 1.0;
    final opacity = _pressed ? 0.78 : 1.0;
    final width = widget.compact ? 60.0 : 136.0;

    return AnimatedScale(
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOutCubic,
      scale: scale,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        opacity: opacity,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          width: width,
          height: 52,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTapDown: (_) => _setPressed(true),
                  onTapUp: (_) => _setPressed(false),
                  onTap: widget.onTap,
                  onTapCancel: () => _setPressed(false),
                  child: Ink(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: const Color(0x66FFFFFF),
                        width: 1.5,
                      ),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xB3FFFFFF), Color(0x66EAF2FA)],
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x22000000),
                          blurRadius: 16,
                          spreadRadius: -4,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        transitionBuilder: (child, animation) => FadeTransition(
                          opacity: animation,
                          child: ScaleTransition(scale: animation, child: child),
                        ),
                        child: widget.compact
                            ? const Icon(
                                Icons.bolt_rounded,
                                key: ValueKey('compact_bolt'),
                                color: Color(0xFF253445),
                                size: 33,
                                weight: 700,
                              )
                            : const Text(
                                '자동매치',
                                key: ValueKey('expanded_label'),
                                style: TextStyle(
                                  color: Color(0xFF253445),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 17,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: const Color(0x993F4F61),
          fontWeight: FontWeight.w400,
          fontSize: 16,
        ),
      ),
    );
  }
}


class _BlobCard extends StatelessWidget {
  const _BlobCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: AppGlassStyles.card(radius: 16),
          child: child,
        ),
      ),
    );
  }
}


class _PieceRoomListItem extends StatelessWidget {
  const _PieceRoomListItem({
    required this.room,
    this.onTap,
  });

  final PieceRoom room;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: _BlobCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              room.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: const Color(0xFF304255),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _InfoChip(icon: Icons.group_rounded, text: room.capacityLabel),
                const SizedBox(width: 8),
                _InfoChip(icon: Icons.person_rounded, text: room.creator),
                const SizedBox(width: 8),
                Expanded(
                  child: _InfoChip(
                    icon: Icons.place_rounded,
                    text: room.location,
                    expanded: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.text,
    this.expanded = false,
  });

  final IconData icon;
  final String text;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: const Color(0x66FFFFFF),
        border: Border.all(color: const Color(0x33586B80), width: 1),
      ),
      child: Row(
        mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: const Color(0xFF4B5D73)),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFF4B5D73),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (expanded) {
      return SizedBox(width: double.infinity, child: chip);
    }
    return chip;
  }
}
