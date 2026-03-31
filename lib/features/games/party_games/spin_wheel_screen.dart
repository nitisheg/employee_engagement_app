import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class SpinWheelScreen extends StatefulWidget {
  const SpinWheelScreen({super.key});

  @override
  State<SpinWheelScreen> createState() => _SpinWheelScreenState();
}

class _SpinWheelScreenState extends State<SpinWheelScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _currentAngle = 0;
  String? _result;
  bool _spinning = false;

  static const List<String> _segments = [
    'Extra Leave',
    'Gift Card',
    '100 Pts',
    'Team Lunch',
    '200 Pts',
    'Coffee Treat',
    '50 Pts',
    'Mystery Prize',
  ];

  static const List<Color> _colors = [
    Color(0xFFE53935),
    Color(0xFFFF6B35),
    Color(0xFF10B981),
    Color(0xFFF59E0B),
    Color(0xFFEC4899),
    Color(0xFF14B8A6),
    Color(0xFF00ACC1),
    Color(0xFFEF4444),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _animation = Tween<double>(begin: 0, end: 0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _spin() {
    if (_spinning) return;
    final random = Random();
    final extraSpins = (5 + random.nextInt(5)) * 2 * pi;
    final landingAngle = random.nextDouble() * 2 * pi;
    final targetAngle = _currentAngle + extraSpins + landingAngle;

    setState(() {
      _spinning = true;
      _result = null;
    });

    _animation = Tween<double>(begin: _currentAngle, end: targetAngle)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.decelerate));

    _controller.reset();
    _controller.forward().then((_) {
      _currentAngle = targetAngle % (2 * pi);
      final segmentAngle = 2 * pi / _segments.length;
      // Determine which segment is at the top (pointer is at top = 0 / 2pi)
      final normalised = (2 * pi - (_currentAngle % (2 * pi))) % (2 * pi);
      final index = (normalised / segmentAngle).floor() % _segments.length;
      setState(() {
        _result = _segments[index];
        _spinning = false;
      });
      _showResult(_segments[index], _colors[index]);
    });
  }

  void _showResult(String result, Color color) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text('You won!',
                style: GoogleFonts.poppins(
                    fontSize: 18, color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(result,
                  style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: color)),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Awesome!',
                  style: GoogleFonts.poppins(
                      color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A0A2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Spin Wheel',
            style: GoogleFonts.poppins(
                color: Colors.white, fontWeight: FontWeight.w700)),
        centerTitle: true,
      ),
      body: SafeArea(
        top: false,
        child: Column(
        children: [
          const SizedBox(height: 16),
          Text('Spin for a prize!',
              style: GoogleFonts.poppins(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 14)),
          const SizedBox(height: 24),

          // Pointer arrow
          const Icon(Icons.arrow_drop_down_rounded,
              color: Colors.white, size: 36),

          // Wheel
          Expanded(
            child: Center(
              child: AnimatedBuilder(
                animation: _spinning ? _animation : AlwaysStoppedAnimation(_currentAngle),
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _spinning ? _animation.value : _currentAngle,
                    child: child,
                  );
                },
                child: CustomPaint(
                  size: const Size(300, 300),
                  painter: _WheelPainter(
                    segments: _segments,
                    colors: _colors,
                  ),
                ),
              ),
            ),
          ),

          // Result text
          if (_result != null)
            Text('Result: $_result',
                style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16))
                .animate()
                .fadeIn()
                .slideY(begin: 0.2, end: 0),
          const SizedBox(height: 16),

          // Spin button
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 0, 32, 40),
            child: GestureDetector(
              onTap: _spinning ? null : _spin,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 60,
                decoration: BoxDecoration(
                  gradient: _spinning
                      ? const LinearGradient(
                          colors: [Colors.grey, Colors.grey])
                      : const LinearGradient(
                          colors: [Color(0xFF7C3AED), Color(0xFFDB2777)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: _spinning
                      ? []
                      : [
                          BoxShadow(
                              color: const Color(0xFF7C3AED)
                                  .withValues(alpha: 0.5),
                              blurRadius: 16,
                              offset: const Offset(0, 6))
                        ],
                ),
                child: Center(
                  child: Text(
                    _spinning ? 'Spinning...' : 'SPIN 🎰',
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        letterSpacing: 1.2),
                  ),
                ),
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }
}

class _WheelPainter extends CustomPainter {
  final List<String> segments;
  final List<Color> colors;

  _WheelPainter({required this.segments, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final segAngle = 2 * pi / segments.length;
    final paint = Paint()..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.white
      ..strokeWidth = 2;

    for (int i = 0; i < segments.length; i++) {
      final startAngle = i * segAngle - pi / 2;
      paint.color = colors[i];
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        segAngle,
        true,
        paint,
      );
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        segAngle,
        true,
        borderPaint,
      );

      // Draw text
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(startAngle + segAngle / 2);
      final textPainter = TextPainter(
        text: TextSpan(
          text: segments[i],
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      )..layout(maxWidth: radius * 0.7);
      textPainter.paint(
        canvas,
        Offset(radius * 0.3, -textPainter.height / 2),
      );
      canvas.restore();
    }

    // Center circle
    final centerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 20, centerPaint);
    final centerBorder = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, 20, centerBorder);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
