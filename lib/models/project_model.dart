enum ProjectStatus { active, completed, inProgress, cancelled }

class ProjectModel {
  final int id;
  final String name;
  final String description;
  final int pointsReward;
  final int teamSize;
  final String duration;
  final List<String> requiredSkills;
  final String iconName;
  final String colorHex;
  final ProjectStatus status;
  final bool isVolunteered;

  const ProjectModel({
    required this.id,
    required this.name,
    required this.description,
    required this.pointsReward,
    required this.teamSize,
    required this.duration,
    required this.requiredSkills,
    required this.iconName,
    required this.colorHex,
    required this.status,
    required this.isVolunteered,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      pointsReward: json['points_reward'] as int,
      teamSize: json['team_size'] as int,
      duration: json['duration'] as String,
      requiredSkills: List<String>.from(json['required_skills'] as List),
      iconName: json['icon_name'] as String? ?? 'work',
      colorHex: json['color_hex'] as String? ?? '#E53935',
      status: _parseStatus(json['status'] as String),
      isVolunteered: json['is_volunteered'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'points_reward': pointsReward,
        'team_size': teamSize,
        'duration': duration,
        'required_skills': requiredSkills,
        'icon_name': iconName,
        'color_hex': colorHex,
        'status': status.name,
        'is_volunteered': isVolunteered,
      };

  static ProjectStatus _parseStatus(String s) {
    switch (s) {
      case 'completed':
        return ProjectStatus.completed;
      case 'in_progress':
        return ProjectStatus.inProgress;
      case 'cancelled':
        return ProjectStatus.cancelled;
      default:
        return ProjectStatus.active;
    }
  }
}

class UserProjectModel {
  final int id;
  final ProjectModel project;
  final String role;
  final int pointsEarned;
  final int pointsPending;
  final ProjectStatus status;
  final DateTime joinedAt;

  const UserProjectModel({
    required this.id,
    required this.project,
    required this.role,
    required this.pointsEarned,
    required this.pointsPending,
    required this.status,
    required this.joinedAt,
  });

  factory UserProjectModel.fromJson(Map<String, dynamic> json) {
    return UserProjectModel(
      id: json['id'] as int,
      project:
          ProjectModel.fromJson(json['project'] as Map<String, dynamic>),
      role: json['role'] as String,
      pointsEarned: json['points_earned'] as int,
      pointsPending: json['points_pending'] as int,
      status: ProjectModel._parseStatus(json['status'] as String),
      joinedAt: DateTime.parse(json['joined_at'] as String),
    );
  }
}

class ReferralRewardModel {
  final int id;
  final String companyName;
  final String projectName;
  final ProjectStatus projectStatus;
  final int rewardAmount;
  final String currency;
  final bool isPaid;
  final DateTime referredAt;

  const ReferralRewardModel({
    required this.id,
    required this.companyName,
    required this.projectName,
    required this.projectStatus,
    required this.rewardAmount,
    required this.currency,
    required this.isPaid,
    required this.referredAt,
  });

  factory ReferralRewardModel.fromJson(Map<String, dynamic> json) {
    return ReferralRewardModel(
      id: json['id'] as int,
      companyName: json['company_name'] as String,
      projectName: json['project_name'] as String,
      projectStatus: ProjectModel._parseStatus(json['project_status'] as String),
      rewardAmount: json['reward_amount'] as int,
      currency: json['currency'] as String? ?? 'INR',
      isPaid: json['is_paid'] as bool,
      referredAt: DateTime.parse(json['referred_at'] as String),
    );
  }
}

class ReferralSummary {
  final int totalEarned;
  final int totalPending;
  final int totalReferrals;
  final String referralCode;
  final List<ReferralRewardModel> referrals;

  const ReferralSummary({
    required this.totalEarned,
    required this.totalPending,
    required this.totalReferrals,
    required this.referralCode,
    required this.referrals,
  });

  factory ReferralSummary.fromJson(Map<String, dynamic> json) {
    return ReferralSummary(
      totalEarned: json['total_earned'] as int,
      totalPending: json['total_pending'] as int,
      totalReferrals: json['total_referrals'] as int,
      referralCode: json['referral_code'] as String,
      referrals: (json['referrals'] as List)
          .map((r) => ReferralRewardModel.fromJson(r as Map<String, dynamic>))
          .toList(),
    );
  }
}
