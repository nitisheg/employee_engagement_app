enum LeaderboardPeriod { allTime, thisMonth, thisWeek, teams }

class LeaderboardEntry {
  final int userId;
  final String name;
  final String department;
  final String initials;
  final String avatarColorHex;
  final int points;
  final int rank;
  final int rankChange; // positive = moved up, negative = moved down

  const LeaderboardEntry({
    required this.userId,
    required this.name,
    required this.department,
    required this.initials,
    required this.avatarColorHex,
    required this.points,
    required this.rank,
    required this.rankChange,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      userId: json['user_id'] as int,
      name: json['name'] as String,
      department: json['department'] as String,
      initials: json['initials'] as String,
      avatarColorHex: json['avatar_color_hex'] as String? ?? '#E53935',
      points: json['points'] as int,
      rank: json['rank'] as int,
      rankChange: json['rank_change'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'name': name,
        'department': department,
        'initials': initials,
        'avatar_color_hex': avatarColorHex,
        'points': points,
        'rank': rank,
        'rank_change': rankChange,
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
    return LeaderboardResponse(
      entries: (json['entries'] as List)
          .map((e) => LeaderboardEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      period: _parsePeriod(json['period'] as String),
      currentUserEntry: json['current_user_entry'] != null
          ? LeaderboardEntry.fromJson(
              json['current_user_entry'] as Map<String, dynamic>)
          : null,
    );
  }

  static LeaderboardPeriod _parsePeriod(String s) {
    switch (s) {
      case 'this_month':
        return LeaderboardPeriod.thisMonth;
      case 'this_week':
        return LeaderboardPeriod.thisWeek;
      case 'teams':
        return LeaderboardPeriod.teams;
      default:
        return LeaderboardPeriod.allTime;
    }
  }
}
