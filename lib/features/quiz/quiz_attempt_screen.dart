import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_snackbar.dart';
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
  final int _currentPage = 1;
  final int _initialLimit = 20;
  final int _loadMoreLimit = 10;
  bool _requestingMoreQuestions = false;
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
      limit: _initialLimit,
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
      AppSnackBar.show(
        context,
        message: 'Time up: recording unanswered question.',
        type: AppSnackBarType.warning,
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

  Future<void> _loadMoreQuestionsIfNeeded(
    ScrollNotification notification,
  ) async {
    if (_requestingMoreQuestions) return;

    final provider = context.read<QuizProvider>();
    if (!provider.hasMoreAttemptQuestions || provider.loadingMoreAttempt) {
      return;
    }

    if (notification.metrics.pixels >=
        notification.metrics.maxScrollExtent * 0.9) {
      _requestingMoreQuestions = true;
      await provider.loadMoreAttemptQuestions(
        widget.quizId,
        limit: _loadMoreLimit,
      );
      _requestingMoreQuestions = false;
    }
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
        AppSnackBar.show(
          context,
          message: provider.errorMessage ?? 'Failed to submit quiz',
          type: AppSnackBarType.error,
        );
      }
    }
  }

  void _showResultDialog(QuizSubmitResult result) {
    final provider = context.read<QuizProvider>();
    final attemptTotal = provider.currentAttempt?.totalQuestions ?? 0;
    final answeredTotal = provider.answers
        .where((a) => a.selectedOption >= 0)
        .length;

    int resolvedTotal = result.totalQuestions;
    if (resolvedTotal <= 0 && result.results.isNotEmpty) {
      resolvedTotal = result.results.length;
    }
    if (resolvedTotal <= 0 && attemptTotal > 0) {
      resolvedTotal = attemptTotal;
    }
    if (resolvedTotal <= 0 && answeredTotal > 0) {
      resolvedTotal = answeredTotal;
    }

    int resolvedCorrect = result.correctAnswers;
    if (resolvedCorrect < 0) {
      resolvedCorrect = 0;
    }
    if (resolvedTotal > 0 && resolvedCorrect > resolvedTotal) {
      resolvedCorrect = resolvedTotal;
    }

    final resolvedIncorrect = resolvedTotal > resolvedCorrect
        ? resolvedTotal - resolvedCorrect
        : 0;
    final progressValue = resolvedTotal > 0
        ? (resolvedCorrect / resolvedTotal).clamp(0.0, 1.0)
        : 0.0;
    final percentage = (progressValue * 100).round();
    final isExcellent = percentage >= 90;
    final isGood = percentage >= 70;
    final isPassed = percentage >= 50;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.all(20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with icon
            Container(
              width: 500,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    (isExcellent
                            ? AppColors.success
                            : isGood
                            ? AppColors.primary
                            : isPassed
                            ? AppColors.warning
                            : AppColors.error)
                        .withValues(alpha: 0.1),
              ),
              child: Icon(
                isExcellent
                    ? Icons.emoji_events_rounded
                    : isGood
                    ? Icons.thumb_up_rounded
                    : isPassed
                    ? Icons.check_circle_rounded
                    : Icons.error_rounded,
                color: isExcellent
                    ? AppColors.success
                    : isGood
                    ? AppColors.primary
                    : isPassed
                    ? AppColors.warning
                    : AppColors.error,
                size: 48,
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              isExcellent
                  ? 'Excellent Work!'
                  : isGood
                  ? 'Great Job!'
                  : isPassed
                  ? 'Well Done!'
                  : 'Keep Trying!',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Quiz Completed',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),

            // Score display
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color:
                    (isExcellent
                            ? AppColors.success
                            : isGood
                            ? AppColors.primary
                            : isPassed
                            ? AppColors.warning
                            : AppColors.error)
                        .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    '$percentage%',
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: isExcellent
                          ? AppColors.success
                          : isGood
                          ? AppColors.primary
                          : isPassed
                          ? AppColors.warning
                          : AppColors.error,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Stats
            Wrap(
              alignment: WrapAlignment.spaceEvenly,
              spacing: 18,
              runSpacing: 12,
              children: [
                _ResultStatItem(
                  icon: Icons.check_circle_rounded,
                  value: '$resolvedCorrect/$resolvedTotal',
                  label: 'Correct',
                  color: AppColors.success,
                ),
                Spacer(),
                _ResultStatItem(
                  icon: Icons.stars_rounded,
                  value: '${result.pointsEarned}',
                  label: 'Points',
                  color: AppColors.primary,
                ),
                Spacer(),

                _ResultStatItem(
                  icon: Icons.cancel_rounded,
                  value: '$resolvedIncorrect/$resolvedTotal',
                  label: 'Wrong',
                  color: AppColors.error,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Progress bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Performance',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '$percentage%',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progressValue,
                  backgroundColor: AppColors.surface,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isExcellent
                        ? AppColors.success
                        : isGood
                        ? AppColors.primary
                        : isPassed
                        ? AppColors.warning
                        : AppColors.error,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Go back to quiz list
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isExcellent
                    ? AppColors.success
                    : isGood
                    ? AppColors.primary
                    : isPassed
                    ? AppColors.warning
                    : AppColors.error,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Continue',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
        actionsPadding: const EdgeInsets.all(20),
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
    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(
            widget.quizTitle,
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          actions: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.timer_rounded,
                    size: 16,
                    color: AppColors.white,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$_timeLeft',
                    style: GoogleFonts.poppins(
                      color: AppColors.white,
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
            final showNoMoreQuestionsFooter =
                !provider.loadingMoreAttempt &&
                !provider.hasMoreAttemptQuestions &&
                attempt.questions.isNotEmpty;

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
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
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
                    child: NotificationListener<ScrollNotification>(
                      onNotification: (notification) {
                        _loadMoreQuestionsIfNeeded(notification);
                        return false;
                      },
                      child: ListView.builder(
                        itemCount:
                            attempt.questions.length +
                            ((provider.loadingMoreAttempt ||
                                    showNoMoreQuestionsFooter)
                                ? 1
                                : 0),
                        itemBuilder: (context, qIndex) {
                          if (qIndex >= attempt.questions.length) {
                            if (provider.loadingMoreAttempt) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }

                            if (showNoMoreQuestionsFooter) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                child: Center(
                                  child: Text(
                                    'No more questions',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              );
                            }

                            return const SizedBox.shrink();
                          }

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
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
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
      ),
    );
  }
}

class _ResultStatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _ResultStatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.1),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

