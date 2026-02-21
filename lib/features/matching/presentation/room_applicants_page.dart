import 'dart:ui';

import 'package:clubal_app/core/theme/app_glass_styles.dart';
import 'package:clubal_app/features/matching/models/piece_room.dart';
import 'package:flutter/material.dart';

/// 내 조각 방 신청자 목록 (리퀴드 글라스 스타일)
class RoomApplicantsPage extends StatelessWidget {
  const RoomApplicantsPage({
    super.key,
    required this.room,
  });

  final PieceRoom room;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurfaceVariant = Theme.of(context).colorScheme.onSurfaceVariant;
    final applicants = room.applicantIds;
    final maxHeight = MediaQuery.of(context).size.height * 0.6;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            decoration: AppGlassStyles.card(radius: 24, isDark: isDark),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 12),
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: onSurfaceVariant.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
                    child: Row(
                      children: [
                        Icon(
                          Icons.people_rounded,
                          size: 24,
                          color: onSurfaceVariant,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '신청한 사람',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: onSurfaceVariant.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${applicants.length}명',
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: onSurfaceVariant,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  applicants.isEmpty
                      ? Padding(
                            padding: const EdgeInsets.all(32),
                            child: Center(
                              child: Text(
                                '아직 신청한 사람이 없어요',
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: onSurfaceVariant,
                                    ),
                              ),
                            ),
                          )
                      : Expanded(
                          child: ListView.separated(
                            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                            itemCount: applicants.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final uid = applicants[index];
                              return _ApplicantTile(
                                uid: uid,
                                isDark: isDark,
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

class _ApplicantTile extends StatelessWidget {
  const _ApplicantTile({required this.uid, required this.isDark});

  final String uid;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final onSurfaceVariant = Theme.of(context).colorScheme.onSurfaceVariant;
    final displayName = uid.length > 12 ? '${uid.substring(0, 12)}…' : uid;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: AppGlassStyles.innerCard(radius: 14, isDark: isDark),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: onSurfaceVariant.withValues(alpha: 0.3),
            child: Text(
              displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: onSurfaceVariant,
                  ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '신청자',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  displayName,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: onSurfaceVariant.withValues(alpha: 0.8),
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
