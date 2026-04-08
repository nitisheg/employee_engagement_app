import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class ZipGameScreen extends StatefulWidget {
  const ZipGameScreen({super.key});

  @override
  State<ZipGameScreen> createState() => _ZipGameScreenState();
}

class _ZipGameScreenState extends State<ZipGameScreen> {
  static const int _rows = 6;
  static const int _cols = 6;

  static const List<Cell> _solution = [
    Cell(0, 0),
    Cell(0, 1),
    Cell(0, 2),
    Cell(0, 3),
    Cell(0, 4),
    Cell(0, 5),
    Cell(1, 5),
    Cell(1, 4),
    Cell(1, 3),
    Cell(1, 2),
    Cell(1, 1),
    Cell(1, 0),
    Cell(2, 0),
    Cell(2, 1),
    Cell(2, 2),
    Cell(2, 3),
    Cell(2, 4),
    Cell(2, 5),
    Cell(3, 5),
    Cell(3, 4),
    Cell(3, 3),
    Cell(3, 2),
    Cell(3, 1),
    Cell(3, 0),
    Cell(4, 0),
    Cell(4, 1),
    Cell(4, 2),
    Cell(4, 3),
    Cell(4, 4),
    Cell(4, 5),
    Cell(5, 5),
    Cell(5, 4),
    Cell(5, 3),
    Cell(5, 2),
    Cell(5, 1),
    Cell(5, 0),
  ];

  static final Map<Cell, int> _clues = {
    Cell(0, 0): 1,
    Cell(1, 3): 2,
    Cell(2, 3): 3,
    Cell(3, 2): 4,
    Cell(4, 5): 5,
    Cell(5, 0): 6,
  };

  List<Cell> _path = <Cell>[];
  int _nextRequired = 2;
  bool _isSolved = false;
  String _statusText = 'Drag from 1 to connect all cells.';

  int get _maxClue => _clues.values.reduce(max);

  void _clearBoard() {
    setState(() {
      _path = <Cell>[];
      _nextRequired = 2;
      _isSolved = false;
      _statusText = 'Board cleared. Start from 1.';
    });
  }

  void _applyHint() {
    if (_isSolved) return;

    if (_path.isEmpty) {
      setState(() {
        _path = <Cell>[_solution.first];
        _statusText = 'Hint: start at 1 and keep going.';
      });
      return;
    }

    final prefix = _matchingPrefixLength();
    if (prefix < _path.length || prefix >= _solution.length) {
      setState(() {
        _statusText = 'Hint unavailable here. Use Clear and try again.';
      });
      return;
    }

    final nextCell = _solution[prefix];
    if (_canExtendTo(nextCell)) {
      _extendTo(nextCell);
      setState(() {
        _statusText = 'Hint added.';
      });
    }
  }

  int _matchingPrefixLength() {
    var i = 0;
    while (i < _path.length &&
        i < _solution.length &&
        _path[i] == _solution[i]) {
      i++;
    }
    return i;
  }

  bool _inBounds(Cell cell) {
    return cell.row >= 0 &&
        cell.row < _rows &&
        cell.col >= 0 &&
        cell.col < _cols;
  }

  bool _isAdjacent(Cell a, Cell b) {
    return (a.row - b.row).abs() + (a.col - b.col).abs() == 1;
  }

  bool _canExtendTo(Cell cell) {
    if (!_inBounds(cell)) return false;

    if (_path.isEmpty) {
      return _clues[cell] == 1;
    }

    final last = _path.last;
    if (cell == last) return false;
    if (!_isAdjacent(last, cell)) return false;

    if (_path.length > 1 && cell == _path[_path.length - 2]) {
      return true;
    }

    if (_path.contains(cell)) return false;

    final clue = _clues[cell];
    if (clue != null && clue != _nextRequired) return false;

    return true;
  }

  void _extendTo(Cell cell) {
    if (!_canExtendTo(cell) || _isSolved) return;

    setState(() {
      if (_path.isNotEmpty &&
          _path.length > 1 &&
          cell == _path[_path.length - 2]) {
        final removed = _path.removeLast();
        final removedClue = _clues[removed];
        if (removedClue != null &&
            removedClue == _nextRequired - 1 &&
            removedClue > 1) {
          _nextRequired--;
        }
        _statusText = 'Backtracked.';
        return;
      }

      _path.add(cell);

      final clue = _clues[cell];
      if (clue != null && clue == _nextRequired) {
        _nextRequired++;
      }

      final filledAll = _path.length == _rows * _cols;
      final visitedAllNumbers = _nextRequired == _maxClue + 1;
      final endedAtLast = _clues[cell] == _maxClue;

      if (filledAll && visitedAllNumbers && endedAtLast) {
        _isSolved = true;
        _statusText = 'Solved! Great run.';
      } else {
        _statusText = 'Connect $_nextRequired next.';
      }
    });
  }

  Cell? _cellFromOffset(Offset offset, double boardSide) {
    if (offset.dx < 0 ||
        offset.dy < 0 ||
        offset.dx >= boardSide ||
        offset.dy >= boardSide) {
      return null;
    }

    final cellSize = boardSide / _cols;
    final col = offset.dx ~/ cellSize;
    final row = offset.dy ~/ cellSize;
    final cell = Cell(row, col);
    return _inBounds(cell) ? cell : null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F2EF),
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        foregroundColor: AppColors.black,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Zip',
          style: GoogleFonts.poppins(
            color: AppColors.black,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _clearBoard,
            child: Text(
              'Clear',
              style: GoogleFonts.poppins(
                color: AppColors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: _applyHint,
            child: Text(
              'Hint',
              style: GoogleFonts.poppins(
                color: const Color(0xFF0A66C2),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 6),
              AspectRatio(
                aspectRatio: 1,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final boardSide = min(
                      constraints.maxWidth,
                      constraints.maxHeight,
                    );
                    return Center(
                      child: GestureDetector(
                        onPanStart: (details) {
                          final cell = _cellFromOffset(
                            details.localPosition,
                            boardSide,
                          );
                          if (cell != null) _extendTo(cell);
                        },
                        onPanUpdate: (details) {
                          final cell = _cellFromOffset(
                            details.localPosition,
                            boardSide,
                          );
                          if (cell != null) _extendTo(cell);
                        },
                        child: SizedBox(
                          width: boardSide,
                          height: boardSide,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(22),
                            child: CustomPaint(
                              painter: _ZipBoardPainter(
                                rows: _rows,
                                cols: _cols,
                                path: _path,
                                clues: _clues,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _statusText,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _isSolved
                        ? AppColors.success
                        : AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'How to play',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '1. Start from circle 1.',
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                    Text(
                      '2. Drag orthogonally to connect 2, 3, ... in order.',
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                    Text(
                      '3. Fill every grid cell with one continuous path.',
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Cell {
  final int row;
  final int col;

  const Cell(this.row, this.col);

  @override
  bool operator ==(Object other) {
    return other is Cell && other.row == row && other.col == col;
  }

  @override
  int get hashCode => Object.hash(row, col);
}

class _ZipBoardPainter extends CustomPainter {
  final int rows;
  final int cols;
  final List<Cell> path;
  final Map<Cell, int> clues;

  const _ZipBoardPainter({
    required this.rows,
    required this.cols,
    required this.path,
    required this.clues,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = const Color(0xFFF8F8F8);
    canvas.drawRect(Offset.zero & size, bgPaint);

    final cellSize = size.width / cols;

    final gridPaint = Paint()
      ..color = const Color(0xFFB0B0B0)
      ..strokeWidth = 1;

    for (var r = 0; r <= rows; r++) {
      final y = r * cellSize;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
    for (var c = 0; c <= cols; c++) {
      final x = c * cellSize;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    final visitedPaint = Paint()..color = const Color(0x1A0A66C2);
    for (final cell in path) {
      final rect = Rect.fromLTWH(
        cell.col * cellSize,
        cell.row * cellSize,
        cellSize,
        cellSize,
      );
      canvas.drawRect(rect, visitedPaint);
    }

    final linePaint = Paint()
      ..color = Colors.black
      ..strokeWidth = cellSize * 0.20
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (var i = 1; i < path.length; i++) {
      final a = path[i - 1];
      final b = path[i];
      final p1 = Offset((a.col + 0.5) * cellSize, (a.row + 0.5) * cellSize);
      final p2 = Offset((b.col + 0.5) * cellSize, (b.row + 0.5) * cellSize);
      canvas.drawLine(p1, p2, linePaint);
    }

    for (final entry in clues.entries) {
      final cell = entry.key;
      final number = entry.value;
      final center = Offset(
        (cell.col + 0.5) * cellSize,
        (cell.row + 0.5) * cellSize,
      );

      final circlePaint = Paint()..color = Colors.black;
      canvas.drawCircle(center, cellSize * 0.28, circlePaint);

      final textPainter = TextPainter(
        text: TextSpan(
          text: '$number',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: cellSize * 0.28,
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(
          center.dx - textPainter.width / 2,
          center.dy - textPainter.height / 2,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ZipBoardPainter oldDelegate) {
    return oldDelegate.path != path || oldDelegate.clues != clues;
  }
}
