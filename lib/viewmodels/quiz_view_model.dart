import '../models/quiz_model.dart';
import '../services/api_service.dart';
import 'base_view_model.dart';

class QuizViewModel extends BaseViewModel {
  List<ActiveQuiz> _quizzes = [];
  QuizAttemptData? _currentQuiz;
  List<Map<String, dynamic>> _quizResults = [];
  int _currentQuestionIndex = 0;
  Map<int, String> _selectedAnswers = {};

  List<ActiveQuiz> get quizzes => _quizzes;
  QuizAttemptData? get currentQuiz => _currentQuiz;
  List<Map<String, dynamic>> get quizResults => _quizResults;
  int get currentQuestionIndex => _currentQuestionIndex;
  Map<int, String> get selectedAnswers => _selectedAnswers;

  bool get isLastQuestion =>
      _currentQuiz != null &&
      _currentQuestionIndex == _currentQuiz!.questions.length - 1;

  Future<void> loadQuizzes({String? category, String? difficulty}) async {
    try {
      setLoading();
      final filter = category ?? difficulty ?? 'all';
      final data = await QuizApiService().getActiveQuizzes(filter: filter);
      _quizzes = (data as List)
          .map((json) => ActiveQuiz.fromJson(json))
          .toList();
      setSuccess();
    } catch (e) {
      setError(e.toString());
    }
  }

  Future<void> loadQuizById(String quizId) async {
    try {
      setLoading();
      final data = await QuizApiService().getQuizAttempt(quizId);
      _currentQuiz = QuizAttemptData.fromJson(data);
      _currentQuestionIndex = 0;
      _selectedAnswers.clear();
      setSuccess();
    } catch (e) {
      setError(e.toString());
    }
  }

  void selectAnswer(int questionIndex, String answer) {
    _selectedAnswers[questionIndex] = answer;
    notifyListeners();
  }

  void nextQuestion() {
    if (_currentQuiz != null &&
        _currentQuestionIndex < _currentQuiz!.questions.length - 1) {
      _currentQuestionIndex++;
      notifyListeners();
    }
  }

  void previousQuestion() {
    if (_currentQuestionIndex > 0) {
      _currentQuestionIndex--;
      notifyListeners();
    }
  }

  Future<void> submitQuiz() async {
    if (_currentQuiz == null) return;

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
      setSuccess();
    } catch (e) {
      setError(e.toString());
    }
  }

  Future<void> loadQuizResults() async {
    try {
      setLoading();
      final data = await QuizApiService().getMyResults();
      _quizResults = List<Map<String, dynamic>>.from(data);
      setSuccess();
    } catch (e) {
      setError(e.toString());
    }
  }

  void resetQuiz() {
    _currentQuiz = null;
    _currentQuestionIndex = 0;
    _selectedAnswers.clear();
    setIdle();
  }
}
