class NotificationSettings {
  const NotificationSettings({
    this.chat = true,
    this.matching = true,
    this.sound = true,
    this.vibration = true,
    this.postActivity = true,
    this.postLikes = true,
    this.commentsReplies = true,
    this.recommendedPosts = true,
    this.recommendation = true,
    this.promotion = false,
  });

  final bool chat;
  final bool matching;
  final bool sound;
  final bool vibration;
  final bool postActivity;
  final bool postLikes;
  final bool commentsReplies;
  final bool recommendedPosts;
  final bool recommendation;
  final bool promotion;

  NotificationSettings copyWith({
    bool? chat,
    bool? matching,
    bool? sound,
    bool? vibration,
    bool? postActivity,
    bool? postLikes,
    bool? commentsReplies,
    bool? recommendedPosts,
    bool? recommendation,
    bool? promotion,
  }) {
    return NotificationSettings(
      chat: chat ?? this.chat,
      matching: matching ?? this.matching,
      sound: sound ?? this.sound,
      vibration: vibration ?? this.vibration,
      postActivity: postActivity ?? this.postActivity,
      postLikes: postLikes ?? this.postLikes,
      commentsReplies: commentsReplies ?? this.commentsReplies,
      recommendedPosts: recommendedPosts ?? this.recommendedPosts,
      recommendation: recommendation ?? this.recommendation,
      promotion: promotion ?? this.promotion,
    );
  }
}

