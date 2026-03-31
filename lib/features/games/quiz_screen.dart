import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/common_widgets.dart';
import '../../models/quiz_model.dart';
import '../../providers/quiz_provider.dart';

class QuizScreen extends StatefulWidget {
  /// Pass a quiz ID to load from the API. If null, falls back to local questions.
  final String? quizId;

  const QuizScreen({super.key, this.quizId});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen>
    with SingleTickerProviderStateMixin {
  // ── Local fallback questions (used when quizId is null) ──────────────────────
  static const List<QuizQuestion> _localQuestions = [
    QuizQuestion(
      id: 'local_0',
      question: 'What does "KPI" stand for in a business context?',
      options: [
        'Key Performance Indicator',
        'Key Process Integration',
        'Knowledge Point Index',
        'Key Product Initiative',
      ],
      correctIndex: 0,
    ),
    QuizQuestion(
      id: 'local_1',
      question: 'Which programming language was created by Guido van Rossum?',
      options: ['Java', 'Ruby', 'Python', 'Go'],
      correctIndex: 2,
    ),
    QuizQuestion(
      id: 'local_2',
      question: 'What does "ROI" stand for?',
      options: [
        'Rate of Investment',
        'Return on Investment',
        'Revenue over Income',
        'Risk of Indicator',
      ],
      correctIndex: 1,
    ),
    QuizQuestion(
      id: 'local_3',
      question: 'Which of these is a cloud computing platform by Amazon?',
      options: ['Azure', 'GCP', 'AWS', 'Oracle Cloud'],
      correctIndex: 2,
    ),
    QuizQuestion(
      id: 'local_4',
      question: 'What is the primary purpose of an "agile sprint"?',
      options: [
        'Annual planning',
        'A short development cycle to deliver work',
        'A marketing campaign',
        'A performance review period',
      ],
      correctIndex: 1,
    ),
  ];

  // ── State ────────────────────────────────────────────────────────────────────

  List<QuizQuestion> _questions = [];
  bool _loadingFromApi = false;
  bool _apiMode = false;

  int _currentIndex = 0;
  int? _selectedAnswer;
  bool _answered = false;
  int _score = 0;
  bool _quizComplete = false;
  int _timeLeft = 30;
  Timer? _timer;

  // API result after submit
  QuizSubmitResult? _apiResult;

  @override
  void initState() {
    super.initState();
    if (widget.quizId != null) {
      _loadApiQuestions();
    } else {
      _questions = _localQuestions;
      _startTimer();
    }
  }

  Future<void> _loadApiQuestions() async {
    setState(() => _loadingFromApi = true);
    final provider = context.read<QuizProvider>();
    provider.resetAttempt();
    final ok = await provider.startAttempt(widget.quizId!);
    if (!mounted) return;
    if (ok && provider.currentAttempt != null) {
      final attempt = provider.currentAttempt!;
      setState(() {
        _questions = attempt.questions
            .map(QuizQuestion.fromAttemptQuestion)
            .toList();
        _apiMode = true;
        _loadingFromApi = false;
      });
      _startTimer();
    } else {
      // Fallback to local questions on error
      setState(() {
        _questions = _localQuestions;
        _loadingFromApi = false;
      });
      _startTimer();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    final limit = _questions.isNotEmpty
        ? (_questions[_currentIndex].timeLimitSeconds)
        : 30;
    setState(() => _timeLeft = limit);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_timeLeft <= 1) {
        t.cancel();
        if (!_answered) _handleAnswer(-1);
      } else {
        setState(() => _timeLeft--);
      }
    });
  }

  void _handleAnswer(int index) {
    if (_answered) return;
    _timer?.cancel();
    final q = _questions[_currentIndex];
    bool isCorrect = false;
    if (_apiMode) {
      // In API mode, record the answer; correctness revealed after submit
      context.read<QuizProvider>().selectAnswer(q.id, index);
    } else {
      isCorrect = index == q.correctIndex;
    }
    setState(() {
      _selectedAnswer = index;
      _answered = true;
      if (!_apiMode && isCorrect) _score += 20;
    });
  }

  void _nextQuestion() async {
    if (_currentIndex >= _questions.length - 1) {
      if (_apiMode && widget.quizId != null) {
        // Submit to API
        final ok = await context.read<QuizProvider>().submitQuiz(widget.quizId!);
        if (mounted) {
          _apiResult = ok ? context.read<QuizProvider>().lastResult : null;
          if (_apiResult != null) {
            _score = _apiResult!.pointsEarned;
          }
        }
      }
      setState(() => _quizComplete = true);
      return;
    }
    setState(() {
      _currentIndex++;
      _selectedAnswer = null;
      _answered = false;
    });
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Color _optionColor(int index) {
    if (!_answered) return Colors.white;
    if (_apiMode) {
      // In API mode: only highlight selected, no green/red until result
      return index == _selectedAnswer
          ? AppColors.primary.withValues(alpha: 0.1)
          : Colors.white;
    }
    final q = _questions[_currentIndex];
    if (index == q.correctIndex) return AppColors.success.withValues(alpha: 0.15);
    if (index == _selectedAnswer) return Colors.red.withValues(alpha: 0.12);
    return Colors.white;
  }

  Color _optionBorderColor(int index) {
    if (!_answered) return Colors.grey.shade200;
    if (_apiMode) {
      return index == _selectedAnswer ? AppColors.primary : Colors.grey.shade200;
    }
    final q = _questions[_currentIndex];
    if (index == q.correctIndex) return AppColors.success;
    if (index == _selectedAnswer) return Colors.redAccent;
    return Colors.grey.shade200;
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingFromApi) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_quizComplete) return _buildScoreScreen(context);

    if (_questions.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('No questions available.')),
      );
    }

    final q = _questions[_currentIndex];
    final timerMax = q.timeLimitSeconds;
    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          leading: IconButton(
            icon: const Icon(Icons.close_rounded, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Question ${_currentIndex + 1} of ${_questions.length}',
            style: GoogleFonts.poppins(
                color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
          ),
          flexibleSpace: Container(
              decoration: const BoxDecoration(gradient: AppColors.primaryGradient)),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(child: PointsBadge(points: _score)),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Progress + timer row
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (_currentIndex + 1) / _questions.length,
                        backgroundColor:
                            AppColors.primary.withValues(alpha: 0.15),
                        valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                        minHeight: 6,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  CircularPercentIndicator(
                    radius: 28,
                    lineWidth: 5,
                    percent: (_timeLeft / timerMax).clamp(0.0, 1.0),
                    center: Text(
                      '$_timeLeft',
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: _timeLeft <= 10
                              ? Colors.redAccent
                              : AppColors.primary),
                    ),
                    progressColor: _timeLeft <= 10
                        ? Colors.redAccent
                        : AppColors.primary,
                    backgroundColor:
                        AppColors.primary.withValues(alpha: 0.15),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Question card
              AppCard(
                child: Text(
                  q.question,
                  style: GoogleFonts.poppins(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      height: 1.5),
                  textAlign: TextAlign.center,
                ),
              ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.05, end: 0),
              const SizedBox(height: 24),

              // Options
              ...q.options.asMap().entries.map((entry) {
                final i = entry.key;
                final opt = entry.value;
                return GestureDetector(
                  onTap: () => _handleAnswer(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 16),
                    decoration: BoxDecoration(
                      color: _optionColor(i),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: _optionBorderColor(i), width: 2),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2))
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: _answered && i == _selectedAnswer
                                ? _optionBorderColor(i).withValues(alpha: 0.15)
                                : AppColors.surface,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: _answered && !_apiMode
                                ? Icon(
                                    i == q.correctIndex
                                        ? Icons.check_rounded
                                        : i == _selectedAnswer
                                            ? Icons.close_rounded
                                            : null,
                                    size: 16,
                                    color: i == q.correctIndex
                                        ? AppColors.success
                                        : Colors.redAccent,
                                  )
                                : Text(
                                    String.fromCharCode(65 + i),
                                    style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                        color: AppColors.primary),
                                  ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(opt,
                              style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textPrimary)),
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(
                    delay: Duration(milliseconds: 100 + i * 60));
              }),

              const Spacer(),
              if (_answered)
                Consumer<QuizProvider>(
                  builder: (context, quizProvider, _) {
                    return quizProvider.submitting
                        ? const CircularProgressIndicator()
                        : GradientButton(
                            label: _currentIndex == _questions.length - 1
                                ? 'See Results'
                                : 'Next Question',
                            icon: Icons.arrow_forward_rounded,
                            onTap: _nextQuestion,
                          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreScreen(BuildContext context) {
    final totalPts = _apiMode && _apiResult != null
        ? _apiResult!.pointsEarned
        : _score;
    final correct = _apiMode && _apiResult != null
        ? _apiResult!.correctAnswers
        : (_score ~/ 20);
    final total = _questions.length;
    final percentage = total > 0 ? (correct / total * 100).toInt() : 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.35),
                          blurRadius: 24,
                          offset: const Offset(0, 8))
                    ],
                  ),
                  child: const Icon(Icons.emoji_events_rounded,
                      color: AppColors.gold, size: 60),
                ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
                const SizedBox(height: 24),
                Text('Quiz Complete! 🎉',
                    style: GoogleFonts.poppins(
                        fontSize: 26, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Text('You scored $percentage%',
                    style: GoogleFonts.poppins(
                        fontSize: 16, color: AppColors.textSecondary)),
                const SizedBox(height: 30),
                CircularPercentIndicator(
                  radius: 70,
                  lineWidth: 10,
                  percent: (percentage / 100).clamp(0.0, 1.0),
                  center: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('$totalPts',
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w800, fontSize: 28)),
                      Text('pts',
                          style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: AppColors.textSecondary)),
                    ],
                  ),
                  progressColor: AppColors.primary,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                ).animate().fadeIn(delay: 300.ms),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: OutlineButton2(
                          label: 'Play Again',
                          onTap: () {
                            context.read<QuizProvider>().resetAttempt();
                            setState(() {
                              _currentIndex = 0;
                              _selectedAnswer = null;
                              _answered = false;
                              _score = 0;
                              _quizComplete = false;
                              _apiResult = null;
                            });
                            if (widget.quizId != null) {
                              _loadApiQuestions();
                            } else {
                              _startTimer();
                            }
                          }),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GradientButton(
                          label: 'Done',
                          onTap: () => Navigator.pop(context)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
