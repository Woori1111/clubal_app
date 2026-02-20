import 'dart:ui';

import 'package:clubal_app/core/theme/app_colors.dart';
import 'package:clubal_app/core/theme/app_glass_styles.dart';
import 'package:clubal_app/core/widgets/liquid_pressable.dart';
import 'package:clubal_app/features/matching/models/piece_room.dart';
import 'package:clubal_app/features/matching/presentation/dialogs/matching_info_dialog.dart';
import 'package:clubal_app/features/matching/presentation/widgets/matching_page_scaffold.dart';
import 'package:flutter/material.dart';

class PieceRoomDetailPage extends StatefulWidget {
  const PieceRoomDetailPage({
    super.key,
    required this.room,
    required this.isMyRoom,
  });

  final PieceRoom room;
  final bool isMyRoom;

  @override
  State<PieceRoomDetailPage> createState() => _PieceRoomDetailPageState();
}

class _PieceRoomDetailPageState extends State<PieceRoomDetailPage> {
  late PieceRoom _room;

  @override
  void initState() {
    super.initState();
    _room = widget.room;
  }

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
                leading: const Icon(Icons.check_circle_rounded, color: AppColors.success),
                title: const Text('모집중'),
                onTap: () {
                  setState(() => _room = _room.copyWith(isRecruitmentClosed: false));
                  Navigator.of(context).pop();
                  showMatchingInfoDialog(context, message: '모집중으로 변경되었습니다.');
                },
              ),
              const SizedBox(height: 8),
              ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                tileColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                leading: const Icon(Icons.cancel_rounded, color: AppColors.failure),
                title: const Text('모집완료'),
                onTap: () {
                  setState(() => _room = _room.copyWith(isRecruitmentClosed: true));
                  Navigator.of(context).pop();
                  showMatchingInfoDialog(context, message: '모집완료로 변경되었습니다.');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final onSurface = colorScheme.onSurface;
    final onSurfaceVariant = colorScheme.onSurfaceVariant;
    final outlineVariant = colorScheme.outlineVariant;
    final room = _room;
    final isMyRoom = widget.isMyRoom;

    return MatchingPageScaffold(
      title: '조각 상세',
      bottomPadding: isMyRoom ? 24 : 18,
      appBarTrailing: isMyRoom
          ? IconButton(
              onPressed: () {
                showMatchingInfoDialog(context, message: '편집 기능은 준비 중입니다.');
              },
              icon: Icon(Icons.edit_rounded, color: onSurface),
            )
          : null,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    room.title,
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
                        '${room.creator} 님',
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
                          room.capacityLabel,
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
                  _LocationCard(location: room.locationDisplay),
                  const SizedBox(height: 24),
                  Divider(height: 1, color: outlineVariant),
                  const SizedBox(height: 24),
                  Text(
                    room.description ?? '',
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
          if (isMyRoom)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Row(
                children: [
                  Expanded(
                          child: LiquidPressable(
                            onTap: _showRecruitmentStatusSheet,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0x332ECEF2),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: const Color(0xFF2ECEF2), width: 1.5),
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    child: Center(
                                      child: Text(
                                        '상태변경',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF2ECEF2),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: LiquidPressable(
                      onTap: () {
                        showMatchingConfirmDialog(
                          context,
                          title: '삭제 확인',
                          message: '정말 이 조각 방을 삭제하시겠습니까?',
                          confirmLabel: '삭제',
                          cancelLabel: '취소',
                          destructive: true,
                          onConfirm: () {
                            showMatchingInfoDialog(
                              context,
                              message: '방이 삭제되었습니다.',
                              onConfirm: () => Navigator.of(context).pop(),
                            );
                          },
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xD9FF5E5E),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0x66FFFFFF), width: 1.5),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: Text(
                                  '삭제',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
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
