import 'dart:async';
import 'dart:math';
import 'package:employee_engagement_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SudokuScreen extends StatefulWidget {
  const SudokuScreen({super.key});

  @override
  State<SudokuScreen> createState() => _SudokuScreenState();
}

class _SudokuScreenState extends State<SudokuScreen> {
  String selectedDifficulty = "Easy";
  late DateTime startTime;
  int score = 0;
  bool gameStarted = false;

  List<List<int>> puzzle = List.generate(9, (_) => List.filled(9, 0));
  List<List<int>> solution = List.generate(9, (_) => List.filled(9, 0));
  List<List<int>> userGrid = List.generate(9, (_) => List.filled(9, 0));

  Timer? countdownTimer;
  int remainingTime = 0;
  int hintsUsed = 0;
  int mistakesMade = 0;
  final int maxHints = 3;
  final int hintPenalty = 10;
  final int maxMistakes = 3;

  final Random _rand = Random();
  late List<List<TextEditingController>> controllers;
  bool showMistakes = false;
  List<List<bool>> wrongCells = List.generate(9, (_) => List.filled(9, false));

  @override
  void initState() {
    super.initState();
    controllers = List.generate(
      9,
      (_) => List.generate(9, (_) => TextEditingController()),
    );
  }

  bool _isSafe(List<List<int>> board, int row, int col, int num) {
    for (int x = 0; x < 9; x++) {
      if (board[row][x] == num) return false;
      if (board[x][col] == num) return false;
    }
    int startRow = row - row % 3, startCol = col - col % 3;
    for (int r = 0; r < 3; r++) {
      for (int c = 0; c < 3; c++) {
        if (board[startRow + r][startCol + c] == num) return false;
      }
    }
    return true;
  }

  bool _fillBoard(List<List<int>> board) {
    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        if (board[row][col] == 0) {
          List<int> nums = List<int>.generate(9, (i) => i + 1)..shuffle(_rand);
          for (int num in nums) {
            if (_isSafe(board, row, col, num)) {
              board[row][col] = num;
              if (_fillBoard(board)) return true;
              board[row][col] = 0;
            }
          }
          return false;
        }
      }
    }
    return true;
  }

  List<List<int>> _generateFullSolution() {
    List<List<int>> b = List.generate(9, (_) => List.filled(9, 0));
    for (int k = 0; k < 9; k += 3) {
      List<int> nums = List<int>.generate(9, (i) => i + 1)..shuffle(_rand);
      int idx = 0;
      for (int r = 0; r < 3; r++) {
        for (int c = 0; c < 3; c++) {
          b[k + r][k + c] = nums[idx++];
        }
      }
    }
    _fillBoard(b);
    return b;
  }

  void _removeCells(List<List<int>> board, int emptyCount) {
    List<int> positions = List<int>.generate(81, (i) => i)..shuffle(_rand);
    int removed = 0;
    for (int pos in positions) {
      if (removed >= emptyCount) break;
      int r = pos ~/ 9;
      int c = pos % 9;
      if (board[r][c] != 0) {
        board[r][c] = 0;
        removed++;
      }
    }
  }

  List<List<int>> _deepCopy(List<List<int>> src) =>
      src.map((row) => row.toList()).toList();

  void startGame(String difficulty) {
    setState(() {
      selectedDifficulty = difficulty;
      startTime = DateTime.now();
      score = 0;
      gameStarted = true;
      hintsUsed = 0;
      mistakesMade = 0;
      showMistakes = false;
      wrongCells = List.generate(9, (_) => List.filled(9, false));

      int emptyCells = selectedDifficulty == "Easy"
          ? 20
          : selectedDifficulty == "Medium"
          ? 40
          : 55;

      remainingTime = selectedDifficulty == "Easy"
          ? 300
          : selectedDifficulty == "Medium"
          ? 600
          : 900;

      solution = _generateFullSolution();
      puzzle = _deepCopy(solution);
      _removeCells(puzzle, emptyCells);
      userGrid = _deepCopy(puzzle);

      for (int r = 0; r < 9; r++) {
        for (int c = 0; c < 9; c++) {
          controllers[r][c].text = userGrid[r][c] == 0
              ? ''
              : userGrid[r][c].toString();
        }
      }

      countdownTimer?.cancel();
      countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (remainingTime > 0) {
          setState(() => remainingTime--);
        } else {
          t.cancel();
          _timeUp();
        }
      });
    });
  }

  void _timeUp() {
    setState(() {
      gameStarted = false;
      score = 0;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("⏰ Time's up! You scored 0 points.")),
    );
  }

  void completeGame() {
    setState(() {
      showMistakes = true;
      wrongCells = List.generate(9, (_) => List.filled(9, false));
    });

    bool correct = true;
    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        if (userGrid[i][j] != solution[i][j]) {
          wrongCells[i][j] = true;
          correct = false;
        }
      }
    }

    if (!correct) {
      mistakesMade++;
      if (mistakesMade >= maxMistakes) {
        countdownTimer?.cancel();
        setState(() {
          gameStarted = false;
          score = 0;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("❌ 3 Mistakes! Game Over. Score: 0")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("❌ Wrong! Mistakes: $mistakesMade/$maxMistakes"),
          ),
        );
      }
      return;
    }

    countdownTimer?.cancel();
    final endTime = DateTime.now();
    final timeTaken = endTime.difference(startTime).inSeconds;

    int basePoints = selectedDifficulty == "Easy"
        ? 50
        : selectedDifficulty == "Medium"
        ? 100
        : 200;

    int multiplier = selectedDifficulty == "Choose"
        ? 1
        : selectedDifficulty == "Medium"
        ? 2
        : 3;

    int penalty = (timeTaken ~/ 5) + (hintsUsed * hintPenalty);
    int finalScore = (basePoints * multiplier) - penalty;

    setState(() {
      score = finalScore > 0 ? finalScore : 0;
      gameStarted = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("✅ Correct! You scored $score points.")),
    );
  }

  void useHint() {
    if (!gameStarted) return;

    if (hintsUsed >= maxHints) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ No more hints available!")),
      );
      return;
    }

    List<List<int>> emptyCells = [];
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (userGrid[r][c] == 0) emptyCells.add([r, c]);
      }
    }

    if (emptyCells.isEmpty) return;

    final hintCell = emptyCells[_rand.nextInt(emptyCells.length)];
    int r = hintCell[0];
    int c = hintCell[1];

    setState(() {
      userGrid[r][c] = solution[r][c];
      controllers[r][c].text = solution[r][c].toString();
      hintsUsed++;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("💡 Hint used! ($hintsUsed/$maxHints)")),
    );
  }

  // UI Section

  Widget buildSudokuGrid() {
    return AspectRatio(
      aspectRatio: 1,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 81,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 9,
        ),
        itemBuilder: (context, index) {
          int row = index ~/ 9;
          int col = index % 9;
          bool isFixed = puzzle[row][col] != 0;

          BorderSide thick = const BorderSide(width: 2);
          BorderSide thin = const BorderSide(width: 0.5);
          Border border = Border(
            top: row % 3 == 0 ? thick : thin,
            left: col % 3 == 0 ? thick : thin,
            right: col == 8 ? thick : thin,
            bottom: row == 8 ? thick : thin,
          );

          return Container(
            decoration: BoxDecoration(
              color: isFixed
                  ? Colors.grey.shade200
                  : (showMistakes && wrongCells[row][col])
                  ? Colors.red.shade200
                  : Colors.white,
              border: border,
            ),
            child: Center(
              child: isFixed
                  ? Text(
                      puzzle[row][col].toString(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : TextField(
                      controller: controllers[row][col],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(RegExp(r'[1-9]')),
                        LengthLimitingTextInputFormatter(1),
                      ],
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.blue, // Always blue, no live red
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        counterText: "",
                      ),
                      onChanged: (val) {
                        setState(() {
                          if (val.isEmpty) {
                            userGrid[row][col] = 0;
                          } else {
                            final n = int.tryParse(val);
                            userGrid[row][col] = (n != null && n >= 1 && n <= 9)
                                ? n
                                : 0;
                          }
                        });
                      },
                    ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String minutes = (remainingTime ~/ 60).toString().padLeft(2, '0');
    String seconds = (remainingTime % 60).toString().padLeft(2, '0');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Sudoku'),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        surfaceTintColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.shade300, height: 1),
        ),
      ),
      body: SafeArea(
        top: false,
        bottom: true,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                children: [
                  const Text('Difficulty:'),
                  Spacer(),
                  DropdownButton<String>(
                    value: selectedDifficulty,
                    items: ['Easy', 'Medium', 'Hard']
                        .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                        .toList(),
                    onChanged: (d) {
                      if (d != null) startGame(d);
                    },
                  ),
                  const Spacer(),
                  if (gameStarted)
                    Text(
                      '⏱ $minutes:$seconds',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  const SizedBox(width: 8),
                  Text('Score: $score', style: const TextStyle(fontSize: 16)),
                ],
              ),
              const SizedBox(height: 12),
              if (gameStarted)
                Expanded(child: buildSudokuGrid())
              else
                Expanded(
                  child: Center(
                    child: Text(
                      'Press a difficulty to start a new puzzle',
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              if (gameStarted)
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: completeGame,
                        child: const Text('Submit Solution'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: useHint,
                        child: Text('Hint ($hintsUsed/$maxHints)'),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
