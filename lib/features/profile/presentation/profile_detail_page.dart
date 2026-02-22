import 'package:clubal_app/core/widgets/clubal_glass_card.dart';
import 'package:clubal_app/core/widgets/clubal_page_scaffold.dart';
import 'package:clubal_app/features/profile/models/user_profile.dart';
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
    if (result != null && context.mounted) {
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
    final onSurfaceVariant = Theme.of(context).colorScheme.onSurfaceVariant;

    return ClubalPageScaffold(
      title: '프로필',
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            _TopSection(profile: profile),
            const SizedBox(height: 24),
            _ActivitySummaryCard(profile: profile),
            const SizedBox(height: 24),
            _EditButton(onPressed: () => _openEdit(context)),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _TopSection extends StatelessWidget {
  const _TopSection({required this.profile});
  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final onSurfaceVariant = Theme.of(context).colorScheme.onSurfaceVariant;

    return ClubalGlassCard(
      radius: 20,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 52,
            backgroundColor: onSurface.withValues(alpha: 0.15),
            child: Icon(Icons.person_rounded, color: onSurface, size: 52),
          ),
          const SizedBox(height: 16),
          Text(
            profile.displayName,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: onSurface,
                ),
          ),
          if (profile.username.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              '@${profile.username}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: onSurfaceVariant,
                  ),
            ),
          ],
          if (profile.bio.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              profile.bio,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: onSurface.withValues(alpha: 0.8),
                    height: 1.4,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ActivitySummaryCard extends StatelessWidget {
  const _ActivitySummaryCard({required this.profile});
  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final onSurfaceVariant = Theme.of(context).colorScheme.onSurfaceVariant;
    final successRatePercent =
        (profile.successRate * 100).toStringAsFixed(0);
    final genresText = profile.preferredGenres.isNotEmpty
        ? profile.preferredGenres.join(', ')
        : '-';

    return ClubalGlassCard(
      radius: 20,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '활동 요약',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: onSurface,
                ),
          ),
          const SizedBox(height: 16),
          _ActivityRow(
            label: '총 매칭 횟수',
            value: '${profile.totalMatches}회',
          ),
          const SizedBox(height: 10),
          _ActivityRow(
            label: '성공률',
            value: '$successRatePercent%',
          ),
          const SizedBox(height: 10),
          _ActivityRow(
            label: '최근 매칭 지역',
            value: profile.recentMatchLocation.isNotEmpty
                ? profile.recentMatchLocation
                : '-',
          ),
          const SizedBox(height: 10),
          _ActivityRow(
            label: '선호 장르',
            value: genresText,
          ),
        ],
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final onSurfaceVariant = Theme.of(context).colorScheme.onSurfaceVariant;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: onSurfaceVariant,
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: onSurface,
              ),
        ),
      ],
    );
  }
}

class _EditButton extends StatelessWidget {
  const _EditButton({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return InkWell(
      onTap: onPressed,
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
          '프로필 편집',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: onSurface,
              ),
        ),
      ),
    );
  }
}
