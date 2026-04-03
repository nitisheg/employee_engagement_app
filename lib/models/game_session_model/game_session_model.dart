class GameSessionModel {
  final String id;
  final String gameId;
  final String userId;
  final DateTime startTime;
  final DateTime? endTime;
  final int? score;
  final Map<String, dynamic> metadata;
  final bool isCompleted;

  GameSessionModel({
    required this.id,
    required this.gameId,
    required this.userId,
    required this.startTime,
    this.endTime,
    this.score,
    this.metadata = const {},
    this.isCompleted = false,
  });

  factory GameSessionModel.fromJson(Map<String, dynamic> json) {
    return GameSessionModel(
      id: json['_id'] ?? json['id'] ?? '',
      gameId: json['gameId'] ?? '',
      userId: json['userId'] ?? '',
      startTime: DateTime.parse(
        json['startTime'] ?? DateTime.now().toIso8601String(),
      ),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      score: json['score'],
      metadata: json['metadata'] ?? {},
      isCompleted: json['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'gameId': gameId,
      'userId': userId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'score': score,
      'metadata': metadata,
      'isCompleted': isCompleted,
    };
  }
}

