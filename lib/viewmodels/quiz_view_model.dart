import '../models/quiz_model.dart';
import '../services/api_service.dart';
import '../core/utils/app_logger.dart';
import 'base/base_view_model.dart';

class QuizViewModel extends BaseViewModel {
  static const _tag = 'QuizViewModel';

  List<ActiveQuiz> _quizzes = [];
  QuizAttemptData? _currentQuiz;
  List<Map<String, dynamic>> _quizResults = [];
  int _currentQuestionIndex = 0;
  final Map<int, String> _selectedAnswers = {};

  List<ActiveQuiz> get quizzes => _quizzes;
  QuizAttemptData? get currentQuiz => _currentQuiz;
  List<Map<String, dynamic>> get quizResults => _quizResults;
  int get currentQuestionIndex => _currentQuestionIndex;
  Map<int, String> get selectedAnswers => _selectedAnswers;

  bool get isLastQuestion =>
      _currentQuiz != null &&
      _currentQuestionIndex == _currentQuiz!.questions.length - 1;

  Future<void> loadQuizzes({String? category, String? difficulty}) async {
    AppLogger.info(_tag, 'loadQuizzes called');
    try {
      setLoading();
      final filter = category ?? difficulty ?? 'all';
      final response = await QuizApiService().getActiveQuizzes(filter: filter);
      final rawList =
          response['quizzes'] as List<dynamic>? ??
          response['data'] as List<dynamic>? ??
          [];
      _quizzes = rawList
          .map((json) => ActiveQuiz.fromJson(json as Map<String, dynamic>))
          .toList();
      AppLogger.success(_tag, 'loadQuizzes succeeded');
      setSuccess();
    } catch (e) {
      AppLogger.error(_tag, 'loadQuizzes error', e);
      setError(e.toString());
    }
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

  Future<void> loadQuizResults() async {
    AppLogger.info(_tag, 'loadQuizResults called');
    try {
      setLoading();
      final response = await QuizApiService().getMyResults();
      final rawList =
          response['results'] as List<dynamic>? ??
          response['data'] as List<dynamic>? ??
          [];
      _quizResults = List<Map<String, dynamic>>.from(
        rawList.map((r) => r as Map<String, dynamic>),
      );
      AppLogger.success(_tag, 'loadQuizResults succeeded');
      setSuccess();
    } catch (e) {
      AppLogger.error(_tag, 'loadQuizResults error', e);
      setError(e.toString());
    }
  }

  void resetQuiz() {
    AppLogger.info(_tag, 'resetQuiz called');
    _currentQuiz = null;
    _currentQuestionIndex = 0;
    _selectedAnswers.clear();
    setIdle();
  }
}
