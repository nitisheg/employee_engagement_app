class PsychometricTest {
  final String id;
  final String title;
  final String? description;
  final bool completed;
  final String? personalityType;
  final DateTime? submittedAt;

  const PsychometricTest({
    required this.id,
    required this.title,
    this.description,
    required this.completed,
    this.personalityType,
    this.submittedAt,
  });

  factory PsychometricTest.fromJson(Map<String, dynamic> json) {
    return PsychometricTest(
      id: json['_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      completed: json['completed'] as bool? ?? false,
      personalityType: json['personality_type'] as String?,
      submittedAt: json['submitted_at'] != null
          ? DateTime.tryParse(json['submitted_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'title': title,
    'description': description,
    'completed': completed,
    'personality_type': personalityType,
    'submitted_at': submittedAt?.toIso8601String(),
  };
}

class ScaleOption {
  final int value;
  final String label;

  const ScaleOption({required this.value, required this.label});

  factory ScaleOption.fromJson(Map<String, dynamic> json) {
    return ScaleOption(
      value: json['value'] as int,
      label: json['label'] as String,
    );
  }

  Map<String, dynamic> toJson() => {'value': value, 'label': label};
}

class TestStatement {
  final String id;
  final String statementText;

  const TestStatement({required this.id, required this.statementText});

  factory TestStatement.fromJson(Map<String, dynamic> json) {
    return TestStatement(
      id: json['_id'] as String,
      statementText: json['statement_text'] as String,
    );
  }

  Map<String, dynamic> toJson() => {'_id': id, 'statement_text': statementText};
}

class TestAttempt {
  final PsychometricTest test;
  final List<TestStatement> statements;
  final int total;
  final List<ScaleOption> scale;

  const TestAttempt({
    required this.test,
    required this.statements,
    required this.total,
    required this.scale,
  });

  factory TestAttempt.fromJson(Map<String, dynamic> json) {
    final testData = json['test'] as Map<String, dynamic>;
    final test = PsychometricTest(
      id: testData['_id'] as String,
      title: testData['title'] as String,
      description: testData['description'] as String?,
      completed: false,
    );

    return TestAttempt(
      test: test,
      statements: (json['statements'] as List<dynamic>)
          .map((s) => TestStatement.fromJson(s as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int,
      scale: (json['scale'] as List<dynamic>)
          .map((s) => ScaleOption.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'test': test.toJson(),
    'statements': statements.map((s) => s.toJson()).toList(),
    'total': total,
    'scale': scale.map((s) => s.toJson()).toList(),
  };
}
