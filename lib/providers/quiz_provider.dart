import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../models/quiz_model.dart';
import '../services/api_service.dart';

class QuizProvider extends ChangeNotifier {
  final QuizApiService _quizApi = QuizApiService();

  // Active quiz list
  List<ActiveQuiz> _activeQuizzes = [];
  bool _loadingQuizzes = false;

  // Current attempt
  QuizAttemptData? _currentAttempt;
  bool _loadingAttempt = false;

  // Answers collected client-side
  final List<QuizAnswer> _answers = [];

  // Submit result
  QuizSubmitResult? _lastResult;
  bool _submitting = false;

  // My results history
  List<QuizMyResult> _myResults = [];
  bool _loadingResults = false;

  String? _errorMessage;

  // ── Getters ──────────────────────────────────────────────────────────────────

  List<ActiveQuiz> get activeQuizzes => _activeQuizzes;
  bool get loadingQuizzes => _loadingQuizzes;

  QuizAttemptData? get currentAttempt => _currentAttempt;
  bool get loadingAttempt => _loadingAttempt;

  List<QuizAnswer> get answers => List.unmodifiable(_answers);

  QuizSubmitResult? get lastResult => _lastResult;
  bool get submitting => _submitting;

  List<QuizMyResult> get myResults => _myResults;
  bool get loadingResults => _loadingResults;

  String? get errorMessage => _errorMessage;

  // ── Actions ──────────────────────────────────────────────────────────────────

  Future<void> fetchActiveQuizzes() async {
    _loadingQuizzes = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final list = await _quizApi.getActiveQuizzes();
      _activeQuizzes = list
          .map((q) => ActiveQuiz.fromJson(q as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      _errorMessage = ApiException.fromDioException(e);
    } catch (e) {
      _errorMessage = e.toString();
    }
    _loadingQuizzes = false;
    notifyListeners();
  }

  Future<bool> startAttempt(
    String quizId, {
    int page = 1,
    int limit = 10,
  }) async {
    _loadingAttempt = true;
    _errorMessage = null;
    _lastResult = null;
    notifyListeners();
    try {
      final data = await _quizApi.getQuizAttempt(
        quizId,
        page: page,
        limit: limit,
      );
      _currentAttempt = QuizAttemptData.fromJson(data);
      _loadingAttempt = false;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _errorMessage = ApiException.fromDioException(e);
      _loadingAttempt = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _loadingAttempt = false;
      notifyListeners();
      return false;
    }
  }

  void selectAnswer(String questionId, int selectedOption) {
    final idx = _answers.indexWhere((a) => a.questionId == questionId);
    if (idx >= 0) {
      _answers[idx] = QuizAnswer(
        questionId: questionId,
        selectedOption: selectedOption,
      );
    } else {
      _answers.add(
        QuizAnswer(questionId: questionId, selectedOption: selectedOption),
      );
    }
    notifyListeners();
  }

  int? getSelectedAnswer(String questionId) {
    try {
      return _answers
          .firstWhere((a) => a.questionId == questionId)
          .selectedOption;
    } catch (_) {
      return null;
    }
  }

  Future<bool> submitQuiz(String quizId) async {
    _submitting = true;
    _errorMessage = null;
    notifyListeners();

    // Build submit payload using selected option text (expected by API)
    final attempt = _currentAttempt;
    final payloadAnswers = <Map<String, dynamic>>[];
    if (attempt != null) {
      for (final answer in _answers) {
        final question = attempt.questions.firstWhere(
          (q) => q.id == answer.questionId,
          orElse: () => QuizAttemptQuestion(
            id: answer.questionId,
            question: '',
            options: [],
          ),
        );

        String selectedOption = answer.selectedOption.toString();
        if (answer.selectedOption >= 0 &&
            answer.selectedOption < question.options.length) {
          selectedOption = question.options[answer.selectedOption];
        }

        payloadAnswers.add({
          'question_id': answer.questionId,
          'selected_option': selectedOption,
        });
      }
    } else {
      payloadAnswers.addAll(_answers.map((a) => a.toJson()));
    }

    try {
      final data = await _quizApi.submitQuiz(quizId, payloadAnswers);
      final resultJson = data['result'] as Map<String, dynamic>? ?? data;
      _lastResult = QuizSubmitResult.fromJson(resultJson);
      _submitting = false;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _errorMessage = ApiException.fromDioException(e);
      _submitting = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _submitting = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchMyResults() async {
    _loadingResults = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final list = await _quizApi.getMyResults();
      _myResults = list
          .map((r) => QuizMyResult.fromJson(r as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      _errorMessage = ApiException.fromDioException(e);
    } catch (e) {
      _errorMessage = e.toString();
    }
    _loadingResults = false;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void resetAttempt() {
    _currentAttempt = null;
    _answers.clear();
    _lastResult = null;
    notifyListeners();
  }
}
