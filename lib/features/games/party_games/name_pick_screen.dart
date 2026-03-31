import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class NamePickScreen extends StatefulWidget {
  const NamePickScreen({super.key});

  @override
  State<NamePickScreen> createState() => _NamePickScreenState();
}

class _NamePickScreenState extends State<NamePickScreen>
    with SingleTickerProviderStateMixin {
  final List<String> _names = [
    'Alex', 'Jordan', 'Sam', 'Taylor', 'Morgan', 'Casey', 'Riley', 'Drew',
  ];
  final TextEditingController _inputCtrl = TextEditingController();
  String _displayName = '?';
  String? _pickedName;
  bool _picking = false;
  Timer? _cycleTimer;

  late AnimationController _scaleController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _cycleTimer?.cancel();
    _inputCtrl.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _pickRandom() {
    if (_names.isEmpty || _picking) return;
    setState(() {
      _picking = true;
      _pickedName = null;
    });

    final random = Random();
    int cycleCount = 0;
    const totalCycles = 25;

    _cycleTimer = Timer.periodic(const Duration(milliseconds: 80), (timer) {
      cycleCount++;
      final interval = cycleCount < 15
          ? 80
          : cycleCount < 20
              ? 140
              : 220;

      if (cycleCount >= totalCycles) {
        timer.cancel();
        final picked = _names[random.nextInt(_names.length)];
        setState(() {
          _displayName = picked;
          _pickedName = picked;
          _picking = false;
        });
        _scaleController.forward(from: 0);
      } else {
        setState(() {
          _displayName = _names[random.nextInt(_names.length)];
        });
        // Reschedule with increasing interval
        if (interval != 80) {
          timer.cancel();
          _cycleTimer = Timer.periodic(
            Duration(milliseconds: interval),
            (t) {
              cycleCount++;
              if (cycleCount >= totalCycles) {
                t.cancel();
                final picked = _names[random.nextInt(_names.length)];
                setState(() {
                  _displayName = picked;
                  _pickedName = picked;
                  _picking = false;
                });
                _scaleController.forward(from: 0);
              } else {
                setState(() =>
                    _displayName = _names[random.nextInt(_names.length)]);
              }
            },
          );
        }
      }
    });
  }

  void _reset() {
    _cycleTimer?.cancel();
    setState(() {
      _displayName = '?';
      _pickedName = null;
      _picking = false;
    });
  }

  void _addName() {
    final name = _inputCtrl.text.trim();
    if (name.isNotEmpty && !_names.contains(name)) {
      setState(() => _names.add(name));
      _inputCtrl.clear();
    }
  }

  void _removeName(String name) {
    setState(() {
      _names.remove(name);
      if (_pickedName == name) _reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1F0A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Name Pick',
            style: GoogleFonts.poppins(
                color: Colors.white, fontWeight: FontWeight.w700)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: _reset,
            tooltip: 'Reset',
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Big name display
            Expanded(
              child: Center(
                child: AnimatedBuilder(
                  animation: _scaleAnim,
                  builder: (ctx, child) => Transform.scale(
                    scale: _scaleAnim.value,
                    child: child,
                  ),
                  child: Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: _pickedName != null
                            ? [Colors.green.shade600, Colors.green.shade900]
                            : _picking
                                ? [
                                    const Color(0xFF16A34A),
                                    const Color(0xFF166534)
                                  ]
                                : [
                                    Colors.white.withValues(alpha: 0.1),
                                    Colors.white.withValues(alpha: 0.05)
                                  ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withValues(alpha: 0.3),
                          blurRadius: 32,
                          spreadRadius: 4,
                        ),
                      ],
                      border: Border.all(
                        color: Colors.green.withValues(alpha: 0.5),
                        width: 3,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        _displayName,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: _displayName == '?' ? 64 : 28,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            if (_pickedName != null)
              Text('🎉 $_pickedName is picked!',
                      style: GoogleFonts.poppins(
                          color: Colors.greenAccent,
                          fontWeight: FontWeight.w700,
                          fontSize: 16))
                  .animate()
                  .fadeIn()
                  .slideY(begin: 0.2, end: 0),

            const SizedBox(height: 20),

            // Add name row
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputCtrl,
                    style: GoogleFonts.poppins(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Add a name',
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
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.person_add_rounded,
                        color: Colors.white, size: 22),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Name chips
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: _names
                    .map((n) => GestureDetector(
                          onLongPress: () => _removeName(n),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: n == _pickedName
                                  ? Colors.green
                                  : Colors.white.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                  color: n == _pickedName
                                      ? Colors.greenAccent
                                      : Colors.white.withValues(alpha: 0.2)),
                            ),
                            child: Text(n,
                                style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: n == _pickedName
                                        ? FontWeight.w700
                                        : FontWeight.w400)),
                          ),
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _reset,
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2)),
                      ),
                      child: Center(
                        child: Text('Reset',
                            style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: _picking ? null : _pickRandom,
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: _picking
                            ? const LinearGradient(
                                colors: [Colors.grey, Colors.grey])
                            : const LinearGradient(
                                colors: [
                                  Color(0xFF16A34A),
                                  Color(0xFF15803D)
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: _picking
                            ? []
                            : [
                                BoxShadow(
                                    color: Colors.green.withValues(alpha: 0.4),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4))
                              ],
                      ),
                      child: Center(
                        child: Text(
                          _picking ? 'Picking...' : 'Pick Random 🎯',
                          style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 15),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
        ),
      ),
    );
  }
}
