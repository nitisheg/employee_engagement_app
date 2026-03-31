import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

class SudokuScreen extends StatefulWidget {
  const SudokuScreen({super.key});

  @override
  State<SudokuScreen> createState() => _SudokuScreenState();
}

class _SudokuScreenState extends State<SudokuScreen> {
  String _difficulty = 'Easy';
  int? _selectedRow;
  int? _selectedCol;
  bool _isPaused = false;
  int _elapsedSeconds = 0;
  Timer? _timer;
  int _score = 0;

  // 0 = empty, non-zero = given clue (locked)
  // grid[row][col]
  late List<List<int>> _userGrid;
  late List<List<bool>> _locked;

  static const List<List<int>> _easyPuzzle = [
    [5, 3, 0, 0, 7, 0, 0, 0, 0],
    [6, 0, 0, 1, 9, 5, 0, 0, 0],
    [0, 9, 8, 0, 0, 0, 0, 6, 0],
    [8, 0, 0, 0, 6, 0, 0, 0, 3],
    [4, 0, 0, 8, 0, 3, 0, 0, 1],
    [7, 0, 0, 0, 2, 0, 0, 0, 6],
    [0, 6, 0, 0, 0, 0, 2, 8, 0],
    [0, 0, 0, 4, 1, 9, 0, 0, 5],
    [0, 0, 0, 0, 8, 0, 0, 7, 9],
  ];

  static const List<List<int>> _mediumPuzzle = [
    [0, 0, 0, 2, 6, 0, 7, 0, 1],
    [6, 8, 0, 0, 7, 0, 0, 9, 0],
    [1, 9, 0, 0, 0, 4, 5, 0, 0],
    [8, 2, 0, 1, 0, 0, 0, 4, 0],
    [0, 0, 4, 6, 0, 2, 9, 0, 0],
    [0, 5, 0, 0, 0, 3, 0, 2, 8],
    [0, 0, 9, 3, 0, 0, 0, 7, 4],
    [0, 4, 0, 0, 5, 0, 0, 3, 6],
    [7, 0, 3, 0, 1, 8, 0, 0, 0],
  ];

  static const List<List<int>> _hardPuzzle = [
    [0, 2, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 6, 0, 0, 0, 0, 3],
    [0, 7, 4, 0, 8, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 3, 0, 0, 2],
    [0, 8, 0, 0, 4, 0, 0, 1, 0],
    [6, 0, 0, 5, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 1, 0, 7, 8, 0],
    [5, 0, 0, 0, 0, 9, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 4, 0],
  ];

  @override
  void initState() {
    super.initState();
    _initPuzzle();
    _startTimer();
  }

  void _initPuzzle() {
    final source = _difficulty == 'Easy'
        ? _easyPuzzle
        : _difficulty == 'Medium'
            ? _mediumPuzzle
            : _hardPuzzle;
    _userGrid = source.map((r) => List<int>.from(r)).toList();
    _locked = source
        .map((r) => r.map((v) => v != 0).toList())
        .toList();
    _selectedRow = null;
    _selectedCol = null;
    _elapsedSeconds = 0;
    _score = 0;
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_isPaused) setState(() => _elapsedSeconds++);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _timeString {
    final m = _elapsedSeconds ~/ 60;
    final s = _elapsedSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _selectCell(int row, int col) {
    if (_locked[row][col]) return;
    setState(() {
      _selectedRow = row;
      _selectedCol = col;
    });
  }

  void _inputNumber(int num) {
    if (_selectedRow == null || _selectedCol == null) return;
    if (_locked[_selectedRow!][_selectedCol!]) return;
    setState(() {
      _userGrid[_selectedRow!][_selectedCol!] = num;
      if (num != 0) _score += 2;
    });
  }

  bool _isInSameBox(int r, int c) {
    if (_selectedRow == null || _selectedCol == null) return false;
    return (r ~/ 3 == _selectedRow! ~/ 3) && (c ~/ 3 == _selectedCol! ~/ 3);
  }

  bool _isConflict(int row, int col) {
    final val = _userGrid[row][col];
    if (val == 0) return false;
    // Check row
    for (int c = 0; c < 9; c++) {
      if (c != col && _userGrid[row][c] == val) return true;
    }
    // Check col
    for (int r = 0; r < 9; r++) {
      if (r != row && _userGrid[r][col] == val) return true;
    }
    // Check 3x3
    final br = (row ~/ 3) * 3;
    final bc = (col ~/ 3) * 3;
    for (int r = br; r < br + 3; r++) {
      for (int c = bc; c < bc + 3; c++) {
        if ((r != row || c != col) && _userGrid[r][c] == val) return true;
      }
    }
    return false;
  }

  BorderSide _cellBorder(int row, int col, bool isRight, bool isBottom) {
    if (isRight && (col + 1) % 3 == 0 && col < 8) {
      return const BorderSide(color: AppColors.primary, width: 2);
    }
    if (isBottom && (row + 1) % 3 == 0 && row < 8) {
      return const BorderSide(color: AppColors.primary, width: 2);
    }
    if (isRight) return BorderSide(color: Colors.grey.shade300);
    if (isBottom) return BorderSide(color: Colors.grey.shade300);
    return BorderSide.none;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Sudoku',
            style: GoogleFonts.poppins(
                color: Colors.white, fontWeight: FontWeight.w600)),
        flexibleSpace: Container(
            decoration:
                const BoxDecoration(gradient: AppColors.primaryGradient)),
        actions: [
          Center(
            child: Text(_timeString,
                style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16)),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(_isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                color: Colors.white),
            onPressed: () => setState(() => _isPaused = !_isPaused),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
        children: [
          // Difficulty selector
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: ['Easy', 'Medium', 'Hard'].map((d) {
                final selected = _difficulty == d;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _difficulty = d;
                        _initPuzzle();
                      });
                      _startTimer();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        gradient: selected ? AppColors.primaryGradient : null,
                        color: selected ? null : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: selected
                                ? Colors.transparent
                                : Colors.grey.shade200),
                        boxShadow: selected
                            ? [
                                BoxShadow(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3))
                              ]
                            : [],
                      ),
                      child: Center(
                        child: Text(d,
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: selected
                                    ? Colors.white
                                    : AppColors.textSecondary)),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Score display
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Score: $_score pts',
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        fontSize: 14)),
                Text('Tap a cell, then pick a number',
                    style: GoogleFonts.poppins(
                        fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),

          // Sudoku grid
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: AppColors.primaryDark, width: 2.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 9),
                      itemCount: 81,
                      itemBuilder: (context, index) {
                        final row = index ~/ 9;
                        final col = index % 9;
                        final val = _userGrid[row][col];
                        final isLocked = _locked[row][col];
                        final isSelected =
                            row == _selectedRow && col == _selectedCol;
                        final isSameRow = row == _selectedRow;
                        final isSameCol = col == _selectedCol;
                        final isSameBox = _isInSameBox(row, col);
                        final isConflict = _isConflict(row, col);

                        Color bgColor;
                        if (isSelected) {
                          bgColor = AppColors.primary.withValues(alpha: 0.3);
                        } else if (isSameRow || isSameCol || isSameBox) {
                          bgColor = AppColors.primary.withValues(alpha: 0.07);
                        } else if (isLocked) {
                          bgColor = Colors.grey.shade100;
                        } else {
                          bgColor = Colors.white;
                        }

                        return GestureDetector(
                          onTap: () => _selectCell(row, col),
                          child: Container(
                            decoration: BoxDecoration(
                              color: bgColor,
                              border: Border(
                                right: _cellBorder(row, col, true, false),
                                bottom: _cellBorder(row, col, false, true),
                              ),
                            ),
                            child: Center(
                              child: val == 0
                                  ? const SizedBox.shrink()
                                  : Text(
                                      '$val',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: isLocked
                                            ? FontWeight.w800
                                            : FontWeight.w500,
                                        color: isConflict
                                            ? Colors.redAccent
                                            : isLocked
                                                ? AppColors.textPrimary
                                                : AppColors.primary,
                                      ),
                                    ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Number pad
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ...List.generate(9, (i) => i + 1).map((n) => _NumberPadBtn(
                    number: n, onTap: () => _inputNumber(n))),
                _NumberPadBtn(
                  number: 0,
                  isErase: true,
                  onTap: () => _inputNumber(0),
                ),
              ],
            ),
          ),
        ],
        ),
      ),
    );
  }
}

class _NumberPadBtn extends StatelessWidget {
  final int number;
  final VoidCallback onTap;
  final bool isErase;

  const _NumberPadBtn(
      {required this.number, required this.onTap, this.isErase = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 44,
        decoration: BoxDecoration(
          color: isErase
              ? Colors.red.withValues(alpha: 0.1)
              : AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: isErase
                  ? Colors.red.withValues(alpha: 0.3)
                  : AppColors.primary.withValues(alpha: 0.3)),
        ),
        child: Center(
          child: isErase
              ? const Icon(Icons.backspace_outlined,
                  size: 16, color: Colors.redAccent)
              : Text('$number',
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: AppColors.primary)),
        ),
      ),
    );
  }
}
