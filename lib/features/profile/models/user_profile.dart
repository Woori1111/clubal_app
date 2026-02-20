class UserProfile {
  const UserProfile({
    required this.displayName,
    required this.bio,
  });

  final String displayName;
  final String bio;

  UserProfile copyWith({
    String? displayName,
    String? bio,
  }) {
    return UserProfile(
      displayName: displayName ?? this.displayName,
      bio: bio ?? this.bio,
    );
  }
}

