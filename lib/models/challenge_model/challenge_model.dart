enum ChallengeType { individual, team }

enum ChallengeStatus { active, available, completed, expired }

class ChallengeModel {
  final int id;
  final String title;
  final String description;
  final int pointsReward;
  final ChallengeType type;
  final ChallengeStatus status;
  final DateTime startDate;
  final DateTime endDate;
  final int? currentProgress;
  final int? targetProgress;
  final String? progressUnit;
  final String iconName;
  final String colorHex;

  const ChallengeModel({
    required this.id,
    required this.title,
    required this.description,
    required this.pointsReward,
    required this.type,
    required this.status,
    required this.startDate,
    required this.endDate,
    this.currentProgress,
    this.targetProgress,
    this.progressUnit,
    required this.iconName,
    required this.colorHex,
  });

  double get progressPercent {
    if (currentProgress == null || targetProgress == null || targetProgress == 0) {
      return 0;
    }
    return (currentProgress! / targetProgress!).clamp(0.0, 1.0);
  }

  int get daysLeft {
    final now = DateTime.now();
    return endDate.difference(now).inDays.clamp(0, 999);
  }

  factory ChallengeModel.fromJson(Map<String, dynamic> json) {
    return ChallengeModel(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      pointsReward: json['points_reward'] as int,
      type: json['type'] == 'team' ? ChallengeType.team : ChallengeType.individual,
      status: _parseStatus(json['status'] as String),
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      currentProgress: json['current_progress'] as int?,
      targetProgress: json['target_progress'] as int?,
      progressUnit: json['progress_unit'] as String?,
      iconName: json['icon_name'] as String? ?? 'flag',
      colorHex: json['color_hex'] as String? ?? '#E53935',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'points_reward': pointsReward,
        'type': type.name,
        'status': status.name,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
        'current_progress': currentProgress,
        'target_progress': targetProgress,
        'progress_unit': progressUnit,
        'icon_name': iconName,
        'color_hex': colorHex,
      };

  static ChallengeStatus _parseStatus(String s) {
    switch (s) {
      case 'active':
        return ChallengeStatus.active;
      case 'available':
        return ChallengeStatus.available;
      case 'completed':
        return ChallengeStatus.completed;
      default:
        return ChallengeStatus.expired;
    }
  }
}

class ChallengeJoinRequest {
  final int challengeId;

  const ChallengeJoinRequest({required this.challengeId});

  Map<String, dynamic> toJson() => {'challenge_id': challengeId};
}

class ChallengeProgressUpdate {
  final int challengeId;
  final int progressValue;

  const ChallengeProgressUpdate({
    required this.challengeId,
    required this.progressValue,
  });

  Map<String, dynamic> toJson() => {
        'challenge_id': challengeId,
        'progress_value': progressValue,
      };
}

