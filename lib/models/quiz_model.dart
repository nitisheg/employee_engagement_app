// Models matching the actual REST API response shapes.
// The server does NOT expose correct answers in attempt questions.

// ── Active quiz list ──────────────────────────────────────────────────────────

class ActiveQuiz {
  final String id;
  final String title;
  final String? description;
  final String? startDateTime;
  final String? endDateTime;
  final bool isLive;
  final bool submitted;
  final int totalQuestions;
  final int totalPoints;
  final int pointsEarned;
  final String? submittedAt;
  final int pointsPerQuestion;
  final bool isAttempted;

  const ActiveQuiz({
    required this.id,
    required this.title,
    this.description,
    this.startDateTime,
    this.endDateTime,
    this.isLive = false,
    this.submitted = false,
    required this.totalQuestions,
    this.totalPoints = 0,
    this.pointsEarned = 0,
    this.submittedAt,
    required this.pointsPerQuestion,
    required this.isAttempted,
  });

  factory ActiveQuiz.fromJson(Map<String, dynamic> json) {
    return ActiveQuiz(
      id: (json['_id'] ?? json['id'] ?? '') as String,
      title: (json['title'] ?? '') as String,
      description: json['description'] as String?,
      startDateTime: json['start_datetime'] as String?,
      endDateTime: json['end_datetime'] as String?,
      isLive: (json['is_live'] ?? false) as bool,
      submitted: (json['submitted'] ?? false) as bool,
      totalQuestions:
          (json['total_questions'] ?? json['totalQuestions'] ?? 0) as int,
      totalPoints:
          (json['total_points'] ?? json['pointsPerQuestion'] ?? 20) as int,
      pointsEarned: (json['points_earned'] ?? 0) as int,
      submittedAt: json['submitted_at'] as String?,
      pointsPerQuestion: (json['pointsPerQuestion'] ?? 20) as int,
      isAttempted: (json['isAttempted'] ?? false) as bool,
    );
  }
}

// ── Quiz attempt (question list from server) ──────────────────────────────────

class QuizAttemptQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int? timeLimitSeconds;

  const QuizAttemptQuestion({
    required this.id,
    required this.question,
    required this.options,
    this.timeLimitSeconds,
  });

  factory QuizAttemptQuestion.fromJson(Map<String, dynamic> json) {
    final options = <String>[];

    if (json['options'] is List) {
      options.addAll(List<String>.from(json['options'] as List));
    } else {
      if ((json['option_a'] ?? json['optionA']) != null) {
        options.add((json['option_a'] ?? json['optionA']) as String);
      }
      if ((json['option_b'] ?? json['optionB']) != null) {
        options.add((json['option_b'] ?? json['optionB']) as String);
      }
      if ((json['option_c'] ?? json['optionC']) != null) {
        options.add((json['option_c'] ?? json['optionC']) as String);
      }
      if ((json['option_d'] ?? json['optionD']) != null) {
        options.add((json['option_d'] ?? json['optionD']) as String);
      }
    }

    return QuizAttemptQuestion(
      id: (json['_id'] ?? json['id'] ?? '') as String,
      question: (json['question_text'] ?? json['question'] ?? '') as String,
      options: options,
      timeLimitSeconds: json['timeLimitSeconds'] as int?,
    );
  }
}

class QuizAttemptData {
  final String quizId;
  final String title;
  final List<QuizAttemptQuestion> questions;
  final int page;
  final int totalPages;
  final int totalQuestions;

  const QuizAttemptData({
    required this.quizId,
    required this.title,
    required this.questions,
    required this.page,
    required this.totalPages,
    required this.totalQuestions,
  });

  factory QuizAttemptData.fromJson(Map<String, dynamic> json) {
    final quizSection = json['quiz'] as Map<String, dynamic>?;
    final safeJson = quizSection ?? json;

    final questionList = (safeJson['questions'] as List? ?? [])
        .map((q) => QuizAttemptQuestion.fromJson(q as Map<String, dynamic>))
        .toList();

    return QuizAttemptData(
      quizId:
          (safeJson['quizId'] ?? safeJson['_id'] ?? safeJson['id'] ?? '')
              as String,
      title: (safeJson['title'] ?? '') as String,
      questions: questionList,
      page: (json['page'] ?? json['pagination']?['page'] ?? 1) as int,
      totalPages:
          (json['totalPages'] ?? json['pagination']?['totalPages'] ?? 1) as int,
      totalQuestions:
          (json['total'] ?? json['pagination']?['total'] ?? questionList.length)
              as int,
    );
  }
}

// ── Answer tracking (client-side) ────────────────────────────────────────────

class QuizAnswer {
  final String questionId;
  final int selectedOption;

  const QuizAnswer({required this.questionId, required this.selectedOption});

  Map<String, dynamic> toJson() => {
    'question_id': questionId,
    'selected_option': selectedOption,
  };
}

// ── Submit result ─────────────────────────────────────────────────────────────

class QuizAnswerResult {
  final String questionId;
  final bool isCorrect;
  final int? correctOption;

  const QuizAnswerResult({
    required this.questionId,
    required this.isCorrect,
    this.correctOption,
  });

  factory QuizAnswerResult.fromJson(Map<String, dynamic> json) {
    return QuizAnswerResult(
      questionId: (json['question_id'] ?? json['questionId'] ?? '') as String,
      isCorrect: (json['is_correct'] ?? json['isCorrect'] ?? false) as bool,
      correctOption: json['correct_option'] as int?,
    );
  }
}

class QuizSubmitResult {
  final int correctAnswers;
  final int totalQuestions;
  final int scoredPoints;
  final int pointsEarned;
  final List<QuizAnswerResult> results;

  const QuizSubmitResult({
    required this.correctAnswers,
    required this.totalQuestions,
    required this.scoredPoints,
    required this.pointsEarned,
    required this.results,
  });

  double get percentage =>
      totalQuestions > 0 ? correctAnswers / totalQuestions : 0;

  factory QuizSubmitResult.fromJson(Map<String, dynamic> json) {
    final correctAnswers =
        (json['correctAnswers'] ??
                json['correct_answers'] ??
                json['score'] ??
                0)
            as int;
    final totalQuestions =
        (json['totalQuestions'] ??
                json['total_questions'] ??
                json['total'] ??
                0)
            as int;
    final scoredPoints =
        (json['scored_points'] ??
                json['score'] ??
                json['total_points'] ??
                correctAnswers)
            as int;
    final pointsEarned =
        (json['pointsEarned'] ??
                json['points_earned'] ??
                json['total_points'] ??
                0)
            as int;

    return QuizSubmitResult(
      correctAnswers: correctAnswers,
      totalQuestions: totalQuestions,
      scoredPoints: scoredPoints,
      pointsEarned: pointsEarned,
      results: (json['results'] as List? ?? [])
          .map((r) => QuizAnswerResult.fromJson(r as Map<String, dynamic>))
          .toList(),
    );
  }
}

// ── My results history ────────────────────────────────────────────────────────

class QuizMyResult {
  final String id;
  final String quizTitle;
  final int correctAnswers;
  final int totalQuestions;
  final int scoredPoints;
  final int pointsEarned;
  final DateTime submittedAt;

  const QuizMyResult({
    required this.id,
    required this.quizTitle,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.scoredPoints,
    required this.pointsEarned,
    required this.submittedAt,
  });

  double get percentage =>
      totalQuestions > 0 ? correctAnswers / totalQuestions : 0;

  factory QuizMyResult.fromJson(Map<String, dynamic> json) {
    return QuizMyResult(
      id: (json['_id'] ?? json['id'] ?? '') as String,
      quizTitle: (json['quizTitle'] ?? json['quiz_title'] ?? '') as String,
      correctAnswers:
          (json['correctAnswers'] ??
                  json['correct_answers'] ??
                  json['score'] ??
                  0)
              as int,
      totalQuestions:
          (json['totalQuestions'] ??
                  json['total_questions'] ??
                  json['total_questions'] ??
                  json['total'] ??
                  0)
              as int,
      scoredPoints: (json['scored_points'] ?? json['score'] ?? 0) as int,
      pointsEarned:
          (json['pointsEarned'] ??
                  json['points_earned'] ??
                  json['total_points'] ??
                  0)
              as int,
      submittedAt: json['submittedAt'] != null
          ? DateTime.tryParse(json['submittedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

// ── Legacy local-only models (kept for quiz_screen.dart offline mode) ─────────

class QuizQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int? correctIndex; // null when coming from real API
  final int pointsPerQuestion;
  final int timeLimitSeconds;

  const QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    this.correctIndex,
    this.pointsPerQuestion = 20,
    this.timeLimitSeconds = 30,
  });

  factory QuizQuestion.fromAttemptQuestion(QuizAttemptQuestion q) {
    return QuizQuestion(
      id: q.id,
      question: q.question,
      options: q.options,
      correctIndex: null,
      timeLimitSeconds: q.timeLimitSeconds ?? 30,
    );
  }
}
