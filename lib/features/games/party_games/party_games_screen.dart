import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import 'spin_wheel_screen.dart';
import 'bottle_spin_screen.dart';
import 'name_pick_screen.dart';
import 'group_creator_screen.dart';
import 'zip_game_screen.dart';

class PartyGamesScreen extends StatelessWidget {
  const PartyGamesScreen({super.key});

  static const List<Map<String, dynamic>> _games = [
    {
      'title': 'Spin Wheel',
      'desc': 'Spin to win prizes & rewards',
      'icon': Icons.rotate_right_rounded,
      'color': Colors.purple,
    },
    {
      'title': 'Bottle Spin',
      'desc': 'Truth or dare for the team',
      'icon': Icons.wine_bar_rounded,
      'color': Colors.orange,
    },
    {
      'title': 'Name Pick',
      'desc': 'Random name selector',
      'icon': Icons.person_search_rounded,
      'color': Colors.green,
    },
    {
      'title': 'Group Creator',
      'desc': 'Auto-split into random teams',
      'icon': Icons.group_rounded,
      'color': Colors.blue,
    },
    {
      'title': 'Zip Game',
      'desc': 'Lightning-fast word challenge',
      'icon': Icons.flash_on_rounded,
      'color': Colors.red,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 150,
            backgroundColor: Colors.deepPurple,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF7C3AED), Color(0xFFDB2777)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),

              ),
            ),
            title: Text('Party Games 🎉',
                style: GoogleFonts.poppins(
                    color: Colors.white, fontWeight: FontWeight.w600)),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 0.88,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final g = _games[i];
                  final color = g['color'] as MaterialColor;
                  return GestureDetector(
                    onTap: () {
                      Widget screen;
                      switch (i) {
                        case 0:
                          screen = const SpinWheelScreen();
                          break;
                        case 1:
                          screen = const BottleSpinScreen();
                          break;
                        case 2:
                          screen = const NamePickScreen();
                          break;
                        case 3:
                          screen = const GroupCreatorScreen();
                          break;
                        default:
                          screen = const ZipGameScreen();
                      }
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => screen));
                    },
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                              color: color.withValues(alpha: 0.18),
                              blurRadius: 14,
                              offset: const Offset(0, 5))
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(g['icon'] as IconData,
                                color: color.shade700, size: 28),
                          ),
                          const Spacer(),
                          Text(g['title'] as String,
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                  color: AppColors.textPrimary)),
                          const SizedBox(height: 4),
                          Text(g['desc'] as String,
                              style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                  height: 1.4),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [color.shade400, color.shade700],
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text('Play Now',
                                style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12)),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(
                      delay: Duration(milliseconds: 100 + i * 70))
                      .slideY(begin: 0.08, end: 0);
                },
                childCount: _games.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}
