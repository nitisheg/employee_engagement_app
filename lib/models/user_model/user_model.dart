class UserModel {
  final String id;
  final String name;
  final String email;
  final String employeeId;
  final String department;
  final String role;
  final String? phone;
  final String? address;
  final String? designation;
  final String? avatar;
  final String? joiningDate;
  final String status;
  final String? lastCheckInDate;
  // Display-only fields (not from API, kept with defaults for UI)
  final int totalPoints;
  final int rank;
  final int currentStreak;
  final int longestStreak;
  final int streakDays;
  final String level;
  final int levelProgressPoints;
  final int levelTargetPoints;
  final List<String> badges;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.employeeId,
    required this.department,
    required this.role,
    this.phone,
    this.address,
    this.designation,
    this.avatar,
    this.joiningDate,
    this.status = 'active',
    this.lastCheckInDate,
    this.totalPoints = 0,
    this.rank = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.streakDays = 0,
    this.level = 'Beginner',
    this.levelProgressPoints = 0,
    this.levelTargetPoints = 500,
    this.badges = const [],
    required this.createdAt,
  });

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['_id'] ?? json['id'] ?? '') as String,
      name: (json['name'] ?? '') as String,
      email: (json['email'] ?? '') as String,
      // API returns snake_case from profile endpoint
      employeeId: (json['employee_id'] ?? json['employeeId'] ?? '') as String,
      department: (json['department'] ?? '') as String,
      role: (json['role'] ?? 'user') as String,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      designation: json['designation'] as String?,
      avatar: json['avatar'] as String?,
      joiningDate: (json['joining_date'] ?? json['joiningDate']) as String?,
      status: (json['status'] ?? 'active') as String,
      lastCheckInDate: json['lastCheckInDate'] as String?,
      totalPoints: (json['total_points'] ?? json['totalPoints'] ?? 0) as int,
      rank: (json['rank'] ?? 0) as int,
      currentStreak:
          (json['currentStreak'] ?? json['current_streak'] ?? 0) as int,
      longestStreak:
          (json['longestStreak'] ?? json['longest_streak'] ?? 0) as int,
      streakDays: (json['streakDays'] ?? json['streak_days'] ?? 0) as int,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'name': name,
    'email': email,
    'employeeId': employeeId,
    'department': department,
    'role': role,
    if (phone != null) 'phone': phone,
    if (address != null) 'address': address,
    if (designation != null) 'designation': designation,
    if (avatar != null) 'avatar': avatar,
    if (joiningDate != null) 'joiningDate': joiningDate,
    'status': status,
    if (lastCheckInDate != null) 'lastCheckInDate': lastCheckInDate,
    'total_points': totalPoints,
    'rank': rank,
    'currentStreak': currentStreak,
    'longestStreak': longestStreak,
    'streakDays': streakDays,
    'createdAt': createdAt.toIso8601String(),
  };

  UserModel copyWith({
    String? name,
    String? phone,
    String? address,
    String? designation,
    String? avatar,
    String? joiningDate,
    String? lastCheckInDate,
    int? totalPoints,
    int? rank,
    int? currentStreak,
    int? longestStreak,
    int? streakDays,
    String? level,
    int? levelProgressPoints,
    List<String>? badges,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email,
      employeeId: employeeId,
      department: department,
      role: role,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      designation: designation ?? this.designation,
      avatar: avatar ?? this.avatar,
      joiningDate: joiningDate ?? this.joiningDate,
      status: status,
      lastCheckInDate: lastCheckInDate ?? this.lastCheckInDate,
      totalPoints: totalPoints ?? this.totalPoints,
      rank: rank ?? this.rank,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      streakDays: streakDays ?? this.streakDays,
      level: level ?? this.level,
      levelProgressPoints: levelProgressPoints ?? this.levelProgressPoints,
      levelTargetPoints: levelTargetPoints,
      badges: badges ?? this.badges,
      createdAt: createdAt,
    );
  }
}

class LoginRequest {
  final String email;
  final String password;

  const LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}

class RegisterRequest {
  final String name;
  final String email;
  final String employeeId;
  final String department;

  final String password;

  const RegisterRequest({
    required this.name,
    required this.email,
    required this.employeeId,
    required this.department,

    required this.password,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'employeeId': employeeId,
    'department': department,

    'password': password,
  };
}

class AuthResponse {
  final String accessToken;
  final UserModel user;

  const AuthResponse({required this.accessToken, required this.user});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: (json['accessToken'] ?? json['token'] ?? '') as String,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}

