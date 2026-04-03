import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../models/quiz_model.dart';
import '../services/api_service.dart';
import '../core/utils/app_logger.dart';

class QuizProvider extends ChangeNotifier {
  static const _tag = 'QuizProvider';

  final QuizApiService _quizApi = QuizApiService();

  // Active quiz list
  List<ActiveQuiz> _activeQuizzes = [];
  bool _loadingQuizzes = false;
  bool _loadingMoreQuizzes = false;
  int _quizzesPage = 2;
  int _quizzesLimit = 20;
  bool _hasMoreQuizzes = true;
  String _activeFilter = 'all';

  // Current attempt
  QuizAttemptData? _currentAttempt;
  bool _loadingAttempt = false;
  bool _loadingMoreAttempt = false;

  // Answers collected client-side
  final List<QuizAnswer> _answers = [];

  // Submit result
  QuizSubmitResult? _lastResult;
  bool _submitting = false;

  // My results history
  List<QuizMyResult> _myResults = [];
  bool _loadingResults = false;
  bool _loadingMoreResults = false;
  int _resultsPage = 2;
  int _resultsLimit = 20;
  bool _hasMoreResults = true;

  String? _errorMessage;

  // ── Getters ──────────────────────────────────────────────────────────────────

  List<ActiveQuiz> get activeQuizzes => _activeQuizzes;
  bool get loadingQuizzes => _loadingQuizzes;
  bool get loadingMoreQuizzes => _loadingMoreQuizzes;
  bool get hasMoreQuizzes => _hasMoreQuizzes;
  String get activeFilter => _activeFilter;

  QuizAttemptData? get currentAttempt => _currentAttempt;
  bool get loadingAttempt => _loadingAttempt;
  bool get loadingMoreAttempt => _loadingMoreAttempt;
  bool get hasMoreAttemptQuestions {
    final attempt = _currentAttempt;
    if (attempt == null) return false;
    return attempt.hasNextPage || attempt.page < attempt.totalPages;
  }

  List<QuizAnswer> get answers => List.unmodifiable(_answers);

  QuizSubmitResult? get lastResult => _lastResult;
  bool get submitting => _submitting;

  List<QuizMyResult> get myResults => _myResults;
  bool get loadingResults => _loadingResults;
  bool get loadingMoreResults => _loadingMoreResults;
  bool get hasMoreResults => _hasMoreResults;

  String? get errorMessage => _errorMessage;

  // ── Actions ──────────────────────────────────────────────────────────────────

  Future<void> fetchActiveQuizzes({
    String filter = 'all',
    int page = 1,
    int limit = 20,
    bool refresh = false,
  }) async {
    AppLogger.info(_tag, 'fetchActiveQuizzes called');
    final isFirstPage = page <= 1 || refresh || filter != _activeFilter;

    if (isFirstPage) {
      _loadingQuizzes = true;
      _activeFilter = filter;
      _quizzesPage = 1;
      _quizzesLimit = limit;
      _hasMoreQuizzes = true;
    } else {
      _loadingMoreQuizzes = true;
    }

    _errorMessage = null;
    notifyListeners();
    try {
      final response = await _quizApi.getActiveQuizzes(
        filter: filter,
        page: page,
        limit: limit,
      );
      final rawList =
          response['quizzes'] as List<dynamic>? ??
          response['data'] as List<dynamic>? ??
          [];
      final quizzes = rawList
          .map((q) => ActiveQuiz.fromJson(q as Map<String, dynamic>))
          .toList();

      if (isFirstPage) {
        _activeQuizzes = quizzes;
      } else {
        final existingIds = _activeQuizzes.map((q) => q.id).toSet();
        final newItems = quizzes
            .where((q) => !existingIds.contains(q.id))
            .toList();
        _activeQuizzes.addAll(newItems);
      }

      _quizzesPage = page;
      final pagination = response['pagination'] as Map<String, dynamic>?;
      if (pagination != null) {
        _hasMoreQuizzes =
            pagination['hasNextPage'] as bool? ??
            (page < (pagination['totalPages'] as int? ?? 1));
      } else {
        _hasMoreQuizzes = quizzes.length >= limit;
      }
      AppLogger.success(_tag, 'fetchActiveQuizzes succeeded');
    } on DioException catch (e) {
      _errorMessage = ApiException.fromDioException(e);
      AppLogger.error(_tag, 'fetchActiveQuizzes DioException', e);
    } catch (e) {
      _errorMessage = e.toString();
      AppLogger.error(_tag, 'fetchActiveQuizzes error', e);
    }

    if (isFirstPage) {
      _loadingQuizzes = false;
    }
    _loadingMoreQuizzes = false;
    notifyListeners();
  }

  Future<void> loadMoreActiveQuizzes() async {
    if (_loadingQuizzes || _loadingMoreQuizzes || !_hasMoreQuizzes) {
      return;
    }
    await fetchActiveQuizzes(
      filter: _activeFilter,
      page: _quizzesPage + 1,
      limit: _quizzesLimit,
    );
  }

  Future<bool> startAttempt(
    String quizId, {
    int page = 1,
    int limit = 20,
  }) async {
    AppLogger.info(_tag, 'startAttempt called');
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
      AppLogger.success(_tag, 'startAttempt succeeded');
      _loadingAttempt = false;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _errorMessage = ApiException.fromDioException(e);
      AppLogger.error(_tag, 'startAttempt DioException', e);
      _loadingAttempt = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      AppLogger.error(_tag, 'startAttempt error', e);
      _loadingAttempt = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> loadMoreAttemptQuestions(
    String quizId, {
    int limit = 10,
  }) async {
    final attempt = _currentAttempt;
    if (attempt == null) return false;
    if (_loadingAttempt || _loadingMoreAttempt || !hasMoreAttemptQuestions) {
      return false;
    }

    final nextPage = attempt.page + 1;
    _loadingMoreAttempt = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _quizApi.getQuizAttempt(
        quizId,
        page: nextPage,
        limit: limit,
      );
      final nextAttempt = QuizAttemptData.fromJson(data);

      final mergedQuestions = <QuizAttemptQuestion>[
        ...attempt.questions,
        ...nextAttempt.questions.where(
          (q) => !attempt.questions.any((existing) => existing.id == q.id),
        ),
      ];

      _currentAttempt = QuizAttemptData(
        quizId: attempt.quizId,
        title: attempt.title,
        questions: mergedQuestions,
        page: nextAttempt.page,
        totalPages: nextAttempt.totalPages,
        totalQuestions: nextAttempt.totalQuestions,
        limit: nextAttempt.limit,
        hasNextPage: nextAttempt.hasNextPage,
        hasPrevPage: nextAttempt.hasPrevPage,
        alreadySubmitted: nextAttempt.alreadySubmitted,
      );

      AppLogger.success(_tag, 'loadMoreAttemptQuestions succeeded');
      _loadingMoreAttempt = false;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _errorMessage = ApiException.fromDioException(e);
      AppLogger.error(_tag, 'loadMoreAttemptQuestions DioException', e);
      _loadingMoreAttempt = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      AppLogger.error(_tag, 'loadMoreAttemptQuestions error', e);
      _loadingMoreAttempt = false;
      notifyListeners();
      return false;
    }
  }

  void selectAnswer(String questionId, int selectedOption) {
    AppLogger.info(_tag, 'selectAnswer called');
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
    AppLogger.info(_tag, 'getSelectedAnswer called');
    try {
      return _answers
          .firstWhere((a) => a.questionId == questionId)
          .selectedOption;
    } catch (_) {
      return null;
    }
  }

  Future<bool> submitQuiz(String quizId) async {
    AppLogger.info(_tag, 'submitQuiz called');
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
      AppLogger.warning(
        _tag,
        'submitQuiz: no current attempt, using raw answers',
      );
      payloadAnswers.addAll(_answers.map((a) => a.toJson()));
    }

    try {
      final data = await _quizApi.submitQuiz(quizId, payloadAnswers);
      final resultJson = data['result'] as Map<String, dynamic>? ?? data;
      _lastResult = QuizSubmitResult.fromJson(resultJson);
      AppLogger.success(_tag, 'submitQuiz succeeded');
      _submitting = false;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _errorMessage = ApiException.fromDioException(e);
      AppLogger.error(_tag, 'submitQuiz DioException', e);
      _submitting = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      AppLogger.error(_tag, 'submitQuiz error', e);
      _submitting = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchMyResults({
    int page = 1,
    int limit = 20,
    bool refresh = false,
  }) async {
    AppLogger.info(_tag, 'fetchMyResults called');
    final isFirstPage = page <= 1 || refresh;

    if (isFirstPage) {
      _loadingResults = true;
      _resultsPage = 1;
      _resultsLimit = limit;
      _hasMoreResults = true;
    } else {
      _loadingMoreResults = true;
    }

    _errorMessage = null;
    notifyListeners();
    try {
      final response = await _quizApi.getMyResults(page: page, limit: limit);
      final rawList =
          response['results'] as List<dynamic>? ??
          response['data'] as List<dynamic>? ??
          [];
      final results = rawList
          .map((r) => QuizMyResult.fromJson(r as Map<String, dynamic>))
          .toList();

      if (isFirstPage) {
        _myResults = results;
      } else {
        final existingIds = _myResults.map((r) => r.id).toSet();
        final newItems = results
            .where((r) => !existingIds.contains(r.id))
            .toList();
        _myResults.addAll(newItems);
      }

      _resultsPage = page;
      final pagination = response['pagination'] as Map<String, dynamic>?;
      if (pagination != null) {
        _hasMoreResults =
            pagination['hasNextPage'] as bool? ??
            (page < (pagination['totalPages'] as int? ?? 1));
      } else {
        _hasMoreResults = results.length >= limit;
      }
      AppLogger.success(_tag, 'fetchMyResults succeeded');
    } on DioException catch (e) {
      _errorMessage = ApiException.fromDioException(e);
      AppLogger.error(_tag, 'fetchMyResults DioException', e);
    } catch (e) {
      _errorMessage = e.toString();
      AppLogger.error(_tag, 'fetchMyResults error', e);
    }

    if (isFirstPage) {
      _loadingResults = false;
    }
    _loadingMoreResults = false;
    notifyListeners();
  }

  Future<void> loadMoreMyResults() async {
    if (_loadingResults || _loadingMoreResults || !_hasMoreResults) {
      return;
    }
    await fetchMyResults(page: _resultsPage + 1, limit: _resultsLimit);
  }

  void clearError() {
    AppLogger.info(_tag, 'clearError called');
    _errorMessage = null;
    notifyListeners();
  }

  void resetAttempt() {
    AppLogger.info(_tag, 'resetAttempt called');
    _currentAttempt = null;
    _loadingMoreAttempt = false;
    _answers.clear();
    _lastResult = null;
    notifyListeners();
  }
}
