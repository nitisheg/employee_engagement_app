import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/common_widgets.dart';
import '../../providers/psychometric_provider.dart';
import 'psychometric_result_detail_screen.dart';

class PsychometricTestScreen extends StatefulWidget {
  final String testId;

  const PsychometricTestScreen({super.key, required this.testId});

  @override
  State<PsychometricTestScreen> createState() => _PsychometricTestScreenState();
}

class _PsychometricTestScreenState extends State<PsychometricTestScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    Future.microtask(() {
      context.read<PsychometricProvider>().startTest(widget.testId);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        context.read<PsychometricProvider>().reset();
        return true;
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Psychometric Test'),
          centerTitle: true,
          backgroundColor: AppColors.primary,
          elevation: 0,
        ),
        body: SafeArea(
          top: false,
          child: Consumer<PsychometricProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (provider.errorMessage != null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(provider.errorMessage!, textAlign: TextAlign.center),
                    ],
                  ),
                );
              }

              final attempt = provider.currentAttempt;
              if (attempt == null) {
                return const Center(child: Text('No test data'));
              }

              return Column(
                children: [
                  // Progress bar
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.white,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              attempt.test.title,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              '${provider.answeredCount}/${provider.totalCount}',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: provider.completionPercentage / 100,
                            minHeight: 8,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Statements list
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      onPageChanged: (_) {},
                      itemCount: attempt.statements.length,
                      itemBuilder: (context, index) {
                        final statement = attempt.statements[index];
                        final currentValue = provider.responses[statement.id];

                        return SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 20),
                              // Question number
                              Text(
                                'Question ${index + 1} of ${attempt.statements.length}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Statement
                              Text(
                                statement.statementText,
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 32),
                              // Scale options
                              ...attempt.scale.map((option) {
                                final isSelected = currentValue == option.value;

                                return GestureDetector(
                                  onTap: () {
                                    provider.setResponse(
                                      statement.id,
                                      option.value,
                                    );
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.primary.withOpacity(0.1)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isSelected
                                            ? AppColors.primary
                                            : Colors.grey.shade200,
                                        width: isSelected ? 2 : 1,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 24,
                                          height: 24,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: isSelected
                                                  ? AppColors.primary
                                                  : Colors.grey.shade400,
                                              width: 2,
                                            ),
                                          ),
                                          child: isSelected
                                              ? Center(
                                                  child: Container(
                                                    width: 12,
                                                    height: 12,
                                                    decoration:
                                                        const BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          color:
                                                              AppColors.primary,
                                                        ),
                                                  ),
                                                )
                                              : null,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                option.label,
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w600,
                                                  color: isSelected
                                                      ? AppColors.primary
                                                      : Colors.black87,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                              const SizedBox(height: 32),
                              // Navigation buttons
                              Row(
                                children: [
                                  if (index > 0)
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: () {
                                          _pageController.previousPage(
                                            duration: const Duration(
                                              milliseconds: 300,
                                            ),
                                            curve: Curves.easeInOut,
                                          );
                                        },
                                        icon: const Icon(
                                          Icons.arrow_back_rounded,
                                        ),
                                        label: const Text('Previous'),
                                      ),
                                    )
                                  else
                                    const Spacer(),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: currentValue != null
                                          ? () {
                                              if (index <
                                                  attempt.statements.length -
                                                      1) {
                                                _pageController.nextPage(
                                                  duration: const Duration(
                                                    milliseconds: 300,
                                                  ),
                                                  curve: Curves.easeInOut,
                                                );
                                              } else {
                                                // Show submit dialog
                                                _showSubmitDialog(
                                                  context,
                                                  provider,
                                                );
                                              }
                                            }
                                          : null,
                                      icon: Icon(
                                        index < attempt.statements.length - 1
                                            ? Icons.arrow_forward_rounded
                                            : Icons.check_rounded,
                                      ),
                                      label: Text(
                                        index < attempt.statements.length - 1
                                            ? 'Next'
                                            : 'Submit',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _showSubmitDialog(BuildContext context, PsychometricProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Submit Test'),
        content: const Text(
          'Are you sure you want to submit your test? You cannot change your answers after submission.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await provider.submitTest();
              if (success && mounted) {
                Navigator.pop(context);
                if (provider.lastResult != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PsychometricResultDetailScreen(
                        result: provider.lastResult!,
                      ),
                    ),
                  );
                }
              }
            },
            child: provider.isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
