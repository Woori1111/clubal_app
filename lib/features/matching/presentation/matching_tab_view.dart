import 'package:clubal_app/features/matching/models/piece_room.dart';
import 'package:clubal_app/features/matching/presentation/piece_room_detail_page.dart';
import 'package:clubal_app/core/widgets/long_press_confirm_button.dart';
import 'package:clubal_app/features/matching/presentation/widgets/auto_match_fab.dart';
import 'package:clubal_app/features/matching/presentation/widgets/matching_room_list_item.dart';
import 'package:clubal_app/features/matching/presentation/widgets/matching_section_label.dart';
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
    this.scrollController,
  });

  final VoidCallback onAutoMatchTap;
  final List<PieceRoom> rooms;
  final List<PieceRoom> myRooms;
  final List<PieceRoom> activeMatches;
  final double topPadding;
  final ScrollController? scrollController;

  @override
  State<MatchingTabView> createState() => _MatchingTabViewState();
}

class _MatchingTabViewState extends State<MatchingTabView> {
  bool _fabCompact = false;
  static const List<PieceRoom> _completedMatches = [];
  final ValueNotifier<double> _fabScaleNotifier = ValueNotifier<double>(1.0);

  bool _handleScroll(UserScrollNotification notification) {
    if (notification.direction == ScrollDirection.reverse && !_fabCompact) {
      setState(() => _fabCompact = true);
    } else if (notification.direction == ScrollDirection.forward && _fabCompact) {
      setState(() => _fabCompact = false);
    }
    return false;
  }

  @override
  void dispose() {
    _fabScaleNotifier.dispose();
    super.dispose();
  }

  Future<void> _openRoomDetail(PieceRoom room, bool isMyRoom) async {
    if (_isIOSNative) _navChannel.invokeMethod('setTabBarVisible', false);
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PieceRoomDetailPage(room: room, isMyRoom: isMyRoom),
      ),
    );
    if (_isIOSNative && context.mounted) _navChannel.invokeMethod('setTabBarVisible', true);
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
              child: ListView(
                controller: widget.scrollController,
                padding: const EdgeInsets.only(bottom: 170),
                children: [
                  const MatchingSectionLabel(title: '매칭중'),
                  const SizedBox(height: 8),
                  ..._roomListItems(widget.activeMatches, isMyRoom: true),
                  const SizedBox(height: _sectionSpacing),

                  const MatchingSectionLabel(title: '매칭완료'),
                  const SizedBox(height: 8),
                  ..._roomListItems(_completedMatches, isMyRoom: true),
                  const SizedBox(height: _sectionSpacing),

                  const MatchingSectionLabel(title: '내가 만든 조각'),
                  const SizedBox(height: 8),
                  ..._roomGridRows(widget.myRooms, isMyRoom: true),
                  const SizedBox(height: _sectionSpacing),

                  const MatchingSectionLabel(title: '조각 목록'),
                  const SizedBox(height: 12),
                  ..._roomGridRows(widget.rooms, isMyRoom: false),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            Positioned(
              right: 2,
              bottom: 8,
              child: LongPressConfirmButton(
                onTap: widget.onAutoMatchTap,
                scaleNotifier: _fabScaleNotifier,
                child: AutoMatchFab(
                  compact: _fabCompact,
                  scaleNotifier: _fabScaleNotifier,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const double _sectionSpacing = 14;

  List<Widget> _roomListItems(List<PieceRoom> list, {required bool isMyRoom}) {
    if (list.isEmpty) return [const SizedBox(height: 14)];
    return list
        .map(
          (room) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: MatchingRoomListItem(
              room: room,
              onTap: () => _openRoomDetail(room, isMyRoom),
            ),
          ),
        )
        .toList();
  }

  /// 내가 만든 조각 / 조각 목록: 한 줄에 카드 2개
  List<Widget> _roomGridRows(List<PieceRoom> list, {required bool isMyRoom}) {
    if (list.isEmpty) return [const SizedBox(height: 14)];
    return [
      LayoutBuilder(
        builder: (context, constraints) {
          const spacing = 10.0;
          final cardWidth = (constraints.maxWidth - spacing) / 2;
          return Wrap(
            spacing: spacing,
            runSpacing: 12,
            children: list.map((room) {
              return SizedBox(
                width: cardWidth,
                child: MatchingRoomListItem(
                  room: room,
                  onTap: () => _openRoomDetail(room, isMyRoom),
                ),
              );
            }).toList(),
          );
        },
      ),
    ];
  }
}
