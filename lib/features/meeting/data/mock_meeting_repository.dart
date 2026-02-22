import 'package:clubal_app/features/meeting/data/meeting_model.dart';
import 'package:clubal_app/features/meeting/data/meeting_repository.dart';

/// Mock Meeting Repository.
/// 서버 연결 시 fetch* 메서드만 실제 API 호출로 교체.
class MockMeetingRepository implements MeetingRepository {
  MockMeetingRepository._();
  static final MockMeetingRepository instance = MockMeetingRepository._();

  static const _currentUserId = 'me';

  List<Meeting> _mockMeetings() {
    final now = DateTime.now();
    return [
      Meeting(
        id: 'm1',
        title: '강남 클럽 조각 모임',
        date: now.add(const Duration(days: 3)),
        status: 'scheduled',
        createdBy: _currentUserId,
      ),
      Meeting(
        id: 'm2',
        title: '홍대 감성주점 모임',
        date: now.add(const Duration(days: 7)),
        status: 'scheduled',
        createdBy: _currentUserId,
      ),
      Meeting(
        id: 'm3',
        title: '이태원 힙합 클럽 모임',
        date: now.subtract(const Duration(days: 2)),
        status: 'ended',
        createdBy: _currentUserId,
      ),
      Meeting(
        id: 'm4',
        title: '성수 클럽 투어',
        date: now,
        status: 'active',
        createdBy: 'user1',
      ),
      Meeting(
        id: 'm5',
        title: '강남 불금 모임',
        date: now.add(const Duration(days: 1)),
        status: 'active',
        createdBy: 'user2',
      ),
      Meeting(
        id: 'm6',
        title: '주말 클럽 나이트',
        date: now.subtract(const Duration(days: 5)),
        status: 'ended',
        createdBy: _currentUserId,
      ),
      Meeting(
        id: 'm7',
        title: 'D-1 급만남',
        date: now.add(const Duration(days: 1)),
        status: 'scheduled',
        createdBy: _currentUserId,
      ),
      Meeting(
        id: 'm8',
        title: '지난주 회식',
        date: now.subtract(const Duration(days: 10)),
        status: 'ended',
        createdBy: 'user3',
      ),
    ];
  }

  @override
  Future<List<Meeting>> fetchMeetings() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return _mockMeetings();
  }

  @override
  Future<List<Meeting>> fetchCreatedMeetings(String userId) async {
    final all = await fetchMeetings();
    return all.where((m) => m.createdBy == userId).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  Future<List<Meeting>> fetchJoinedMeetings(String userId) async {
    final all = await fetchMeetings();
    return all.where((m) => m.status == 'active').toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  @override
  Future<List<Meeting>> fetchMeetingsByStatus(String status) async {
    final all = await fetchMeetings();
    return all.where((m) => m.status == status).toList()
      ..sort((a, b) => status == 'ended' ? b.date.compareTo(a.date) : a.date.compareTo(b.date));
  }
}
