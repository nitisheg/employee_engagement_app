import 'package:employee_engagement_app/models/quiz_model.dart';

class DashboardModel {
  final DashboardUser user;
  final DashboardPoints points;
  final DashboardQuizzes quizzes;
  final List<dynamic> personality;

  DashboardModel({
    required this.user,
    required this.points,
    required this.quizzes,
    this.personality = const [],
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    final dashboard = json['dashboard'] as Map<String, dynamic>? ?? json;
    final userJson = dashboard['user'] as Map<String, dynamic>? ?? {};
    final pointsJson = dashboard['points'] as Map<String, dynamic>? ?? {};
    final quizzesJson = dashboard['quizzes'] as Map<String, dynamic>? ?? {};

    final activeList = (quizzesJson['active'] as List<dynamic>? ?? [])
        .map((item) => ActiveQuiz.fromJson(item as Map<String, dynamic>))
        .toList();

    final recentList = (quizzesJson['recent'] as List<dynamic>? ?? [])
        .map((item) => QuizMyResult.fromJson(item as Map<String, dynamic>))
        .toList();

    return DashboardModel(
      user: DashboardUser.fromJson(userJson),
      points: DashboardPoints.fromJson(pointsJson),
      quizzes: DashboardQuizzes(
        taken: (quizzesJson['taken'] ?? 0) as int,
        totalPossible: (quizzesJson['total_possible'] ?? 0) as int,
        totalActive: (quizzesJson['total_active'] ?? 0) as int,
        percentage: (quizzesJson['percentage'] ?? 0) as int,
        active: activeList,
        recent: recentList,
      ),
      personality: (dashboard['personality'] as List<dynamic>? ?? []),
    );
  }
}

class DashboardUser {
  final String name;
  final String avatar;
  final String initials;

  DashboardUser({
    required this.name,
    required this.avatar,
    required this.initials,
  });

  factory DashboardUser.fromJson(Map<String, dynamic> json) {
    return DashboardUser(
      name: (json['name'] ?? '') as String,
      avatar: (json['avatar'] ?? '') as String,
      initials: (json['initials'] ?? '') as String,
    );
  }
}

class DashboardPoints {
  final int total;
  final int today;
  final int rank;

  DashboardPoints({
    required this.total,
    required this.today,
    required this.rank,
  });

  factory DashboardPoints.fromJson(Map<String, dynamic> json) {
    return DashboardPoints(
      total: (json['total'] ?? 0) as int,
      today: (json['today'] ?? 0) as int,
      rank: (json['rank'] ?? 0) as int,
    );
  }
}

class DashboardQuizzes {
  final int taken;
  final int totalPossible;
  final int totalActive;
  final int percentage;
  final List<ActiveQuiz> active;
  final List<QuizMyResult> recent;

  DashboardQuizzes({
    required this.taken,
    required this.totalPossible,
    required this.totalActive,
    required this.percentage,
    this.active = const [],
    this.recent = const [],
  });
}
