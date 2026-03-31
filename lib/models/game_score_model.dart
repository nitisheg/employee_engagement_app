enum GameType { quiz, sudoku, zipGame }

enum SudokuDifficulty { easy, medium, hard }

class GameScoreModel {
  final int id;
  final GameType gameType;
  final int pointsEarned;
  final int timeTakenSeconds;
  final Map<String, dynamic> metadata;
  final DateTime playedAt;

  const GameScoreModel({
    required this.id,
    required this.gameType,
    required this.pointsEarned,
    required this.timeTakenSeconds,
    required this.metadata,
    required this.playedAt,
  });

  factory GameScoreModel.fromJson(Map<String, dynamic> json) {
    return GameScoreModel(
      id: json['id'] as int,
      gameType: _parseGameType(json['game_type'] as String),
      pointsEarned: json['points_earned'] as int,
      timeTakenSeconds: json['time_taken_seconds'] as int,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
      playedAt: DateTime.parse(json['played_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'game_type': gameType.name,
        'points_earned': pointsEarned,
        'time_taken_seconds': timeTakenSeconds,
        'metadata': metadata,
        'played_at': playedAt.toIso8601String(),
      };

  static GameType _parseGameType(String s) {
    switch (s) {
      case 'sudoku':
        return GameType.sudoku;
      case 'zip_game':
        return GameType.zipGame;
      default:
        return GameType.quiz;
    }
  }
}

class SudokuSubmission {
  final SudokuDifficulty difficulty;
  final int timeTakenSeconds;
  final bool isCompleted;
  final List<List<int>> finalGrid;

  const SudokuSubmission({
    required this.difficulty,
    required this.timeTakenSeconds,
    required this.isCompleted,
    required this.finalGrid,
  });

  Map<String, dynamic> toJson() => {
        'difficulty': difficulty.name,
        'time_taken_seconds': timeTakenSeconds,
        'is_completed': isCompleted,
        'final_grid': finalGrid,
      };

  /// Points formula: base × difficulty multiplier ÷ time factor
  int get calculatedPoints {
    if (!isCompleted) return 0;
    final base = switch (difficulty) {
      SudokuDifficulty.easy => 50,
      SudokuDifficulty.medium => 100,
      SudokuDifficulty.hard => 200,
    };
    // Bonus for fast completion: full bonus under 3 min, half bonus 3–6 min
    if (timeTakenSeconds < 180) return base;
    if (timeTakenSeconds < 360) return (base * 0.75).toInt();
    return (base * 0.5).toInt();
  }
}

class ActivityFeedItem {
  final int id;
  final String title;
  final String subtitle;
  final String iconName;
  final String colorHex;
  final int pointsDelta;
  final DateTime occurredAt;

  const ActivityFeedItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.iconName,
    required this.colorHex,
    required this.pointsDelta,
    required this.occurredAt,
  });

  factory ActivityFeedItem.fromJson(Map<String, dynamic> json) {
    return ActivityFeedItem(
      id: json['id'] as int,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      iconName: json['icon_name'] as String,
      colorHex: json['color_hex'] as String? ?? '#E53935',
      pointsDelta: json['points_delta'] as int,
      occurredAt: DateTime.parse(json['occurred_at'] as String),
    );
  }
}
