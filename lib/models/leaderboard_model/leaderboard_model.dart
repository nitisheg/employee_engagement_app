enum LeaderboardPeriod { allTime, monthly, weekly, today, teams }

class LeaderboardEntry {
  final String userId;
  final String name;
  final String? avatar;
  final String initials;
  final int points;
  final int rank;
  final bool isCurrentUser;

  const LeaderboardEntry({
    required this.userId,
    required this.name,
    this.avatar,
    required this.initials,
    required this.points,
    required this.rank,
    this.isCurrentUser = false,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    final rawUserId = json['user_id'] ?? json['userId'] ?? '';
    return LeaderboardEntry(
      userId: rawUserId is String ? rawUserId : rawUserId?.toString() ?? '',
      name: (json['name'] ?? '') as String,
      avatar: json['avatar'] as String?,
      initials: (json['initials'] ?? '') as String,
      points: (json['points'] ?? 0) as int,
      rank: (json['rank'] ?? 0) as int,
      isCurrentUser:
          (json['isCurrentUser'] ?? json['is_current_user'] ?? false) as bool,
    );
  }

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'name': name,
    'avatar': avatar,
    'initials': initials,
    'points': points,
    'rank': rank,
    'isCurrentUser': isCurrentUser,
  };
}

class TeamLeaderboardEntry {
  final int teamId;
  final String name;
  final int memberCount;
  final int totalPoints;
  final int rank;
  final String colorHex;

  const TeamLeaderboardEntry({
    required this.teamId,
    required this.name,
    required this.memberCount,
    required this.totalPoints,
    required this.rank,
    required this.colorHex,
  });

  factory TeamLeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return TeamLeaderboardEntry(
      teamId: json['team_id'] as int,
      name: json['name'] as String,
      memberCount: json['member_count'] as int,
      totalPoints: json['total_points'] as int,
      rank: json['rank'] as int,
      colorHex: json['color_hex'] as String? ?? '#E53935',
    );
  }
}

class LeaderboardResponse {
  final List<LeaderboardEntry> entries;
  final LeaderboardPeriod period;
  final LeaderboardEntry? currentUserEntry;

  const LeaderboardResponse({
    required this.entries,
    required this.period,
    this.currentUserEntry,
  });

  factory LeaderboardResponse.fromJson(Map<String, dynamic> json) {
    final leaderboard = (json['leaderboard'] as List<dynamic>?) ?? [];
    final entries = leaderboard
        .map((e) => LeaderboardEntry.fromJson(e as Map<String, dynamic>))
        .toList();

    final currentUserIndex = entries.indexWhere((e) => e.isCurrentUser);
    final currentUserEntry = currentUserIndex >= 0
        ? entries[currentUserIndex]
        : null;

    return LeaderboardResponse(
      entries: entries,
      period: _parsePeriod(json['period'] as String? ?? 'all-time'),
      currentUserEntry: currentUserEntry,
    );
  }

  static LeaderboardPeriod _parsePeriod(String s) {
    switch (s.toLowerCase()) {
      case 'monthly':
      case 'this_month':
        return LeaderboardPeriod.monthly;
      case 'weekly':
      case 'this_week':
        return LeaderboardPeriod.weekly;
      case 'today':
        return LeaderboardPeriod.today;
      case 'teams':
        return LeaderboardPeriod.teams;
      case 'all-time':
      case 'all_time':
      default:
        return LeaderboardPeriod.allTime;
    }
  }
}

