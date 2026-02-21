import 'dart:ui';

import 'package:clubal_app/core/theme/app_colors.dart';
import 'package:clubal_app/core/theme/app_glass_styles.dart';
import 'package:clubal_app/core/utils/app_dialogs.dart';
import 'package:clubal_app/features/matching/models/piece_room.dart';
import 'package:clubal_app/features/matching/presentation/dialogs/matching_info_dialog.dart';
import 'package:clubal_app/features/matching/presentation/room_applicants_page.dart';
import 'package:clubal_app/features/matching/presentation/widgets/matching_page_scaffold.dart';
import 'package:clubal_app/core/firestore/piece_room_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PieceRoomDetailPage extends StatefulWidget {
  const PieceRoomDetailPage({
    super.key,
    required this.room,
    required this.isMyRoom,
    required this.pieceRoomService,
  });

  final PieceRoom room;
  final bool isMyRoom;
  final PieceRoomService pieceRoomService;

  @override
  State<PieceRoomDetailPage> createState() => _PieceRoomDetailPageState();
}

class _PieceRoomDetailPageState extends State<PieceRoomDetailPage> {
  PieceRoom get _room => widget.room;
  bool get _isMyRoom {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null && widget.room.creatorUid != null) {
      return widget.room.creatorUid == uid;
    }
    return widget.isMyRoom;
  }
  PieceRoomService get _service => widget.pieceRoomService;

  Future<void> _showRecruitmentStatusSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '모집 상태 선택',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
              ),
              const SizedBox(height: 16),
              ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                tileColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                leading: Icon(Icons.check_circle_rounded, color: AppColors.success),
                title: const Text('모집중'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final id = _room.id;
                  if (id != null) await _service.updateRecruitmentClosed(id, false);
                  if (mounted) showMatchingInfoDialog(context, message: '모집중으로 변경되었습니다.');
                },
              ),
              const SizedBox(height: 8),
              ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                tileColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                leading: Icon(Icons.cancel_rounded, color: AppColors.failure),
                title: const Text('모집완료'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final id = _room.id;
                  if (id != null) await _service.updateRecruitmentClosed(id, true);
                  if (mounted) showMatchingInfoDialog(context, message: '모집완료로 변경되었습니다.');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteRoom() async {
    final id = _room.id;
    if (id == null) return;
    await _service.deleteRoom(id);
    if (mounted) {
      showMatchingInfoDialog(context, message: '방이 삭제되었습니다.');
      Navigator.of(context).pop();
    }
  }

  Future<void> _applyToRoom() async {
    final id = _room.id;
    if (id == null) return;
    await _service.applyToRoom(id);
    if (mounted) {
      showMatchingInfoDialog(context, message: '신청이 완료되었습니다.');
      Navigator.of(context).pop();
    }
  }

  void _showApplicants() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => RoomApplicantsPage(room: _room),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final onSurface = colorScheme.onSurface;
    final onSurfaceVariant = colorScheme.onSurfaceVariant;
    final outlineVariant = colorScheme.outlineVariant;
    final room = _room;

    return StreamBuilder<PieceRoom?>(
      stream: room.id != null ? _service.streamRoom(room.id!) : null,
      builder: (context, snap) {
        final currentRoom = snap.hasData && snap.data != null ? snap.data! : room;

        return MatchingPageScaffold(
          title: '조각 상세',
          bottomPadding: 0,
          appBarTrailing: _isMyRoom
              ? IconButton(
                  onPressed: () {
                    showMessageDialog(context, message: '편집 기능은 준비 중입니다.');
                  },
                  icon: Icon(Icons.edit_rounded, color: onSurface),
                )
              : null,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentRoom.title,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: onSurface,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(Icons.person_rounded, size: 20, color: onSurfaceVariant),
                          const SizedBox(width: 8),
                          Text(
                            '${currentRoom.creator} 님',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: onSurfaceVariant,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: outlineVariant.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              currentRoom.capacityLabel,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _LocationCard(location: currentRoom.locationDisplay),
                      const SizedBox(height: 24),
                      Divider(height: 1, color: outlineVariant),
                      const SizedBox(height: 24),
                      Text(
                        currentRoom.description ?? '',
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.6,
                          color: onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _BottomActions(
                isMyRoom: _isMyRoom,
                room: currentRoom,
                onStatusTap: _showRecruitmentStatusSheet,
                onDeleteTap: _deleteRoom,
                onApplicantsTap: _showApplicants,
                onApplyTap: _applyToRoom,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BottomActions extends StatelessWidget {
  const _BottomActions({
    required this.isMyRoom,
    required this.room,
    required this.onStatusTap,
    required this.onDeleteTap,
    required this.onApplicantsTap,
    required this.onApplyTap,
  });

  final bool isMyRoom;
  final PieceRoom room;
  final VoidCallback onStatusTap;
  final VoidCallback onDeleteTap;
  final VoidCallback onApplicantsTap;
  final VoidCallback onApplyTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasId = room.id != null;

    if (isMyRoom && hasId) {
      return Container(
        padding: EdgeInsets.fromLTRB(20, 16, 20, 16 + MediaQuery.paddingOf(context).bottom),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.95),
        ),
        child: Row(
          children: [
            _GlassIconButton(
              icon: Icons.people_rounded,
              tooltip: '신청한 사람',
              onTap: onApplicantsTap,
              isDark: isDark,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _GlassTextButton(
                label: '상태변경',
                color: const Color(0xFF2ECEF2),
                onTap: onStatusTap,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _GlassTextButton(
                label: '삭제',
                color: const Color(0xFFE53935),
                onTap: onDeleteTap,
                isDark: isDark,
              ),
            ),
          ],
        ),
      );
    }

    if (!isMyRoom && hasId && !room.isFullOrClosed) {
      return Container(
        padding: EdgeInsets.fromLTRB(20, 16, 20, 16 + MediaQuery.paddingOf(context).bottom),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.95),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            width: double.infinity,
            child: _GlassTextButton(
              label: '신청',
              color: const Color(0xFF2ECEF2),
              onTap: onApplyTap,
              isDark: isDark,
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

class _GlassIconButton extends StatelessWidget {
  const _GlassIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    required this.isDark,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: AppGlassStyles.innerCard(radius: 16, isDark: isDark),
          child: Icon(icon, size: 24, color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      ),
    );
  }
}

class _GlassTextButton extends StatelessWidget {
  const _GlassTextButton({
    required this.label,
    required this.color,
    required this.onTap,
    required this.isDark,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color, width: 1.5),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: label == '삭제' ? Colors.white : color,
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

class _LocationCard extends StatelessWidget {
  const _LocationCard({required this.location});

  final String location;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurfaceVariant = Theme.of(context).colorScheme.onSurfaceVariant;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: AppGlassStyles.innerCard(
        radius: 12,
        isDark: isDark,
      ),
      child: Row(
        children: [
          Icon(Icons.place_rounded, size: 20, color: onSurfaceVariant),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              location,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
