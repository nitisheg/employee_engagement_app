class PrivacySettingsModel {
  final String id;
  final String userId;
  final bool showProfilePublicly;
  final bool allowMessagesFromAnyone;
  final bool showActivityOnLeaderboard;
  final bool enableGroupInvites;
  final bool allowDataCollection;
  final bool enableNotifications;
  final bool enableEmailNotifications;
  final bool enablePushNotifications;
  final bool enableChallengeNotifications;
  final bool enableAchievementNotifications;
  final DateTime updatedAt;

  const PrivacySettingsModel({
    required this.id,
    required this.userId,
    this.showProfilePublicly = true,
    this.allowMessagesFromAnyone = true,
    this.showActivityOnLeaderboard = true,
    this.enableGroupInvites = true,
    this.allowDataCollection = false,
    this.enableNotifications = true,
    this.enableEmailNotifications = true,
    this.enablePushNotifications = true,
    this.enableChallengeNotifications = true,
    this.enableAchievementNotifications = true,
    required this.updatedAt,
  });

  factory PrivacySettingsModel.fromJson(Map<String, dynamic> json) {
    return PrivacySettingsModel(
      id: (json['_id'] ?? json['id'] ?? '') as String,
      userId: (json['userId'] ?? json['user_id'] ?? '') as String,
      showProfilePublicly:
          (json['showProfilePublicly'] ?? json['show_profile_publicly'] ?? true)
              as bool,
      allowMessagesFromAnyone:
          (json['allowMessagesFromAnyone'] ??
                  json['allow_messages_from_anyone'] ??
                  true)
              as bool,
      showActivityOnLeaderboard:
          (json['showActivityOnLeaderboard'] ??
                  json['show_activity_on_leaderboard'] ??
                  true)
              as bool,
      enableGroupInvites:
          (json['enableGroupInvites'] ?? json['enable_group_invites'] ?? true)
              as bool,
      allowDataCollection:
          (json['allowDataCollection'] ??
                  json['allow_data_collection'] ??
                  false)
              as bool,
      enableNotifications:
          (json['enableNotifications'] ?? json['enable_notifications'] ?? true)
              as bool,
      enableEmailNotifications:
          (json['enableEmailNotifications'] ??
                  json['enable_email_notifications'] ??
                  true)
              as bool,
      enablePushNotifications:
          (json['enablePushNotifications'] ??
                  json['enable_push_notifications'] ??
                  true)
              as bool,
      enableChallengeNotifications:
          (json['enableChallengeNotifications'] ??
                  json['enable_challenge_notifications'] ??
                  true)
              as bool,
      enableAchievementNotifications:
          (json['enableAchievementNotifications'] ??
                  json['enable_achievement_notifications'] ??
                  true)
              as bool,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'userId': userId,
    'showProfilePublicly': showProfilePublicly,
    'allowMessagesFromAnyone': allowMessagesFromAnyone,
    'showActivityOnLeaderboard': showActivityOnLeaderboard,
    'enableGroupInvites': enableGroupInvites,
    'allowDataCollection': allowDataCollection,
    'enableNotifications': enableNotifications,
    'enableEmailNotifications': enableEmailNotifications,
    'enablePushNotifications': enablePushNotifications,
    'enableChallengeNotifications': enableChallengeNotifications,
    'enableAchievementNotifications': enableAchievementNotifications,
    'updatedAt': updatedAt.toIso8601String(),
  };

  PrivacySettingsModel copyWith({
    bool? showProfilePublicly,
    bool? allowMessagesFromAnyone,
    bool? showActivityOnLeaderboard,
    bool? enableGroupInvites,
    bool? allowDataCollection,
    bool? enableNotifications,
    bool? enableEmailNotifications,
    bool? enablePushNotifications,
    bool? enableChallengeNotifications,
    bool? enableAchievementNotifications,
  }) {
    return PrivacySettingsModel(
      id: id,
      userId: userId,
      showProfilePublicly: showProfilePublicly ?? this.showProfilePublicly,
      allowMessagesFromAnyone:
          allowMessagesFromAnyone ?? this.allowMessagesFromAnyone,
      showActivityOnLeaderboard:
          showActivityOnLeaderboard ?? this.showActivityOnLeaderboard,
      enableGroupInvites: enableGroupInvites ?? this.enableGroupInvites,
      allowDataCollection: allowDataCollection ?? this.allowDataCollection,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      enableEmailNotifications:
          enableEmailNotifications ?? this.enableEmailNotifications,
      enablePushNotifications:
          enablePushNotifications ?? this.enablePushNotifications,
      enableChallengeNotifications:
          enableChallengeNotifications ?? this.enableChallengeNotifications,
      enableAchievementNotifications:
          enableAchievementNotifications ?? this.enableAchievementNotifications,
      updatedAt: DateTime.now(),
    );
  }
}

