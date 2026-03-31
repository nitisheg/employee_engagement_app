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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadQuestions();
    });
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

    final totalTime = attempt.questions
        .map((q) => q.timeLimitSeconds ?? 30)
        .reduce((value, element) => value + element);

    setState(() => _timeLeft = totalTime);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft <= 1) {
        timer.cancel();
        _handleTimeout();
      } else {
        setState(() => _timeLeft--);
      }
    });
  }

  void _handleTimeout() async {
    final provider = context.read<QuizProvider>();
    final attempt = provider.currentAttempt;
    if (attempt == null || attempt.questions.isEmpty) return;

    // Find first unanswered question and mark as timeout answer
    final unanswered = attempt.questions
        .where((q) => provider.getSelectedAnswer(q.id) == null)
        .toList();

    if (unanswered.isNotEmpty) {
      provider.selectAnswer(unanswered.first.id, -1);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Time up: recording unanswered question.')),
      );

      // continue countdown until full quiz time is done
      _startTimer();
      return;
    }

    // If everything answered, submit automatically
    await _submitQuiz();
  }

  void _selectAnswer(String questionId, int optionIndex) {
    final provider = context.read<QuizProvider>();
    provider.selectAnswer(questionId, optionIndex);
  }

  Future<void> _submitQuiz() async {
    final provider = context.read<QuizProvider>();
    final attempt = provider.currentAttempt;
    if (attempt == null) return;

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

          final totalQuestions = attempt.totalQuestions;
          final answeredCount = provider.answers.length;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Progress indicator for total quiz
                LinearProgressIndicator(
                  value: totalQuestions > 0
                      ? answeredCount / totalQuestions
                      : 0,
                  backgroundColor: AppColors.surface,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
                const SizedBox(height: 8),
                Text(
                  'Answered $answeredCount of $totalQuestions questions',
                  style: GoogleFonts.poppins(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 24),

                Expanded(
                  child: ListView.builder(
                    itemCount: attempt.questions.length,
                    itemBuilder: (context, qIndex) {
                      final question = attempt.questions[qIndex];
                      final selectedAnswer = provider.getSelectedAnswer(
                        question.id,
                      );

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Q${qIndex + 1}. ${question.question}',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...question.options.asMap().entries.map((entry) {
                            final index = entry.key;
                            final option = entry.value;
                            final isSelected = selectedAnswer == index;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              child: AppCard(
                                child: InkWell(
                                  onTap: () =>
                                      _selectAnswer(question.id, index),
                                  child: Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isSelected
                                            ? AppColors.primary
                                            : AppColors.surface,
                                        width: 2,
                                      ),
                                      color: isSelected
                                          ? AppColors.primary.withOpacity(0.1)
                                          : Colors.white,
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          '${String.fromCharCode(65 + index)}.',
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.bold,
                                            color: isSelected
                                                ? AppColors.primary
                                                : AppColors.textSecondary,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            option,
                                            style: GoogleFonts.poppins(
                                              fontSize: 15,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                        ),
                                        if (isSelected)
                                          const Icon(
                                            Icons.check_circle,
                                            color: Colors.green,
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                          const SizedBox(height: 16),
                        ],
                      );
                    },
                  ),
                ),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: answeredCount == totalQuestions
                        ? _submitQuiz
                        : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: AppColors.primary,
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                    child: Text(
                      answeredCount == totalQuestions
                          ? 'Submit Quiz'
                          : 'Answer all $totalQuestions questions',
                    ),
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
