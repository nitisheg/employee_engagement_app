import '../models/quiz_model.dart';
import '../services/api_service.dart';
import '../core/utils/app_logger.dart';
import 'base/base_view_model.dart';

class QuizViewModel extends BaseViewModel {
  static const _tag = 'QuizViewModel';

  List<ActiveQuiz> _quizzes = [];
  bool _isLoadingMoreQuizzes = false;
  int _quizzesPage = 1;
  int _quizzesLimit = 20;
  bool _hasMoreQuizzes = true;
  String _activeQuizFilter = 'all';

  QuizAttemptData? _currentQuiz;
  List<Map<String, dynamic>> _quizResults = [];
  bool _isLoadingMoreResults = false;
  int _resultsPage = 1;
  int _resultsLimit = 20;
  bool _hasMoreResults = true;

  int _currentQuestionIndex = 0;
  final Map<int, String> _selectedAnswers = {};

  List<ActiveQuiz> get quizzes => _quizzes;
  bool get isLoadingMoreQuizzes => _isLoadingMoreQuizzes;
  bool get hasMoreQuizzes => _hasMoreQuizzes;
  int get quizzesPage => _quizzesPage;

  QuizAttemptData? get currentQuiz => _currentQuiz;
  List<Map<String, dynamic>> get quizResults => _quizResults;
  bool get isLoadingMoreResults => _isLoadingMoreResults;
  bool get hasMoreResults => _hasMoreResults;
  int get resultsPage => _resultsPage;

  int get currentQuestionIndex => _currentQuestionIndex;
  Map<int, String> get selectedAnswers => _selectedAnswers;

  bool get isLastQuestion =>
      _currentQuiz != null &&
      _currentQuestionIndex == _currentQuiz!.questions.length - 1;

  Future<void> loadQuizzes({
    String? category,
    String? difficulty,
    int page = 1,
    int limit = 20,
    bool refresh = false,
  }) async {
    AppLogger.info(_tag, 'loadQuizzes called');
    final filter = category ?? difficulty ?? _activeQuizFilter;
    final isFirstPage = page <= 1 || refresh || filter != _activeQuizFilter;

    try {
      if (isFirstPage) {
        _activeQuizFilter = filter;
        _quizzesPage = 1;
        _quizzesLimit = limit;
        _hasMoreQuizzes = true;
        setLoading();
      } else {
        _isLoadingMoreQuizzes = true;
        notifyListeners();
      }

      final response = await QuizApiService().getActiveQuizzes(
        filter: filter,
        page: page,
        limit: limit,
      );
      final rawList =
          response['quizzes'] as List<dynamic>? ??
          response['data'] as List<dynamic>? ??
          [];
      final fetched = rawList
          .map((json) => ActiveQuiz.fromJson(json as Map<String, dynamic>))
          .toList();

      if (isFirstPage) {
        _quizzes = fetched;
      } else {
        final existingIds = _quizzes.map((q) => q.id).toSet();
        final deduped = fetched.where((q) => !existingIds.contains(q.id));
        _quizzes.addAll(deduped);
      }

      _quizzesPage = page;

      final pagination = response['pagination'] as Map<String, dynamic>?;
      if (pagination != null) {
        _hasMoreQuizzes =
            pagination['hasNextPage'] as bool? ??
            (page < (pagination['totalPages'] as int? ?? 1));
      } else {
        _hasMoreQuizzes = fetched.length >= limit;
      }

      AppLogger.success(_tag, 'loadQuizzes succeeded');
      if (isFirstPage) {
        setSuccess();
      } else {
        setIdle();
      }
    } catch (e) {
      AppLogger.error(_tag, 'loadQuizzes error', e);
      setError(e.toString());
      if (!isFirstPage && _quizzesPage > 1) {
        _quizzesPage--;
      }
      _hasMoreQuizzes = false;
    } finally {
      _isLoadingMoreQuizzes = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreQuizzes() async {
    if (isLoading || _isLoadingMoreQuizzes || !_hasMoreQuizzes) return;
    await loadQuizzes(
      category: _activeQuizFilter,
      page: _quizzesPage + 1,
      limit: _quizzesLimit,
    );
  }

  Future<void> refreshQuizzes({String? category, String? difficulty}) async {
    await loadQuizzes(
      category: category,
      difficulty: difficulty,
      page: 1,
      limit: _quizzesLimit,
      refresh: true,
    );
  }

  Future<void> loadQuizById(String quizId) async {
    AppLogger.info(_tag, 'loadQuizById called');
    try {
      setLoading();
      final data = await QuizApiService().getQuizAttempt(quizId);
      _currentQuiz = QuizAttemptData.fromJson(data);
      _currentQuestionIndex = 0;
      _selectedAnswers.clear();
      AppLogger.success(_tag, 'loadQuizById succeeded');
      setSuccess();
    } catch (e) {
      AppLogger.error(_tag, 'loadQuizById error', e);
      setError(e.toString());
    }
  }

  void selectAnswer(int questionIndex, String answer) {
    AppLogger.info(_tag, 'selectAnswer called');
    _selectedAnswers[questionIndex] = answer;
    notifyListeners();
  }

  void nextQuestion() {
    AppLogger.info(_tag, 'nextQuestion called');
    if (_currentQuiz != null &&
        _currentQuestionIndex < _currentQuiz!.questions.length - 1) {
      _currentQuestionIndex++;
      notifyListeners();
    } else {
      AppLogger.warning(
        _tag,
        'nextQuestion: already at last question or no quiz loaded',
      );
    }
  }

  void previousQuestion() {
    AppLogger.info(_tag, 'previousQuestion called');
    if (_currentQuestionIndex > 0) {
      _currentQuestionIndex--;
      notifyListeners();
    } else {
      AppLogger.warning(_tag, 'previousQuestion: already at first question');
    }
  }

  Future<void> submitQuiz() async {
    AppLogger.info(_tag, 'submitQuiz called');
    if (_currentQuiz == null) {
      AppLogger.warning(_tag, 'submitQuiz: no current quiz loaded');
      return;
    }

    try {
      setLoading();
      final answers = _selectedAnswers.entries
          .map((entry) => {'questionIndex': entry.key, 'answer': entry.value})
          .toList();
      final data = await QuizApiService().submitQuiz(
        _currentQuiz!.quizId,
        answers,
      );
      _quizResults.add(data);
      AppLogger.success(_tag, 'submitQuiz succeeded');
      setSuccess();
    } catch (e) {
      AppLogger.error(_tag, 'submitQuiz error', e);
      setError(e.toString());
    }
  }

  Future<void> loadQuizResults({
    int page = 1,
    int limit = 20,
    bool refresh = false,
  }) async {
    AppLogger.info(_tag, 'loadQuizResults called');
    final isFirstPage = page <= 1 || refresh;

    try {
      if (isFirstPage) {
        _resultsPage = 1;
        _resultsLimit = limit;
        _hasMoreResults = true;
        setLoading();
      } else {
        _isLoadingMoreResults = true;
        notifyListeners();
      }

      final response = await QuizApiService().getMyResults(
        page: page,
        limit: limit,
      );
      final rawList =
          response['results'] as List<dynamic>? ??
          response['data'] as List<dynamic>? ??
          [];
      final fetched = List<Map<String, dynamic>>.from(
        rawList.map((r) => r as Map<String, dynamic>),
      );

      if (isFirstPage) {
        _quizResults = fetched;
      } else {
        final existingIds = _quizResults
            .map((r) => (r['_id'] ?? r['id'])?.toString())
            .whereType<String>()
            .toSet();

        for (final result in fetched) {
          final id = (result['_id'] ?? result['id'])?.toString();
          if (id == null || !existingIds.contains(id)) {
            _quizResults.add(result);
          }
        }
      }

      _resultsPage = page;

      final pagination = response['pagination'] as Map<String, dynamic>?;
      if (pagination != null) {
        _hasMoreResults =
            pagination['hasNextPage'] as bool? ??
            (page < (pagination['totalPages'] as int? ?? 1));
      } else {
        _hasMoreResults = fetched.length >= limit;
      }

      AppLogger.success(_tag, 'loadQuizResults succeeded');
      if (isFirstPage) {
        setSuccess();
      } else {
        setIdle();
      }
    } catch (e) {
      AppLogger.error(_tag, 'loadQuizResults error', e);
      setError(e.toString());
      if (!isFirstPage && _resultsPage > 1) {
        _resultsPage--;
      }
      _hasMoreResults = false;
    } finally {
      _isLoadingMoreResults = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreQuizResults() async {
    if (isLoading || _isLoadingMoreResults || !_hasMoreResults) return;
    await loadQuizResults(page: _resultsPage + 1, limit: _resultsLimit);
  }

  Future<void> refreshQuizResults() async {
    await loadQuizResults(page: 1, limit: _resultsLimit, refresh: true);
  }

  void resetQuiz() {
    AppLogger.info(_tag, 'resetQuiz called');
    _currentQuiz = null;
    _currentQuestionIndex = 0;
    _selectedAnswers.clear();
    setIdle();
  }
}
