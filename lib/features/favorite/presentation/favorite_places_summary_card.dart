import 'package:clubal_app/features/favorite/data/mock_favorite_repository.dart';
import 'package:clubal_app/features/favorite/presentation/favorite_clubs_page.dart';
import 'package:clubal_app/features/favorite/presentation/recent_visit_clubs_page.dart';
import 'package:clubal_app/features/menu/widgets/activity_row_item.dart';
import 'package:flutter/material.dart';

/// 즐겨찾기 장소 요약 카드 내부 컨텐츠.
/// Repository 기반 count, 저장한 클럽/최근 방문 클럽 클릭 시 상세 화면 이동.
class FavoritePlacesSummaryCard extends StatelessWidget {
  const FavoritePlacesSummaryCard({super.key});

  static const _userId = 'me';

  @override
  Widget build(BuildContext context) {
    final repository = MockFavoriteRepository.instance;

    return FutureBuilder<Map<String, int>>(
      future: _fetchCounts(repository),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }
        final saved = snapshot.data?['saved'] ?? 0;
        final recentVisit = snapshot.data?['recentVisit'] ?? 0;

        return Column(
          children: [
            ActivityRowItem(
              label: '저장한 클럽',
              value: '${saved}곳',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const FavoriteClubsPage(),
                  ),
                );
              },
            ),
            ActivityRowItem(
              label: '최근 방문 클럽',
              value: '${recentVisit}곳',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const RecentVisitClubsPage(),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Future<Map<String, int>> _fetchCounts(MockFavoriteRepository repo) async {
    final saved = await repo.countFavoriteClubs(_userId);
    final recentClubs = await repo.fetchRecentVisitClubs(_userId);
    return {'saved': saved, 'recentVisit': recentClubs.length};
  }
}
