class GameModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String difficulty;
  final int maxScore;
  final int timeLimit; // in seconds
  final Map<String, dynamic> metadata;

  GameModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.difficulty,
    required this.maxScore,
    required this.timeLimit,
    this.metadata = const {},
  });

  factory GameModel.fromJson(Map<String, dynamic> json) {
    return GameModel(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      difficulty: json['difficulty'] ?? 'easy',
      maxScore: json['maxScore'] ?? 100,
      timeLimit: json['timeLimit'] ?? 300,
      metadata: json['metadata'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'difficulty': difficulty,
      'maxScore': maxScore,
      'timeLimit': timeLimit,
      'metadata': metadata,
    };
  }
}

