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
    this.popularPosts = true,
    this.recommendation = true,
    this.promotion = false,
    this.marketingConsent = false,
    this.marketingSms = false,
    this.marketingAppPush = false,
  });

  final bool chat;
  final bool matching;
  final bool sound;
  final bool vibration;
  final bool postActivity;
  final bool postLikes;
  final bool commentsReplies;
  final bool recommendedPosts;
  final bool popularPosts;
  final bool recommendation;
  final bool promotion;
  final bool marketingConsent;
  final bool marketingSms;
  final bool marketingAppPush;

  NotificationSettings copyWith({
    bool? chat,
    bool? matching,
    bool? sound,
    bool? vibration,
    bool? postActivity,
    bool? postLikes,
    bool? commentsReplies,
    bool? recommendedPosts,
    bool? popularPosts,
    bool? recommendation,
    bool? promotion,
    bool? marketingConsent,
    bool? marketingSms,
    bool? marketingAppPush,
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
      popularPosts: popularPosts ?? this.popularPosts,
      recommendation: recommendation ?? this.recommendation,
      promotion: promotion ?? this.promotion,
      marketingConsent: marketingConsent ?? this.marketingConsent,
      marketingSms: marketingSms ?? this.marketingSms,
      marketingAppPush: marketingAppPush ?? this.marketingAppPush,
    );
  }
}

