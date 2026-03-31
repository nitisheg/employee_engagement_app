enum AttendanceCheckStatus { present, absent, late }

class AttendanceRecord {
  final int id;
  final DateTime date;
  final DateTime? checkInTime;
  final AttendanceCheckStatus status;
  final int pointsEarned;

  const AttendanceRecord({
    required this.id,
    required this.date,
    this.checkInTime,
    required this.status,
    required this.pointsEarned,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      id: json['id'] as int,
      date: DateTime.parse(json['date'] as String),
      checkInTime: json['check_in_time'] != null
          ? DateTime.parse(json['check_in_time'] as String)
          : null,
      status: _parseStatus(json['status'] as String),
      pointsEarned: json['points_earned'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'check_in_time': checkInTime?.toIso8601String(),
        'status': status.name,
        'points_earned': pointsEarned,
      };

  static AttendanceCheckStatus _parseStatus(String s) {
    switch (s) {
      case 'present':
        return AttendanceCheckStatus.present;
      case 'late':
        return AttendanceCheckStatus.late;
      default:
        return AttendanceCheckStatus.absent;
    }
  }
}

class AttendanceSummary {
  final int presentDays;
  final int absentDays;
  final int lateDays;
  final int currentStreak;
  final int bestStreak;
  final int totalPointsEarned;
  final List<AttendanceRecord> recentRecords;

  const AttendanceSummary({
    required this.presentDays,
    required this.absentDays,
    required this.lateDays,
    required this.currentStreak,
    required this.bestStreak,
    required this.totalPointsEarned,
    required this.recentRecords,
  });

  factory AttendanceSummary.fromJson(Map<String, dynamic> json) {
    return AttendanceSummary(
      presentDays: json['present_days'] as int,
      absentDays: json['absent_days'] as int,
      lateDays: json['late_days'] as int,
      currentStreak: json['current_streak'] as int,
      bestStreak: json['best_streak'] as int,
      totalPointsEarned: json['total_points_earned'] as int,
      recentRecords: (json['recent_records'] as List)
          .map((r) => AttendanceRecord.fromJson(r as Map<String, dynamic>))
          .toList(),
    );
  }
}

class CheckInRequest {
  final DateTime checkInTime;

  const CheckInRequest({required this.checkInTime});

  Map<String, dynamic> toJson() => {
        'check_in_time': checkInTime.toIso8601String(),
      };
}

class CheckInResponse {
  final AttendanceRecord record;
  final int pointsEarned;
  final int newStreak;
  final String message;

  const CheckInResponse({
    required this.record,
    required this.pointsEarned,
    required this.newStreak,
    required this.message,
  });

  factory CheckInResponse.fromJson(Map<String, dynamic> json) {
    return CheckInResponse(
      record: AttendanceRecord.fromJson(
          json['record'] as Map<String, dynamic>),
      pointsEarned: json['points_earned'] as int,
      newStreak: json['new_streak'] as int,
      message: json['message'] as String,
    );
  }
}
