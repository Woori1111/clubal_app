import 'package:clubal_app/features/match/data/match_model.dart';

/// 매칭 Repository 인터페이스.
/// Firestore / REST API 연동 시 구현체만 교체.
abstract class MatchRepository {
  Future<List<Match>> fetchMatches();
  Future<List<Match>> fetchMatchesByStatus(String status);
  Future<int> countMatchesByStatus(String status);
}
