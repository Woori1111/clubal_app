import 'package:clubal_app/features/profile/models/user_profile.dart';

abstract class ProfileRepository {
  Future<UserProfile> fetchUserProfile(String userId);
}
