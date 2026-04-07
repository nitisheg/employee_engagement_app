import 'package:employee_engagement_app/models/psychometric_model/psychometric_test.dart';

class PersonalityDimension {
  final int first;
  final int second;

  const PersonalityDimension({required this.first, required this.second});

  factory PersonalityDimension.fromJson(Map<String, dynamic> json) {
    return PersonalityDimension(
      first: json['first'] as int? ?? 0,
      second: json['second'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {'first': first, 'second': second};

  int get total => first + second;
  double get firstPercentage =>
      total > 0 ? (first / total * 100).roundToDouble() : 0;
  double get secondPercentage =>
      total > 0 ? (second / total * 100).roundToDouble() : 0;
}

class PersonalityProfile {
  final PersonalityDimension ei;
  final PersonalityDimension sn;
  final PersonalityDimension tf;
  final PersonalityDimension jp;

  const PersonalityProfile({
    required this.ei,
    required this.sn,
    required this.tf,
    required this.jp,
  });

  factory PersonalityProfile.fromJson(Map<String, dynamic> json) {
    return PersonalityProfile(
      ei: PersonalityDimension.fromJson(
        json['EI'] as Map<String, dynamic>? ?? {},
      ),
      sn: PersonalityDimension.fromJson(
        json['SN'] as Map<String, dynamic>? ?? {},
      ),
      tf: PersonalityDimension.fromJson(
        json['TF'] as Map<String, dynamic>? ?? {},
      ),
      jp: PersonalityDimension.fromJson(
        json['JP'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'EI': ei.toJson(),
    'SN': sn.toJson(),
    'TF': tf.toJson(),
    'JP': jp.toJson(),
  };
}

class PsychometricResult {
  final String id;
  final PsychometricTest test;
  final PersonalityProfile profile;
  final String personalityType;
  final DateTime submittedAt;

  const PsychometricResult({
    required this.id,
    required this.test,
    required this.profile,
    required this.personalityType,
    required this.submittedAt,
  });

  factory PsychometricResult.fromJson(Map<String, dynamic> json) {
    final testData = json['test'] as Map<String, dynamic>;
    final test = PsychometricTest(
      id: testData['_id'] as String,
      title: testData['title'] as String,
      description: testData['description'] as String?,
      completed: true,
      personalityType: json['personality_type'] as String,
      submittedAt: json['submitted_at'] != null
          ? DateTime.tryParse(json['submitted_at'] as String)
          : null,
    );

    return PsychometricResult(
      id: json['_id'] as String,
      test: test,
      profile: PersonalityProfile.fromJson(
        json['profile'] as Map<String, dynamic>? ?? {},
      ),
      personalityType: json['personality_type'] as String,
      submittedAt:
          DateTime.tryParse(json['submitted_at'] as String) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'test': test.toJson(),
    'profile': profile.toJson(),
    'personality_type': personalityType,
    'submitted_at': submittedAt.toIso8601String(),
  };
}

class TestResponse {
  final String statement;
  final int value;

  const TestResponse({required this.statement, required this.value});

  factory TestResponse.fromJson(Map<String, dynamic> json) {
    return TestResponse(
      statement: json['statement'] as String,
      value: json['value'] as int,
    );
  }

  Map<String, dynamic> toJson() => {'statement': statement, 'value': value};
}
