enum AttendanceCheckStatus { present, absent, late }

class AttendanceSession {
  final DateTime checkIn;
  final DateTime? checkOut;

  const AttendanceSession({required this.checkIn, this.checkOut});

  factory AttendanceSession.fromJson(Map<String, dynamic> json) {
    return AttendanceSession(
      checkIn: DateTime.parse(json['check_in'] as String),
      checkOut: json['check_out'] != null
          ? DateTime.parse(json['check_out'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'check_in': checkIn.toIso8601String(),
    'check_out': checkOut?.toIso8601String(),
  };

  Duration get duration {
    if (checkOut == null) return Duration.zero;
    return checkOut!.difference(checkIn);
  }
}

class AttendanceRecord {
  final String date;
  final List<AttendanceSession> sessions;
  final int totalMinutes;

  const AttendanceRecord({
    required this.date,
    required this.sessions,
    required this.totalMinutes,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      date: json['date'] as String,
      sessions: (json['sessions'] as List<dynamic>? ?? [])
          .map((s) => AttendanceSession.fromJson(s as Map<String, dynamic>))
          .toList(),
      totalMinutes: json['total_minutes'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'date': date,
    'sessions': sessions.map((s) => s.toJson()).toList(),
    'total_minutes': totalMinutes,
  };

  bool get isCheckedIn => sessions.isNotEmpty && sessions.last.checkOut == null;
  Duration get totalDuration => Duration(minutes: totalMinutes);

  /// Calculate points earned based on total work duration
  /// 20 points for 8+ hours, 10 points for any work, 0 for no work
  int get pointsEarned {
    if (totalMinutes >= 480) {
      return 20;
    } else if (totalMinutes > 0) {
      return 10;
    } else {
      return 0;
    }
  }
}

class StreakInfo {
  final int current;
  final int longest;
  final String? warning;

  const StreakInfo({
    required this.current,
    required this.longest,
    this.warning,
  });

  factory StreakInfo.fromJson(Map<String, dynamic> json) {
    return StreakInfo(
      current: json['current'] as int? ?? 0,
      longest: json['longest'] as int? ?? 0,
      warning: json['warning'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'current': current,
    'longest': longest,
    if (warning != null) 'warning': warning,
  };
}

class AttendanceTodayStatus {
  final String date;
  final bool isCheckedIn;
  final List<AttendanceSession> sessions;
  final int totalMinutes;
  final StreakInfo streak;

  const AttendanceTodayStatus({
    required this.date,
    required this.isCheckedIn,
    required this.sessions,
    required this.totalMinutes,
    required this.streak,
  });

  factory AttendanceTodayStatus.fromJson(Map<String, dynamic> json) {
    return AttendanceTodayStatus(
      date: json['date'] as String,
      isCheckedIn: json['is_checked_in'] as bool? ?? false,
      sessions: (json['sessions'] as List<dynamic>? ?? [])
          .map((s) => AttendanceSession.fromJson(s as Map<String, dynamic>))
          .toList(),
      totalMinutes: json['total_minutes'] as int? ?? 0,
      streak: StreakInfo.fromJson(json['streak'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
    'date': date,
    'is_checked_in': isCheckedIn,
    'sessions': sessions.map((s) => s.toJson()).toList(),
    'total_minutes': totalMinutes,
    'streak': streak.toJson(),
  };
}

class AttendanceHistory {
  final int totalDays;
  final double totalHours;
  final List<AttendanceRecord> records;

  const AttendanceHistory({
    required this.totalDays,
    required this.totalHours,
    required this.records,
  });

  factory AttendanceHistory.fromJson(Map<String, dynamic> json) {
    final totalHoursValue = json['total_hours'];
    double totalHours;

    if (totalHoursValue == null) {
      totalHours = 0.0;
    } else if (totalHoursValue is int) {
      totalHours = totalHoursValue.toDouble();
    } else if (totalHoursValue is double) {
      totalHours = totalHoursValue;
    } else {
      totalHours = double.tryParse(totalHoursValue.toString()) ?? 0.0;
    }

    return AttendanceHistory(
      totalDays: json['total_days'] as int? ?? 0,
      totalHours: totalHours,
      records: (json['records'] as List<dynamic>? ?? [])
          .map((r) => AttendanceRecord.fromJson(r as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'total_days': totalDays,
    'total_hours': totalHours,
    'records': records.map((r) => r.toJson()).toList(),
  };
}

class CheckInResponse {
  final AttendanceRecord attendance;
  final StreakInfo streak;

  const CheckInResponse({required this.attendance, required this.streak});

  factory CheckInResponse.fromJson(Map<String, dynamic> json) {
    return CheckInResponse(
      attendance: AttendanceRecord.fromJson(
        json['attendance'] as Map<String, dynamic>,
      ),
      streak: StreakInfo.fromJson(json['streak'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
    'attendance': attendance.toJson(),
    'streak': streak.toJson(),
  };
}

class CheckOutResponse {
  final AttendanceRecord attendance;

  const CheckOutResponse({required this.attendance});

  factory CheckOutResponse.fromJson(Map<String, dynamic> json) {
    return CheckOutResponse(
      attendance: AttendanceRecord.fromJson(json),
    );
  }

  Map<String, dynamic> toJson() => attendance.toJson();
}

