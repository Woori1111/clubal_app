import 'package:clubal_app/core/widgets/clubal_glass_card.dart';
import 'package:clubal_app/core/widgets/clubal_page_scaffold.dart';
import 'package:clubal_app/features/profile/presentation/profile_edit_page.dart';
import 'package:clubal_app/features/profile/presentation/user_profile_scope.dart';
import 'package:flutter/material.dart';

class ProfileDetailPage extends StatelessWidget {
  const ProfileDetailPage({super.key});

  Future<void> _openEdit(BuildContext context) async {
    final controller = UserProfileScope.of(context);
    final profile = controller.profile;
    final result = await Navigator.of(context).push<ProfileEditResult>(
      MaterialPageRoute<ProfileEditResult>(
        builder: (_) => ProfileEditPage(
          initialDisplayName: profile.displayName,
          initialBio: profile.bio,
        ),
      ),
    );
    if (result != null) {
      controller.updatePartial(
        displayName: result.displayName,
        bio: result.bio,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = UserProfileScope.of(context);
    final profile = controller.profile;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return ClubalPageScaffold(
      title: '프로필',
      appBarTrailing: TextButton(
        onPressed: () => _openEdit(context),
        child: Text(
          '편집',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: onSurface,
              ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            LayoutBuilder(
              builder: (context, constraints) {
                final side = constraints.maxWidth;
                return ClubalGlassCard(
                  radius: 20,
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  child: SizedBox(
                    width: side,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 48,
                          backgroundColor: onSurface.withValues(alpha: 0.15),
                          child: Icon(
                            Icons.person_rounded,
                            color: onSurface,
                            size: 48,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          profile.displayName,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: onSurface,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          profile.bio.isNotEmpty
                              ? profile.bio
                              : '소개글이 없습니다.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: onSurface.withValues(alpha: 0.8),
                                height: 1.4,
                              ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _InfoBadge(
                              icon: Icons.calendar_today_rounded,
                              text: '가입일: 2026. 02. 20',
                            ),
                            const SizedBox(width: 12),
                            _InfoBadge(
                              icon: Icons.person_outline_rounded,
                              text: '성별: 남성',
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        InkWell(
                          onTap: () => _openEdit(context),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: onSurface.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '프로필 수정',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: onSurface,
                                  ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  const _InfoBadge({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: onSurface.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: onSurface),
          const SizedBox(width: 6),
          Text(
            text,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: onSurface,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }
}
