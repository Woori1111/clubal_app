import 'package:clubal_app/core/theme/app_glass_styles.dart';
import 'package:clubal_app/core/widgets/clubal_background.dart';
import 'package:clubal_app/core/widgets/clubal_full_body.dart';
import 'package:clubal_app/core/widgets/pressed_icon_action_button.dart';
import 'package:clubal_app/features/favorite/data/club_model.dart';
import 'package:clubal_app/features/favorite/data/mock_favorite_repository.dart';
import 'package:flutter/material.dart';

/// 최근 방문 클럽 상세 리스트 페이지.
class RecentVisitClubsPage extends StatelessWidget {
  const RecentVisitClubsPage({super.key});

  static const _userId = 'me';

  @override
  Widget build(BuildContext context) {
    final repository = MockFavoriteRepository.instance;

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
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
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
                          Expanded(
                            child: Text(
                              '🕐 최근 방문 클럽',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: FutureBuilder<List<Club>>(
                          future: repository.fetchRecentVisitClubs(_userId),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            if (snapshot.hasError) {
                              return Center(
                                child: Text(
                                  '목록을 불러올 수 없습니다.',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Theme.of(context).colorScheme.error,
                                      ),
                                ),
                              );
                            }
                            final list = snapshot.data ?? [];
                            if (list.isEmpty) {
                              return Center(
                                child: Text(
                                  '최근 방문한 클럽이 없습니다.',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      ),
                                ),
                              );
                            }
                            return ListView.separated(
                              itemCount: list.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final club = list[index];
                                return _ClubCard(club: club);
                              },
                            );
                          },
                        ),
                      ),
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

class _ClubCard extends StatelessWidget {
  const _ClubCard({required this.club});

  final Club club;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final onSurfaceVariant = Theme.of(context).colorScheme.onSurfaceVariant;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: AppGlassStyles.innerCard(radius: 12, isDark: isDark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            club.name,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: onSurface,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            '${club.location} | ${club.genre}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: onSurfaceVariant,
                  fontSize: 12,
                ),
          ),
        ],
      ),
    );
  }
}
