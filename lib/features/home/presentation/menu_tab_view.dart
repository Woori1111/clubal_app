import 'dart:ui';

import 'package:clubal_app/core/theme/app_glass_styles.dart';
import 'package:clubal_app/features/profile/presentation/profile_detail_page.dart';
import 'package:clubal_app/features/profile/presentation/user_profile_scope.dart';
import 'package:clubal_app/features/settings/presentation/clubal_settings_page.dart';
import 'package:clubal_app/features/settings/presentation/notification_settings_controller.dart';
import 'package:flutter/material.dart';

class MenuTabView extends StatefulWidget {
  const MenuTabView({super.key});

  @override
  State<MenuTabView> createState() => _MenuTabViewState();
}

class _MenuTabViewState extends State<MenuTabView> {
  late final NotificationSettingsController _settingsController =
      NotificationSettingsController();

  @override
  Widget build(BuildContext context) {
    final controller = UserProfileScope.of(context);
    final profile = controller.profile;

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      children: [
        Text(
          '프로필',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF243244),
              ),
        ),
        const SizedBox(height: 20),
        _ProfileSummaryCard(
          displayName: profile.displayName,
          bio: profile.bio,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => UserProfileScope(
                  controller: controller,
                  child: const ProfileDetailPage(),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 24),
        InlineSettingsContent(
          controller: _settingsController,
          onNotificationSettingsChanged: () => setState(() {}),
        ),
      ],
    );
  }
}

class _ProfileSummaryCard extends StatelessWidget {
  const _ProfileSummaryCard({
    required this.displayName,
    required this.bio,
    required this.onTap,
  });

  final String displayName;
  final String bio;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: AppGlassStyles.card(radius: 24),
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white.withOpacity(0.25),
                  child: const Icon(
                    Icons.person_rounded,
                    color: Color(0xFF243244),
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
                        displayName,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF243244),
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        bio.isNotEmpty ? bio : '내 프로필 보기',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: const Color(0xFF304255).withOpacity(0.8),
                            ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF304255),
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
