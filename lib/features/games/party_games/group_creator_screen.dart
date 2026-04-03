import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class GroupCreatorScreen extends StatefulWidget {
  const GroupCreatorScreen({super.key});

  @override
  State<GroupCreatorScreen> createState() => _GroupCreatorScreenState();
}

class _GroupCreatorScreenState extends State<GroupCreatorScreen> {
  final List<String> _names = [
    'Alex', 'Jordan', 'Sam', 'Taylor', 'Morgan',
    'Casey', 'Riley', 'Drew', 'Quinn', 'Blake',
  ];
  final TextEditingController _nameCtrl = TextEditingController();
  int _groupCount = 2;
  List<List<String>> _groups = [];
  bool _generated = false;

  static const List<Color> _groupColors = [
    Color(0xFFE53935),
    Color(0xFFFF6B35),
    Color(0xFF10B981),
    Color(0xFFF59E0B),
    Color(0xFFEC4899),
    Color(0xFF14B8A6),
  ];

  void _generateGroups() {
    if (_names.isEmpty) return;
    final shuffled = List<String>.from(_names)..shuffle(Random());
    final groups = List.generate(_groupCount, (_) => <String>[]);
    for (int i = 0; i < shuffled.length; i++) {
      groups[i % _groupCount].add(shuffled[i]);
    }
    setState(() {
      _groups = groups;
      _generated = true;
    });
  }

  void _addName() {
    final name = _nameCtrl.text.trim();
    if (name.isNotEmpty && !_names.contains(name)) {
      setState(() {
        _names.add(name);
        _generated = false;
      });
      _nameCtrl.clear();
    }
  }

  void _removeName(String name) {
    setState(() {
      _names.remove(name);
      _generated = false;
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A2E),
      appBar: AppBar(
        backgroundColor: AppColors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Group Creator',
            style: GoogleFonts.poppins(
                color: AppColors.white, fontWeight: FontWeight.w700)),
        centerTitle: true,
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: AppColors.white.withValues(alpha: 0.15)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.group_rounded,
                      color: AppColors.primary, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Auto Group Splitter',
                            style: GoogleFonts.poppins(
                                color: AppColors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 16)),
                        Text('${_names.length} participants',
                            style: GoogleFonts.poppins(
                                color: AppColors.white.withValues(alpha: 0.6),
                                fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 100.ms),
            const SizedBox(height: 20),

            // Group count selector
            Text('Number of Groups',
                style: GoogleFonts.poppins(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14)),
            const SizedBox(height: 10),
            Row(
              children: List.generate(5, (i) {
                final n = i + 2;
                final selected = _groupCount == n;
                return GestureDetector(
                  onTap: () => setState(() {
                    _groupCount = n;
                    _generated = false;
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 48,
                    height: 48,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      gradient: selected
                          ? AppColors.primaryGradient
                          : null,
                      color: selected
                          ? null
                          : AppColors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: selected
                              ? AppColors.transparent
                              : AppColors.white.withValues(alpha: 0.2)),
                    ),
                    child: Center(
                      child: Text('$n',
                          style: GoogleFonts.poppins(
                              color: AppColors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 16)),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),

            // Add participant
            Text('Participants',
                style: GoogleFonts.poppins(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nameCtrl,
                    style: GoogleFonts.poppins(color: AppColors.white),
                    decoration: InputDecoration(
                      hintText: 'Add participant',
                      hintStyle: GoogleFonts.poppins(
                          color: AppColors.white.withValues(alpha: 0.4),
                          fontSize: 13),
                      filled: true,
                      fillColor: AppColors.white.withValues(alpha: 0.08),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none),
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
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.add_rounded,
                        color: AppColors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Name chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _names
                  .map((n) => GestureDetector(
                        onLongPress: () => _removeName(n),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color:
                                    AppColors.white.withValues(alpha: 0.25)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(n,
                                  style: GoogleFonts.poppins(
                                      color: AppColors.white,
                                      fontSize: 12)),
                              const SizedBox(width: 4),
                              GestureDetector(
                                onTap: () => _removeName(n),
                                child: Icon(Icons.close_rounded,
                                    size: 14,
                                    color: AppColors.white
                                        .withValues(alpha: 0.6)),
                              ),
                            ],
                          ),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 24),

            // Generate button
            GestureDetector(
              onTap: _generateGroups,
              child: Container(
                width: double.infinity,
                height: 54,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.4),
                        blurRadius: 14,
                        offset: const Offset(0, 5))
                  ],
                ),
                child: Center(
                  child: Text('Generate Groups 🎲',
                      style: GoogleFonts.poppins(
                          color: AppColors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16)),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Generated groups
            if (_generated) ...[
              Text('Generated Groups',
                      style: GoogleFonts.poppins(
                          color: AppColors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16))
                  .animate()
                  .fadeIn(),
              const SizedBox(height: 12),
              ..._groups.asMap().entries.map((entry) {
                final idx = entry.key;
                final group = entry.value;
                final color = _groupColors[idx % _groupColors.length];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: color.withValues(alpha: 0.4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle),
                            child: Center(
                              child: Text('${idx + 1}',
                                  style: const TextStyle(
                                      color: AppColors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text('Team ${idx + 1}',
                              style: GoogleFonts.poppins(
                                  color: color,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15)),
                          const Spacer(),
                          Text('${group.length} members',
                              style: GoogleFonts.poppins(
                                  color: color.withValues(alpha: 0.8),
                                  fontSize: 11)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: group
                            .map((name) => Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.2),
                                    borderRadius:
                                        BorderRadius.circular(10),
                                  ),
                                  child: Text(name,
                                      style: GoogleFonts.poppins(
                                          color: AppColors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500)),
                                ))
                            .toList(),
                      ),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(
                        delay: Duration(milliseconds: 100 + idx * 80))
                    .slideY(begin: 0.1, end: 0);
              }),
            ],
            const SizedBox(height: 40),
          ],
        ),
        ),
      ),
    );
  }
}

