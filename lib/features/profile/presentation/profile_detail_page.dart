import 'package:clubal_app/core/widgets/clubal_background.dart';
import 'package:clubal_app/core/widgets/clubal_full_body.dart';
import 'package:clubal_app/core/widgets/glass_card.dart';
import 'package:clubal_app/core/widgets/pressed_icon_action_button.dart';
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

    return Scaffold(
      body: Builder(
        builder: (context) => wrapFullBody(
          context,
          Stack(
            children: [
              Positioned.fill(
                child: IgnorePointer(child: ClubalBackground()),
              ),
              SafeArea(
                child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      PressedIconActionButton(
                        icon: Icons.arrow_back_rounded,
                        tooltip: '뒤로가기',
                        onTap: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '프로필',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF243244),
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final side = constraints.maxWidth;
                      return GlassCard(
                        child: Container(
                          width: side,
                          height: side,
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Spacer(flex: 2),
                              CircleAvatar(
                                radius: 48,
                                backgroundColor: Colors.white.withOpacity(0.25),
                                child: const Icon(
                                  Icons.person_rounded,
                                  color: Color(0xFF243244),
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
                                      color: const Color(0xFF243244),
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
                                      color: const Color(0xFF304255)
                                          .withOpacity(0.8),
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
                              const Spacer(flex: 3),
                              InkWell(
                                onTap: () => _openEdit(context),
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 14),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.4),
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
                                          color: const Color(0xFF243244),
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
                  const Spacer(                  ),
                ],
              ),
            ),
              ),
            ],
          ),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF304255)),
          const SizedBox(width: 6),
          Text(
            text,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: const Color(0xFF304255),
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }
}
