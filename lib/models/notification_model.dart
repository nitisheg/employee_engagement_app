class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String message;
  final String type; // 'achievement', 'challenge', 'quiz', 'event', 'general'
  final String? relatedId; // ID of the related resource
  final String? relatedType; // Type of related resource
  final bool isRead;
  final DateTime createdAt;
  final DateTime? readAt;

  const NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    this.relatedId,
    this.relatedType,
    this.isRead = false,
    required this.createdAt,
    this.readAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: (json['_id'] ?? json['id'] ?? '') as String,
      userId: (json['userId'] ?? json['user_id'] ?? '') as String,
      title: (json['title'] ?? '') as String,
      message: (json['message'] ?? '') as String,
      type: (json['type'] ?? 'general') as String,
      relatedId: json['relatedId'] as String?,
      relatedType: json['relatedType'] as String?,
      isRead: (json['isRead'] ?? json['is_read'] ?? false) as bool,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      readAt: json['readAt'] != null
          ? DateTime.tryParse(json['readAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'userId': userId,
    'title': title,
    'message': message,
    'type': type,
    if (relatedId != null) 'relatedId': relatedId,
    if (relatedType != null) 'relatedType': relatedType,
    'isRead': isRead,
    'createdAt': createdAt.toIso8601String(),
    if (readAt != null) 'readAt': readAt!.toIso8601String(),
  };

  String get icon {
    switch (type.toLowerCase()) {
      case 'achievement':
        return '🏆';
      case 'challenge':
        return '⚡';
      case 'quiz':
        return '📝';
      case 'event':
        return '📅';
      default:
        return '📢';
    }
  }

  NotificationModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? message,
    String? type,
    String? relatedId,
    String? relatedType,
    bool? isRead,
    DateTime? createdAt,
    DateTime? readAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      relatedId: relatedId ?? this.relatedId,
      relatedType: relatedType ?? this.relatedType,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
    );
  }
}
