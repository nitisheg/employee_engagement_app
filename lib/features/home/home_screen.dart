import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/common_widgets.dart';
import '../../providers/auth_provider.dart';
import '../games/games_hub_screen.dart';
import '../games/quiz_screen.dart';
import '../games/sudoku_screen.dart';
import '../games/party_games/party_games_screen.dart';
import '../challenges/challenges_screen.dart';
import '../rewards/rewards_screen.dart';
import '../certifications/certifications_screen.dart';
import '../attendance/attendance_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _getTimeBasedGreeting() {
    final now = DateTime.now();
    final hour = now.hour;

    if (hour >= 5 && hour < 12) {
      return 'Good Morning';
    } else if (hour >= 12 && hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    final dashboard = authProvider.dashboard;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: (MediaQuery.of(context).size.height * 0.22).clamp(
              150.0,
              210.0,
            ),
            pinned: true,
            stretch: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      user?.initials ?? '--',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${_getTimeBasedGreeting()}, ${user?.name.split(' ').first ?? 'Employee'}! 👋",
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),

                                    Text(
                                      'Ready to earn points today?',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white.withValues(
                                          alpha: 0.8,
                                        ),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Stack(
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.notifications_outlined,
                                    color: Colors.white,
                                    size: 26,
                                  ),
                                  onPressed: () {},
                                ),
                                Positioned(
                                  right: 10,
                                  top: 10,
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: AppColors.secondary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _MiniStatChip(
                              icon: Icons.stars_rounded,
                              label:
                                  '${dashboard?.points.total ?? user?.totalPoints ?? 0} pts',
                              color: AppColors.gold,
                            ),
                            const SizedBox(width: 8),
                            _MiniStatChip(
                              icon: Icons.leaderboard_rounded,
                              label:
                                  'Rank #${dashboard?.points.rank ?? user?.rank ?? 0}',
                              color: Colors.lightBlueAccent,
                            ),
                            const SizedBox(width: 8),
                            _MiniStatChip(
                              icon: Icons.local_fire_department_rounded,
                              label: '${user?.streakDays ?? 0} Day Streak',
                              color: AppColors.secondary,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (dashboard != null)
                          Row(
                            children: [
                              _MiniStatChip(
                                icon: Icons.check_circle_outline_rounded,
                                label: '${dashboard.quizzes.taken} taken',
                                color: AppColors.success,
                              ),
                              const SizedBox(width: 8),
                              _MiniStatChip(
                                icon: Icons.quiz_rounded,
                                label:
                                    '${dashboard.quizzes.totalActive} active',
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 8),
                              _MiniStatChip(
                                icon: Icons.show_chart_rounded,
                                label:
                                    '${dashboard.quizzes.percentage}% complete',
                                color: AppColors.warning,
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: (MediaQuery.of(context).size.width * 0.042).clamp(
                  12.0,
                  24.0,
                ),
                vertical: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionHeader(
                    title: 'Quick Actions',
                    // actionLabel: 'See All',
                    onAction: () {},
                  ).animate().fadeIn(delay: 100.ms),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 90,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _QuickActionItem(
                          icon: Icons.check_circle_outline_rounded,
                          label: 'Check In',
                          color: AppColors.success,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AttendanceScreen(),
                            ),
                          ),
                        ),
                        _QuickActionItem(
                          icon: Icons.quiz_outlined,
                          label: 'Daily Quiz',
                          color: AppColors.primary,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const QuizScreen(),
                            ),
                          ),
                        ),
                        _QuickActionItem(
                          icon: Icons.flag_outlined,
                          label: 'Challenges',
                          color: AppColors.warning,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ChallengesScreen(),
                            ),
                          ),
                        ),
                        _QuickActionItem(
                          icon: Icons.card_giftcard_rounded,
                          label: 'Rewards',
                          color: AppColors.secondary,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RewardsScreen(),
                            ),
                          ),
                        ),
                        _QuickActionItem(
                          icon: Icons.workspace_premium_rounded,
                          label: 'Certifications',
                          color: Colors.teal,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CertificationsScreen(),
                            ),
                          ),
                        ),
                        _QuickActionItem(
                          icon: Icons.games_rounded,
                          label: 'Games',
                          color: Colors.deepPurple,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const GamesHubScreen(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 150.ms).slideX(begin: 0.1, end: 0),
                  const SizedBox(height: 24),

                  // Active Challenges
                  SectionHeader(
                    title: 'Active Challenges',
                    actionLabel: 'View All',
                    onAction: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ChallengesScreen(),
                      ),
                    ),
                  ).animate().fadeIn(delay: 200.ms),
                  const SizedBox(height: 12),
                  _ChallengeCard(
                    title: '7-Day Quiz Streak',
                    description: 'Complete daily quizzes for 7 days',
                    progress: 0.71,
                    daysLeft: 2,
                    points: 300,
                    color: AppColors.primary,
                  ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.1, end: 0),
                  const SizedBox(height: 10),
                  _ChallengeCard(
                    title: 'Team Fitness Challenge',
                    description: 'Log 10,000 steps daily with your team',
                    progress: 0.45,
                    daysLeft: 5,
                    points: 500,
                    color: AppColors.success,
                  ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0),
                  const SizedBox(height: 24),

                  // Games Section
                  SectionHeader(
                    title: 'Games',
                    actionLabel: 'All Games',
                    onAction: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const GamesHubScreen()),
                    ),
                  ).animate().fadeIn(delay: 350.ms),
                  const SizedBox(height: 12),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;

                      int crossAxisCount;
                      if (width > 900) {
                        crossAxisCount = 5;
                      } else if (width > 600) {
                        crossAxisCount = 4;
                      } else {
                        crossAxisCount = 3;
                      }

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: width > 600 ? 0.9 : 0.78,
                        ),
                        itemCount: 3,
                        itemBuilder: (context, index) {
                          final items = [
                            {
                              "title": "Daily Quiz",
                              "subtitle": "Up to 100 pts",
                              "icon": Icons.quiz_rounded,
                              "color": AppColors.primary,
                              "screen": const QuizScreen(),
                            },
                            {
                              "title": "Sudoku",
                              "subtitle": "Up to 200 pts",
                              "icon": Icons.grid_on_rounded,
                              "color": Colors.teal,
                              "screen": const SudokuScreen(),
                            },
                            {
                              "title": "Party Games",
                              "subtitle": "Team fun",
                              "icon": Icons.celebration_rounded,
                              "color": AppColors.secondary,
                              "screen": const PartyGamesScreen(),
                            },
                          ];

                          final item = items[index];

                          return GameCard(
                            title: item["title"] as String,
                            subtitle: item["subtitle"] as String,
                            icon: item["icon"] as IconData,
                            color: item["color"] as Color,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => item["screen"] as Widget,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ).animate().fadeIn(delay: 400.ms),
                  const SizedBox(height: 24),

                  // Today's Highlight
                  SectionHeader(
                    title: "Today's Highlight",
                  ).animate().fadeIn(delay: 450.ms),
                  const SizedBox(height: 12),
                  AppCard(
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.quiz_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Daily Quiz Available!",
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                "Earn up to 100 pts • 10 questions",
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Play',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 500.ms),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _MiniStatChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final itemWidth = (screenWidth * 0.19).clamp(64.0, 88.0);
    final iconSize = (itemWidth * 0.72).clamp(46.0, 60.0);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: itemWidth,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: iconSize,
              height: iconSize,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: color.withValues(alpha: 0.3)),
              ),
              child: Icon(icon, color: color, size: iconSize * 0.46),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: (screenWidth * 0.026).clamp(9.0, 12.0),
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _ChallengeCard extends StatelessWidget {
  final String title;
  final String description;
  final double progress;
  final int daysLeft;
  final int points;
  final Color color;

  const _ChallengeCard({
    required this.title,
    required this.description,
    required this.progress,
    required this.daysLeft,
    required this.points,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      description,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              PointsBadge(points: points),
            ],
          ),
          const SizedBox(height: 12),
          LinearPercentIndicator(
            lineHeight: 8,
            percent: progress,
            backgroundColor: color.withValues(alpha: 0.15),
            progressColor: color,
            barRadius: const Radius.circular(4),
            padding: EdgeInsets.zero,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(progress * 100).toInt()}% complete',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '$daysLeft days left',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
