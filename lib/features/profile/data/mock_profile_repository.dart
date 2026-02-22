import 'package:clubal_app/features/profile/models/user_profile.dart';
import 'package:clubal_app/features/profile/data/profile_repository.dart';

class MockProfileRepository implements ProfileRepository {
  MockProfileRepository._();
  static final MockProfileRepository instance = MockProfileRepository._();

  @override
  Future<UserProfile> fetchUserProfile(String userId) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return const UserProfile(
      id: 'me',
      displayName: '주지훈',
      username: 'jujihun',
      bio: '나는 주지훈 입니다. 1000만 영화배우입니다!!',
      totalMatches: 12,
      successfulMatches: 8,
      preferredGenres: ['EDM', '힙합'],
      recentMatchLocation: '강남',
    );
  }
}
