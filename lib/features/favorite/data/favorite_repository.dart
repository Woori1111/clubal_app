import 'package:clubal_app/features/favorite/data/club_model.dart';
import 'package:clubal_app/features/favorite/data/favorite_model.dart';

/// 즐겨찾기 Repository 인터페이스.
/// Firestore / REST API 연동 시 구현체만 교체.
abstract class FavoriteRepository {
  Future<List<Favorite>> fetchUserFavorites(String userId);
  Future<List<Club>> fetchFavoriteClubs(String userId);
  Future<int> countFavoriteClubs(String userId);
  Future<List<Club>> fetchRecentVisitClubs(String userId);
}
