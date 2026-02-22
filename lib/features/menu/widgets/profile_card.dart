import 'dart:ui';

import 'package:clubal_app/core/theme/app_glass_styles.dart';
import 'package:clubal_app/features/profile/models/user_profile.dart';
import 'package:clubal_app/features/profile/presentation/profile_edit_page.dart';
import 'package:clubal_app/features/profile/presentation/user_profile_scope.dart';
import 'package:flutter/material.dart';

/// 프로필 카드. Liquid Glass 스타일, 아이덴티티 + 활동 중심 구조.
class MenuProfileCard extends StatelessWidget {
  const MenuProfileCard({
    super.key,
    required this.profile,
    required this.onTap,
  });

  final UserProfile profile;
  final VoidCallback onTap;

  void _showMoreMenu(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit_rounded),
                title: const Text('프로필 편집'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _openEdit(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera_rounded),
                title: const Text('사진 변경'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('사진 변경 기능은 준비 중입니다.')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout_rounded),
                title: const Text('로그아웃'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('로그아웃되었습니다.')),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openEdit(BuildContext context) async {
    final controller = UserProfileScope.of(context);
    final result = await Navigator.of(context).push<ProfileEditResult>(
      MaterialPageRoute<ProfileEditResult>(
        builder: (_) => ProfileEditPage(
          initialDisplayName: profile.displayName,
          initialBio: profile.bio,
        ),
      ),
    );
    if (result != null && context.mounted) {
      controller.updatePartial(
        displayName: result.displayName,
        bio: result.bio,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final onSurfaceVariant = Theme.of(context).colorScheme.onSurfaceVariant;

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: AppGlassStyles.card(
              radius: 24,
              isDark: Theme.of(context).brightness == Brightness.dark,
            ),
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
            child: Stack(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: onSurface.withValues(alpha: 0.15),
                      child: Icon(
                        Icons.person_rounded,
                        color: onSurface,
                        size: 40,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            profile.displayName,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: onSurface,
                                ),
                          ),
                          if (profile.username.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              '@${profile.username}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: onSurfaceVariant,
                                    fontSize: 13,
                                  ),
                            ),
                          ],
                          if (profile.bio.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              '"${profile.bio}"',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: onSurfaceVariant.withValues(alpha: 0.9),
                                    fontStyle: FontStyle.italic,
                                  ),
                            ),
                          ],
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _StatChip(
                                value: '${profile.totalMatches}',
                                label: '참여 모임',
                              ),
                              const SizedBox(width: 12),
                              _StatChip(
                                value: '${profile.successfulMatches}',
                                label: '매칭 성공',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: onSurfaceVariant,
                      size: 24,
                    ),
                  ],
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                    onPressed: () => _showMoreMenu(context),
                    icon: Icon(Icons.more_horiz_rounded, color: onSurfaceVariant),
                    style: IconButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(36, 36),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.value,
    required this.label,
  });

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .onSurface
            .withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}
