class UserProfile {
  const UserProfile({
    required this.id,
    required this.displayName,
    required this.username,
    required this.bio,
    this.totalMatches = 0,
    this.successfulMatches = 0,
    this.preferredGenres = const [],
    this.recentMatchLocation = '',
  });

  final String id;
  final String displayName;
  final String username;
  final String bio;
  final int totalMatches;
  final int successfulMatches;
  final List<String> preferredGenres;
  final String recentMatchLocation;

  double get successRate =>
      totalMatches > 0 ? successfulMatches / totalMatches : 0;

  UserProfile copyWith({
    String? id,
    String? displayName,
    String? username,
    String? bio,
    int? totalMatches,
    int? successfulMatches,
    List<String>? preferredGenres,
    String? recentMatchLocation,
  }) {
    return UserProfile(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      username: username ?? this.username,
      bio: bio ?? this.bio,
      totalMatches: totalMatches ?? this.totalMatches,
      successfulMatches: successfulMatches ?? this.successfulMatches,
      preferredGenres: preferredGenres ?? this.preferredGenres,
      recentMatchLocation: recentMatchLocation ?? this.recentMatchLocation,
    );
  }
}

