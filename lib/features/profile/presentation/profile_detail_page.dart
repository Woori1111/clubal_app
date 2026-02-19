import 'package:clubal_app/core/widgets/clubal_background.dart';
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
      body: Stack(
        children: [
          const ClubalBackground(),
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
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '프로필',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF243244),
                        ),
                  ),
                  const SizedBox(height: 20),
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
                            backgroundColor: Colors.white.withOpacity(0.25),
                            child: const Icon(
                              Icons.person_rounded,
                              color: Color(0xFF243244),
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            profile.displayName,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            profile.bio,
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
                  const SizedBox(height: 20),
                  _ProfileEditOptionCard(
                    title: '프로필 편집',
                    subtitle: '이름, 소개를 수정할 수 있어요',
                    onTap: () => _openEdit(context),
                  ),
                  const SizedBox(height: 12),
                  _ProfileEditOptionCard(
                    title: '프로필 사진 변경',
                    subtitle: '프로필 사진을 바꿀 수 있어요',
                    onTap: () => _openEdit(context),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileEditOptionCard extends StatelessWidget {
  const _ProfileEditOptionCard({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style:
                          Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF243244),
                              ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style:
                          Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: const Color(0xCC243244),
                              ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF243244),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
