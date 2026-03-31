import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/common_widgets.dart';
import '../../models/quiz_model.dart';
import '../../providers/quiz_provider.dart';

class QuizAttemptScreen extends StatefulWidget {
  final String quizId;
  final String quizTitle;

  const QuizAttemptScreen({
    super.key,
    required this.quizId,
    required this.quizTitle,
  });

  @override
  State<QuizAttemptScreen> createState() => _QuizAttemptScreenState();
}

class _QuizAttemptScreenState extends State<QuizAttemptScreen>
    with SingleTickerProviderStateMixin {
  int _currentPage = 1;
  final int _limit = 10;
  bool _loading = true;
  String? _error;

  Timer? _timer;
  int _timeLeft = 30;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final provider = context.read<QuizProvider>();
    provider.resetAttempt();

    final success = await provider.startAttempt(
      widget.quizId,
      page: _currentPage,
      limit: _limit,
    );

    if (mounted) {
      setState(() {
        _loading = false;
        _error = success ? null : provider.errorMessage;
      });

      if (success && provider.currentAttempt != null) {
        _startTimer();
      }
    }
  }

  void _startTimer() {
    _timer?.cancel();
    final provider = context.read<QuizProvider>();
    final attempt = provider.currentAttempt;
    if (attempt == null || attempt.questions.isEmpty) return;

    final currentQuestion = attempt.questions[_currentPage - 1];
    final timeLimit = currentQuestion.timeLimitSeconds ?? 30;

    setState(() => _timeLeft = timeLimit);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft <= 1) {
        timer.cancel();
        _handleTimeout();
      } else {
        setState(() => _timeLeft--);
      }
    });
  }

  void _handleTimeout() {
    final provider = context.read<QuizProvider>();
    final attempt = provider.currentAttempt;
    if (attempt == null || attempt.questions.isEmpty) return;

    final currentQuestion = attempt.questions[_currentPage - 1];
    provider.selectAnswer(currentQuestion.id, -1); // -1 for timeout/no answer

    _nextQuestion();
  }

  void _selectAnswer(int optionIndex) {
    _timer?.cancel();

    final provider = context.read<QuizProvider>();
    final attempt = provider.currentAttempt;
    if (attempt == null || attempt.questions.isEmpty) return;

    final currentQuestion = attempt.questions[_currentPage - 1];
    provider.selectAnswer(currentQuestion.id, optionIndex);

    _nextQuestion();
  }

  void _nextQuestion() async {
    final provider = context.read<QuizProvider>();
    final attempt = provider.currentAttempt;
    if (attempt == null) return;

    if (_currentPage >= attempt.totalPages) {
      // Submit quiz
      setState(() => _loading = true);
      final success = await provider.submitQuiz(widget.quizId);

      if (mounted) {
        setState(() => _loading = false);

        if (success && provider.lastResult != null) {
          _showResultDialog(provider.lastResult!);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(provider.errorMessage ?? 'Failed to submit quiz'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } else {
      // Load next page
      setState(() {
        _currentPage++;
        _loading = true;
      });

      final success = await provider.startAttempt(
        widget.quizId,
        page: _currentPage,
        limit: _limit,
      );

      if (mounted) {
        setState(() => _loading = false);

        if (success) {
          _startTimer();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                provider.errorMessage ?? 'Failed to load next questions',
              ),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  void _showResultDialog(QuizSubmitResult result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          'Quiz Complete!',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Score: ${result.correctAnswers}/${result.totalQuestions}',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Points Earned: ${result.pointsEarned}',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: AppColors.success,
              ),
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: result.percentage,
              backgroundColor: AppColors.surface,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Go back to quiz list
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.quizTitle,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.timer_rounded, size: 16, color: Colors.white),
                const SizedBox(width: 4),
                Text(
                  '$_timeLeft',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Consumer<QuizProvider>(
        builder: (context, provider, child) {
          if (_loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 48,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _error!,
                      style: GoogleFonts.poppins(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadQuestions,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final attempt = provider.currentAttempt;
          if (attempt == null || attempt.questions.isEmpty) {
            return const Center(child: Text('No questions available'));
          }

          final currentQuestion = attempt.questions[_currentPage - 1];

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Progress indicator
                LinearProgressIndicator(
                  value: _currentPage / attempt.totalPages,
                  backgroundColor: AppColors.surface,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
                const SizedBox(height: 8),
                Text(
                  'Question ${_currentPage} of ${attempt.questions.length * attempt.totalPages}',
                  style: GoogleFonts.poppins(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 24),

                // Question
                AppCard(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      currentQuestion.question,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Options
                Expanded(
                  child: ListView.builder(
                    itemCount: currentQuestion.options.length,
                    itemBuilder: (context, index) {
                      final option = currentQuestion.options[index];
                      final isSelected =
                          provider.getSelectedAnswer(currentQuestion.id) ==
                          index;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: AppCard(
                          child: InkWell(
                            onTap: () => _selectAnswer(index),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.surface,
                                width: 2,
                              ),
                              color: isSelected
                                  ? AppColors.primary.withValues(alpha: 0.05)
                                  : Colors.white,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.surface,
                                  ),
                                  child: Center(
                                    child: Text(
                                      String.fromCharCode(
                                        65 + index,
                                      ), // A, B, C, D...
                                      style: GoogleFonts.poppins(
                                        color: isSelected
                                            ? Colors.white
                                            : AppColors.textSecondary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    option,
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  Icon(
                                    Icons.check_circle_rounded,
                                    color: AppColors.primary,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ).animate().fadeIn(delay: (index * 100).ms));
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
