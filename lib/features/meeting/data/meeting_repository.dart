import 'package:clubal_app/features/meeting/data/meeting_model.dart';

/// 모임 Repository 인터페이스.
/// Firebase / REST API 연동 시 구현체만 교체하면 됨.
abstract class MeetingRepository {
  Future<List<Meeting>> fetchMeetings();
  Future<List<Meeting>> fetchCreatedMeetings(String userId);
  Future<List<Meeting>> fetchJoinedMeetings(String userId);
  Future<List<Meeting>> fetchMeetingsByStatus(String status);
}
