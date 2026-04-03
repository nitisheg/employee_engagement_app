import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class ZipGameScreen extends StatefulWidget {
  const ZipGameScreen({super.key});

  @override
  State<ZipGameScreen> createState() => _ZipGameScreenState();
}

class _ZipGameScreenState extends State<ZipGameScreen> {
  static const List<Map<String, String>> _prompts = [
    {'prompt': 'Name a fruit', 'example': 'Apple, Mango, ...'},
    {'prompt': 'Name a country', 'example': 'India, Brazil, ...'},
    {'prompt': 'Name an animal', 'example': 'Lion, Eagle, ...'},
    {'prompt': 'Name a color', 'example': 'Red, Cerulean, ...'},
    {'prompt': 'Name a sport', 'example': 'Cricket, Tennis, ...'},
    {'prompt': 'Name a programming language', 'example': 'Dart, Python, ...'},
    {'prompt': 'Name a car brand', 'example': 'BMW, Toyota, ...'},
    {'prompt': 'Name a planet', 'example': 'Mars, Jupiter, ...'},
  ];

  int _currentPromptIndex = 0;
  int _score = 0;
  int _timeLeft = 5;
  bool _gameStarted = false;
  bool _gameOver = false;
  bool _answered = false;
  Timer? _timer;

  final TextEditingController _answerCtrl = TextEditingController();
  final List<Map<String, dynamic>> _history = [];

  void _startGame() {
    setState(() {
      _gameStarted = true;
      _gameOver = false;
      _score = 0;
      _currentPromptIndex = 0;
      _history.clear();
      _answered = false;
    });
    _startRound();
  }

  void _startRound() {
    _answerCtrl.clear();
    setState(() {
      _timeLeft = 5;
      _answered = false;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_timeLeft <= 1) {
        t.cancel();
        _handleTimeout();
      } else {
        setState(() => _timeLeft--);
      }
    });
  }

  void _handleTimeout() {
    if (_answered) return;
    _history.add({
      'prompt': _prompts[_currentPromptIndex]['prompt'],
      'answer': '(no answer)',
      'correct': false,
    });
    _nextRound();
  }

  void _submitAnswer() {
    if (_answered) return;
    _timer?.cancel();
    final answer = _answerCtrl.text.trim();
    final isValid = answer.length >= 2;
    setState(() {
      _answered = true;
      if (isValid) _score += _timeLeft * 10;
      _history.add({
        'prompt': _prompts[_currentPromptIndex]['prompt'],
        'answer': answer.isEmpty ? '(skipped)' : answer,
        'correct': isValid,
      });
    });
    Future.delayed(const Duration(milliseconds: 600), _nextRound);
  }

  void _nextRound() {
    if (_currentPromptIndex >= _prompts.length - 1) {
      setState(() => _gameOver = true);
      return;
    }
    setState(() => _currentPromptIndex++);
    _startRound();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _answerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A0000),
      appBar: AppBar(
        backgroundColor: AppColors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Zip Game ⚡',
            style: GoogleFonts.poppins(
                color: AppColors.white, fontWeight: FontWeight.w700)),
        centerTitle: true,
        actions: [
          if (_gameStarted && !_gameOver)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text('$_score pts',
                    style: GoogleFonts.poppins(
                        color: AppColors.errorAccent,
                        fontWeight: FontWeight.w700,
                        fontSize: 16)),
              ),
            ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: !_gameStarted
            ? _buildStartScreen()
            : _gameOver
                ? _buildResultScreen()
                : _buildGameScreen(),
      ),
    );
  }

  Widget _buildStartScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('⚡', style: TextStyle(fontSize: 80))
                .animate()
                .scale(duration: 600.ms, curve: Curves.elasticOut),
            const SizedBox(height: 20),
            Text('Zip Game',
                style: GoogleFonts.poppins(
                    color: AppColors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 32)),
            const SizedBox(height: 12),
            Text(
              'Answer ${_prompts.length} prompts as fast as possible!\nYou have 5 seconds per question.\nMore time left = more points!',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                  color: AppColors.white.withValues(alpha: 0.7),
                  fontSize: 14,
                  height: 1.6),
            ),
            const SizedBox(height: 40),
            GestureDetector(
              onTap: _startGame,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 48, vertical: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFDC2626), Color(0xFF991B1B)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.red.withValues(alpha: 0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 6))
                  ],
                ),
                child: Text('Start Game ⚡',
                    style: GoogleFonts.poppins(
                        color: AppColors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 18)),
              ),
            ).animate().fadeIn(delay: 300.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildGameScreen() {
    final prompt = _prompts[_currentPromptIndex];
    final timerColor = _timeLeft <= 2 ? Colors.red : AppColors.errorAccent;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Progress
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Q ${_currentPromptIndex + 1}/${_prompts.length}',
                style: GoogleFonts.poppins(
                    color: AppColors.white.withValues(alpha: 0.7),
                    fontSize: 14),
              ),
              Text('$_score pts',
                  style: GoogleFonts.poppins(
                      color: AppColors.errorAccent,
                      fontWeight: FontWeight.w700,
                      fontSize: 14)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (_currentPromptIndex + 1) / _prompts.length,
              backgroundColor: AppColors.white.withValues(alpha: 0.1),
              valueColor:
                  const AlwaysStoppedAnimation(AppColors.errorAccent),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 32),

          // Timer circle
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: timerColor.withValues(alpha: 0.15),
              border: Border.all(color: timerColor, width: 4),
            ),
            child: Center(
              child: Text('$_timeLeft',
                  style: GoogleFonts.poppins(
                      color: timerColor,
                      fontWeight: FontWeight.w900,
                      fontSize: 40)),
            ),
          ).animate(target: _timeLeft <= 2 ? 1 : 0).shake(),
          const SizedBox(height: 32),

          // Prompt card
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Container(
              key: ValueKey(_currentPromptIndex),
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: AppColors.errorAccent.withValues(alpha: 0.4)),
              ),
              child: Column(
                children: [
                  Text(prompt['prompt']!,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                          color: AppColors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 22)),
                  const SizedBox(height: 6),
                  Text(prompt['example']!,
                      style: GoogleFonts.poppins(
                          color: AppColors.white.withValues(alpha: 0.5),
                          fontSize: 13)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Answer input
          TextField(
            controller: _answerCtrl,
            style: GoogleFonts.poppins(color: AppColors.white, fontSize: 18),
            decoration: InputDecoration(
              hintText: 'Type your answer...',
              hintStyle: GoogleFonts.poppins(
                  color: AppColors.white.withValues(alpha: 0.3),
                  fontSize: 16),
              filled: true,
              fillColor: AppColors.white.withValues(alpha: 0.08),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                    color: AppColors.errorAccent.withValues(alpha: 0.4)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                    color: AppColors.errorAccent.withValues(alpha: 0.4)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                    color: AppColors.errorAccent, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
            ),
            onSubmitted: (_) => _submitAnswer(),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    _answerCtrl.clear();
                    _submitAnswer();
                  },
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: AppColors.white.withValues(alpha: 0.2)),
                    ),
                    child: Center(
                      child: Text('Skip',
                          style: GoogleFonts.poppins(
                              color: AppColors.white.withValues(alpha: 0.7),
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: _submitAnswer,
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFDC2626), Color(0xFF991B1B)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.red.withValues(alpha: 0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 4))
                      ],
                    ),
                    child: Center(
                      child: Text('Submit ⚡',
                          style: GoogleFonts.poppins(
                              color: AppColors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 15)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultScreen() {
    final correct = _history.where((h) => h['correct'] == true).length;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('⚡', style: TextStyle(fontSize: 64))
                .animate()
                .scale(duration: 500.ms, curve: Curves.elasticOut),
            const SizedBox(height: 16),
            Text('Game Over!',
                style: GoogleFonts.poppins(
                    color: AppColors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 28)),
            const SizedBox(height: 8),
            Text('Final Score: $_score pts',
                style: GoogleFonts.poppins(
                    color: AppColors.errorAccent,
                    fontWeight: FontWeight.w700,
                    fontSize: 20)),
            Text('$correct / ${_prompts.length} answered',
                style: GoogleFonts.poppins(
                    color: AppColors.white.withValues(alpha: 0.6),
                    fontSize: 14)),
            const SizedBox(height: 24),
            // History
            Container(
              constraints: const BoxConstraints(maxHeight: 250),
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.all(12),
                itemCount: _history.length,
                itemBuilder: (_, i) {
                  final item = _history[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Icon(
                          item['correct'] == true
                              ? Icons.check_circle_rounded
                              : Icons.cancel_rounded,
                          color: item['correct'] == true
                              ? AppColors.success
                              : AppColors.errorAccent,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${item['prompt']}: ${item['answer']}',
                            style: GoogleFonts.poppins(
                                color: AppColors.white.withValues(alpha: 0.8),
                                fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: AppColors.white.withValues(alpha: 0.2)),
                      ),
                      child: Center(
                        child: Text('Exit',
                            style: GoogleFonts.poppins(
                                color: AppColors.white,
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: _startGame,
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFDC2626), Color(0xFF991B1B)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text('Play Again ⚡',
                            style: GoogleFonts.poppins(
                                color: AppColors.white,
                                fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

