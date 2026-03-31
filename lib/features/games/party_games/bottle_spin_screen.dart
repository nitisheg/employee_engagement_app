import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BottleSpinScreen extends StatefulWidget {
  const BottleSpinScreen({super.key});

  @override
  State<BottleSpinScreen> createState() => _BottleSpinScreenState();
}

class _BottleSpinScreenState extends State<BottleSpinScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _currentAngle = 0;
  bool _spinning = false;
  String? _selectedName;

  final List<String> _names = [
    'Alex', 'Jordan', 'Sam', 'Taylor', 'Morgan', 'Casey', 'Riley', 'Drew'
  ];

  final TextEditingController _nameInputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _animation = Tween<double>(begin: 0, end: 0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    _nameInputController.dispose();
    super.dispose();
  }

  void _spin() {
    if (_spinning || _names.isEmpty) return;
    final random = Random();
    final extraSpins = (4 + random.nextInt(4)) * 2 * pi;
    final targetAngle = _currentAngle + extraSpins + random.nextDouble() * 2 * pi;

    setState(() {
      _spinning = true;
      _selectedName = null;
    });

    _animation = Tween<double>(begin: _currentAngle, end: targetAngle)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.decelerate));

    _controller.reset();
    _controller.forward().then((_) {
      _currentAngle = targetAngle % (2 * pi);
      // Which name is pointed at (top of circle = angle 0)
      if (_names.isNotEmpty) {
        final anglePerName = 2 * pi / _names.length;
        final normalised = (2 * pi - (_currentAngle % (2 * pi))) % (2 * pi);
        final idx = (normalised / anglePerName).floor() % _names.length;
        setState(() {
          _selectedName = _names[idx];
          _spinning = false;
        });
        _showResult(_names[idx]);
      }
    });
  }

  void _showResult(String name) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🍾', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text('It\'s $name\'s turn!',
                style: GoogleFonts.poppins(
                    fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text('Truth or Dare for $name!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.orange.shade800,
                      fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.orange),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Truth',
                        style: GoogleFonts.poppins(
                            color: Colors.orange,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Dare',
                        style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _addName() {
    final name = _nameInputController.text.trim();
    if (name.isNotEmpty && !_names.contains(name)) {
      setState(() => _names.add(name));
      _nameInputController.clear();
    }
  }

  void _removeName(String name) {
    setState(() => _names.remove(name));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1000),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Bottle Spin',
            style: GoogleFonts.poppins(
                color: Colors.white, fontWeight: FontWeight.w700)),
        centerTitle: true,
      ),
      body: SafeArea(
        top: false,
        child: Column(
        children: [
          const SizedBox(height: 8),
          // Participants circle + bottle
          Expanded(
            child: Center(
              child: SizedBox(
                width: 300,
                height: 300,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Names around circle
                    ..._names.asMap().entries.map((entry) {
                      final i = entry.key;
                      final name = entry.value;
                      final angle =
                          (2 * pi / _names.length) * i - pi / 2;
                      const r = 130.0;
                      final x = 150 + r * cos(angle);
                      final y = 150 + r * sin(angle);
                      final isSelected = name == _selectedName;
                      return Positioned(
                        left: x - 28,
                        top: y - 18,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.orange
                                : Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: isSelected
                                    ? Colors.orangeAccent
                                    : Colors.white.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            name,
                            style: GoogleFonts.poppins(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.white.withValues(alpha: 0.9),
                                fontSize: 11,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w400),
                          ),
                        ),
                      );
                    }),

                    // Outer circle
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.orange.withValues(alpha: 0.3),
                            width: 2),
                        color: Colors.white.withValues(alpha: 0.05),
                      ),
                    ),

                    // Spinning bottle
                    AnimatedBuilder(
                      animation: _spinning
                          ? _animation
                          : AlwaysStoppedAnimation(_currentAngle),
                      builder: (ctx, child) => Transform.rotate(
                        angle: _spinning
                            ? _animation.value
                            : _currentAngle,
                        child: child,
                      ),
                      child: CustomPaint(
                        size: const Size(200, 200),
                        painter: _BottlePainter(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Add name field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nameInputController,
                    style: GoogleFonts.poppins(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Add participant name',
                      hintStyle: GoogleFonts.poppins(
                          color: Colors.white.withValues(alpha: 0.4),
                          fontSize: 13),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                    ),
                    onSubmitted: (_) => _addName(),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _addName,
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.add_rounded,
                        color: Colors.white, size: 22),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Name chips
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: _names
                  .map((name) => GestureDetector(
                        onLongPress: () => _removeName(name),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: Colors.orange.withValues(alpha: 0.4)),
                          ),
                          child: Text(name,
                              style: GoogleFonts.poppins(
                                  color: Colors.orange,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 12),

          // Spin button
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 36),
            child: GestureDetector(
              onTap: _spinning ? null : _spin,
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  gradient: _spinning
                      ? const LinearGradient(
                          colors: [Colors.grey, Colors.grey])
                      : const LinearGradient(
                          colors: [Colors.orange, Color(0xFFEA580C)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: _spinning
                      ? []
                      : [
                          BoxShadow(
                              color: Colors.orange.withValues(alpha: 0.4),
                              blurRadius: 14,
                              offset: const Offset(0, 5))
                        ],
                ),
                child: Center(
                  child: Text(
                    _spinning ? 'Spinning...' : 'SPIN 🍾',
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        letterSpacing: 1),
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

class _BottlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Bottle body (line)
    paint.color = Colors.orange;
    canvas.drawLine(
      Offset(center.dx, center.dy - size.height * 0.38),
      Offset(center.dx, center.dy + size.height * 0.38),
      paint,
    );

    // Bottle neck (arrowhead at top)
    final arrowPaint = Paint()
      ..color = Colors.orangeAccent
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(center.dx, center.dy - size.height * 0.42)
      ..lineTo(center.dx - 8, center.dy - size.height * 0.30)
      ..lineTo(center.dx + 8, center.dy - size.height * 0.30)
      ..close();
    canvas.drawPath(path, arrowPaint);

    // Center dot
    canvas.drawCircle(
        center, 8, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
