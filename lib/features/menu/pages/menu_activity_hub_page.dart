import 'package:clubal_app/features/menu/widgets/community_activity_section.dart';
import 'package:clubal_app/features/menu/widgets/favorite_places_section.dart';
import 'package:clubal_app/features/menu/widgets/matching_status_section.dart';
import 'package:clubal_app/features/menu/widgets/my_meetings_section.dart';
import 'package:clubal_app/features/menu/widgets/profile_card.dart';
import 'package:clubal_app/features/menu/widgets/safety_block_section.dart';
import 'package:clubal_app/features/profile/presentation/profile_detail_page.dart';
import 'package:clubal_app/features/profile/presentation/user_profile_scope.dart';
import 'package:flutter/material.dart';

/// 내 활동 허브 (My Activity Hub) 메인 페이지.
/// 설정 리스트 없음. 상단 톱니바퀴로 설정 이동.
class MenuActivityHubPage extends StatelessWidget {
  const MenuActivityHubPage({
    super.key,
    this.scrollController,
    this.onSwitchToMatching,
  });

  final ScrollController? scrollController;
  final VoidCallback? onSwitchToMatching;

  @override
  Widget build(BuildContext context) {
    final controller = UserProfileScope.of(context);
    final profile = controller.profile;

    return SingleChildScrollView(
      controller: scrollController,
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          MenuProfileCard(
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
          MatchingStatusSection(onTap: onSwitchToMatching),
          const SizedBox(height: 16),
          const MyMeetingsSection(),
          const SizedBox(height: 16),
          const FavoritePlacesSection(),
          const SizedBox(height: 16),
          const CommunityActivitySection(),
          const SizedBox(height: 16),
          const SafetyBlockSection(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
