// Models matching the actual REST API response shapes.
// The server does NOT expose correct answers in attempt questions.

// ── Active quiz list ──────────────────────────────────────────────────────────

class ActiveQuiz {
  final String id;
  final String title;
  final String? description;
  final int totalQuestions;
  final int pointsPerQuestion;
  final bool isAttempted;

  const ActiveQuiz({
    required this.id,
    required this.title,
    this.description,
    required this.totalQuestions,
    required this.pointsPerQuestion,
    required this.isAttempted,
  });

  factory ActiveQuiz.fromJson(Map<String, dynamic> json) {
    return ActiveQuiz(
      id: (json['_id'] ?? json['id'] ?? '') as String,
      title: (json['title'] ?? '') as String,
      description: json['description'] as String?,
      totalQuestions: (json['totalQuestions'] ?? 0) as int,
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
    return QuizAttemptQuestion(
      id: (json['_id'] ?? json['id'] ?? '') as String,
      question: (json['question'] ?? '') as String,
      options: List<String>.from(json['options'] as List? ?? []),
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

  const QuizAttemptData({
    required this.quizId,
    required this.title,
    required this.questions,
    required this.page,
    required this.totalPages,
  });

  factory QuizAttemptData.fromJson(Map<String, dynamic> json) {
    return QuizAttemptData(
      quizId: (json['quizId'] ?? '') as String,
      title: (json['title'] ?? '') as String,
      questions: (json['questions'] as List? ?? [])
          .map((q) => QuizAttemptQuestion.fromJson(q as Map<String, dynamic>))
          .toList(),
      page: (json['page'] ?? 1) as int,
      totalPages: (json['totalPages'] ?? 1) as int,
    );
  }
}

// ── Answer tracking (client-side) ────────────────────────────────────────────

class QuizAnswer {
  final String questionId;
  final int selectedOption;

  const QuizAnswer({
    required this.questionId,
    required this.selectedOption,
  });

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
  final int pointsEarned;
  final List<QuizAnswerResult> results;

  const QuizSubmitResult({
    required this.correctAnswers,
    required this.totalQuestions,
    required this.pointsEarned,
    required this.results,
  });

  double get percentage =>
      totalQuestions > 0 ? correctAnswers / totalQuestions : 0;

  factory QuizSubmitResult.fromJson(Map<String, dynamic> json) {
    return QuizSubmitResult(
      correctAnswers: (json['correctAnswers'] ?? json['correct_answers'] ?? 0) as int,
      totalQuestions: (json['totalQuestions'] ?? json['total_questions'] ?? 0) as int,
      pointsEarned: (json['pointsEarned'] ?? json['points_earned'] ?? 0) as int,
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
  final int pointsEarned;
  final DateTime submittedAt;

  const QuizMyResult({
    required this.id,
    required this.quizTitle,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.pointsEarned,
    required this.submittedAt,
  });

  double get percentage =>
      totalQuestions > 0 ? correctAnswers / totalQuestions : 0;

  factory QuizMyResult.fromJson(Map<String, dynamic> json) {
    return QuizMyResult(
      id: (json['_id'] ?? json['id'] ?? '') as String,
      quizTitle: (json['quizTitle'] ?? json['quiz_title'] ?? '') as String,
      correctAnswers: (json['correctAnswers'] ?? json['correct_answers'] ?? 0) as int,
      totalQuestions: (json['totalQuestions'] ?? json['total_questions'] ?? 0) as int,
      pointsEarned: (json['pointsEarned'] ?? json['points_earned'] ?? 0) as int,
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
