import 'package:clubal_app/features/match/data/match_model.dart';
import 'package:clubal_app/features/match/data/match_repository.dart';

class MockMatchRepository implements MatchRepository {
  MockMatchRepository._();
  static final MockMatchRepository instance = MockMatchRepository._();

  List<Match> _mockMatches() {
    final now = DateTime.now();
    return [
      Match(
        id: 'ma1',
        clubName: '강남 Club Arena',
        location: '강남역',
        matchType: '클럽 조각',
        dateTime: now.add(const Duration(days: 3)),
        status: 'active',
        createdAt: now.subtract(const Duration(hours: 2)),
        activeStep: 1,
      ),
      Match(
        id: 'ma2',
        clubName: '홍대 Octagon',
        location: '홍대입구',
        matchType: '감성주점',
        dateTime: now.add(const Duration(days: 5)),
        status: 'active',
        createdAt: now.subtract(const Duration(hours: 5)),
        activeStep: 2,
      ),
      Match(
        id: 'mp1',
        clubName: '이태원 Noir Stage',
        location: '이태원',
        matchType: '힙합 클럽',
        dateTime: now.add(const Duration(days: 7)),
        status: 'pending',
        createdAt: now.subtract(const Duration(hours: 1)),
      ),
      Match(
        id: 'mc1',
        clubName: '성수 Coterie',
        location: '성수동',
        matchType: '클럽 조각',
        dateTime: now.add(const Duration(days: 2, hours: 19)),
        status: 'confirmed',
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      Match(
        id: 'mc2',
        clubName: '강남 MASS',
        location: '강남',
        matchType: 'EDM 클럽',
        dateTime: now.add(const Duration(days: 4, hours: 21)),
        status: 'confirmed',
        createdAt: now.subtract(const Duration(days: 3)),
      ),
    ];
  }

  @override
  Future<List<Match>> fetchMatches() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return _mockMatches();
  }

  @override
  Future<List<Match>> fetchMatchesByStatus(String status) async {
    final all = await fetchMatches();
    return all.where((m) => m.status == status).toList();
  }

  @override
  Future<int> countMatchesByStatus(String status) async {
    final all = await fetchMatches();
    return all.where((m) => m.status == status).length;
  }
}
