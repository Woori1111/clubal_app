import 'package:clubal_app/features/favorite/data/club_model.dart';
import 'package:clubal_app/features/favorite/data/favorite_model.dart';
import 'package:clubal_app/features/favorite/data/favorite_repository.dart';

class MockFavoriteRepository implements FavoriteRepository {
  MockFavoriteRepository._();
  static final MockFavoriteRepository instance = MockFavoriteRepository._();

  static const _userId = 'me';

  List<Club> _mockClubs() => [
        Club(
          id: 'c1',
          name: '강남 Club Arena',
          location: '강남역',
          genre: 'EDM',
          todayMatchCount: 2,
        ),
        Club(
          id: 'c2',
          name: '홍대 Octagon',
          location: '홍대입구',
          genre: '힙합',
          todayMatchCount: 0,
        ),
        Club(
          id: 'c3',
          name: '이태원 Noir Stage',
          location: '이태원',
          genre: '힙합',
          todayMatchCount: 1,
        ),
        Club(
          id: 'c4',
          name: '성수 Coterie',
          location: '성수동',
          genre: '라운지',
          todayMatchCount: 0,
        ),
      ];

  List<Favorite> _mockFavorites() {
    final now = DateTime.now();
    return [
      Favorite(id: 'f1', userId: _userId, clubId: 'c1', createdAt: now.subtract(const Duration(days: 5))),
      Favorite(id: 'f2', userId: _userId, clubId: 'c2', createdAt: now.subtract(const Duration(days: 3))),
      Favorite(id: 'f3', userId: _userId, clubId: 'c3', createdAt: now.subtract(const Duration(days: 1))),
      Favorite(id: 'f4', userId: _userId, clubId: 'c4', createdAt: now.subtract(const Duration(hours: 12))),
    ];
  }

  @override
  Future<List<Favorite>> fetchUserFavorites(String userId) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return _mockFavorites().where((f) => f.userId == userId).toList();
  }

  @override
  Future<List<Club>> fetchFavoriteClubs(String userId) async {
    final favs = await fetchUserFavorites(userId);
    final clubs = _mockClubs();
    final clubIds = favs.map((f) => f.clubId).toSet();
    return clubs.where((c) => clubIds.contains(c.id)).toList();
  }

  @override
  Future<int> countFavoriteClubs(String userId) async {
    final favs = await fetchUserFavorites(userId);
    return favs.length;
  }

  @override
  Future<List<Club>> fetchRecentVisitClubs(String userId) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    final clubs = _mockClubs();
    return clubs.take(3).toList();
  }
}
