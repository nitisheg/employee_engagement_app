import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/common_widgets.dart';

class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({super.key});

  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: Row(
                      children: [
                        if (Navigator.of(context).canPop())
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                                color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                        if (Navigator.of(context).canPop())
                          const SizedBox(width: 8),
                        Expanded(
                          child: Text('Challenges',
                              style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700)),
                        ),
                        const Icon(Icons.flag_rounded,
                            color: Colors.white, size: 26),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  TabBar(
                    controller: _tabController,
                    indicatorColor: Colors.white,
                    indicatorWeight: 3,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white.withValues(alpha: 0.6),
                    labelStyle: GoogleFonts.poppins(
                        fontSize: 14, fontWeight: FontWeight.w600),
                    tabs: const [
                      Tab(text: 'Active'),
                      Tab(text: 'Available'),
                      Tab(text: 'Completed'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                _ActiveTab(),
                _AvailableTab(),
                _CompletedTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveTab extends StatelessWidget {
  const _ActiveTab();

  @override
  Widget build(BuildContext context) {
    final hPad = (MediaQuery.of(context).size.width * 0.042).clamp(12.0, 24.0);
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 16),
      children: [
        _ChallengeDetailCard(
          title: '7-Day Quiz Streak',
          description: 'Complete the daily quiz every day for 7 consecutive days without missing a single day.',
          points: 300,
          progress: 0.71,
          daysLeft: 2,
          type: 'Individual',
          typeColor: AppColors.primary,
          icon: Icons.quiz_rounded,
          color: AppColors.primary,
          current: 5,
          target: 7,
          unit: 'days',
        ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.05, end: 0),
        const SizedBox(height: 14),
        _ChallengeDetailCard(
          title: 'Team Fitness Challenge',
          description: 'Log 10,000 steps daily with your team. All members must participate for points to count.',
          points: 500,
          progress: 0.45,
          daysLeft: 5,
          type: 'Team',
          typeColor: AppColors.success,
          icon: Icons.directions_run_rounded,
          color: AppColors.success,
          current: 45000,
          target: 100000,
          unit: 'steps',
        ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.05, end: 0),
        const SizedBox(height: 14),
        _ChallengeDetailCard(
          title: 'Code Review Master',
          description: 'Review 10 pull requests this sprint and provide constructive feedback.',
          points: 200,
          progress: 0.3,
          daysLeft: 8,
          type: 'Individual',
          typeColor: AppColors.primary,
          icon: Icons.code_rounded,
          color: Colors.deepPurple,
          current: 3,
          target: 10,
          unit: 'reviews',
        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.05, end: 0),
        const SizedBox(height: 80),
      ],
    );
  }
}

class _ChallengeDetailCard extends StatelessWidget {
  final String title;
  final String description;
  final int points;
  final double progress;
  final int daysLeft;
  final String type;
  final Color typeColor;
  final IconData icon;
  final Color color;
  final int current;
  final int target;
  final String unit;

  const _ChallengeDetailCard({
    required this.title,
    required this.description,
    required this.points,
    required this.progress,
    required this.daysLeft,
    required this.type,
    required this.typeColor,
    required this.icon,
    required this.color,
    required this.current,
    required this.target,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: AppColors.textPrimary)),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: typeColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(type,
                              style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: typeColor)),
                        ),
                        const SizedBox(width: 6),
                        Text('$daysLeft days left',
                            style: GoogleFonts.poppins(
                                fontSize: 11, color: AppColors.textSecondary)),
                      ],
                    ),
                  ],
                ),
              ),
              PointsBadge(points: points),
            ],
          ),
          const SizedBox(height: 12),
          Text(description,
              style: GoogleFonts.poppins(
                  fontSize: 12, color: AppColors.textSecondary, height: 1.5)),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Progress: $current / $target $unit',
                  style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary)),
              Text('${(progress * 100).toInt()}%',
                  style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: color)),
            ],
          ),
          const SizedBox(height: 8),
          LinearPercentIndicator(
            lineHeight: 10,
            percent: progress,
            backgroundColor: color.withValues(alpha: 0.12),
            progressColor: color,
            barRadius: const Radius.circular(5),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}

class _AvailableTab extends StatelessWidget {
  const _AvailableTab();

  static const _challenges = [
    {
      'title': 'Learning Marathon',
      'desc': 'Complete 5 online courses in 30 days',
      'points': 400,
      'icon': Icons.school_rounded,
      'color': Color(0xFF00ACC1),
      'duration': '30 days',
    },
    {
      'title': 'Social Butterfly',
      'desc': 'Connect with 20 colleagues on the platform',
      'points': 150,
      'icon': Icons.people_rounded,
      'color': Color(0xFFEC4899),
      'duration': '14 days',
    },
    {
      'title': 'Innovation Sprint',
      'desc': 'Submit 3 new ideas to the suggestion box',
      'points': 250,
      'icon': Icons.lightbulb_rounded,
      'color': Color(0xFFF59E0B),
      'duration': '7 days',
    },
    {
      'title': 'Wellness Week',
      'desc': 'Log daily wellness activities for a week',
      'points': 200,
      'icon': Icons.favorite_rounded,
      'color': Color(0xFF10B981),
      'duration': '7 days',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final hPad = (MediaQuery.of(context).size.width * 0.042).clamp(12.0, 24.0);
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 16),
      itemCount: _challenges.length,
      itemBuilder: (context, i) {
        final c = _challenges[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 3))
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: (c['color'] as Color).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(c['icon'] as IconData,
                    color: c['color'] as Color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c['title'] as String,
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: AppColors.textPrimary)),
                    Text(c['desc'] as String,
                        style: GoogleFonts.poppins(
                            fontSize: 11, color: AppColors.textSecondary),
                        maxLines: 2),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.access_time_rounded,
                            size: 12, color: AppColors.textSecondary),
                        const SizedBox(width: 3),
                        Text(c['duration'] as String,
                            style: GoogleFonts.poppins(
                                fontSize: 11, color: AppColors.textSecondary)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                children: [
                  PointsBadge(points: c['points'] as int),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Joined ${c['title']}!',
                              style: GoogleFonts.poppins()),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('Join',
                          style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 12)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ).animate().fadeIn(delay: Duration(milliseconds: 100 + i * 60));
      },
    );
  }
}

class _CompletedTab extends StatelessWidget {
  const _CompletedTab();

  static const _completed = [
    {
      'title': '5-Day Check-in Streak',
      'desc': 'Checked in 5 days in a row',
      'points': 100,
      'date': 'Mar 20, 2026',
      'color': Color(0xFF10B981),
      'icon': Icons.check_circle_rounded,
    },
    {
      'title': 'First Quiz Win',
      'desc': 'Won your first daily quiz',
      'points': 50,
      'date': 'Mar 15, 2026',
      'color': AppColors.primary,
      'icon': Icons.quiz_rounded,
    },
    {
      'title': 'Profile Complete',
      'desc': 'Filled out 100% of your profile',
      'points': 75,
      'date': 'Mar 10, 2026',
      'color': Color(0xFFF59E0B),
      'icon': Icons.person_rounded,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final hPad = (MediaQuery.of(context).size.width * 0.042).clamp(12.0, 24.0);
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 16),
      itemCount: _completed.length,
      itemBuilder: (context, i) {
        final c = _completed[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: AppColors.success.withValues(alpha: 0.3)),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 3))
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: (c['color'] as Color).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(c['icon'] as IconData,
                    color: c['color'] as Color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(c['title'] as String,
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: AppColors.textPrimary)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text('Done',
                              style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.success)),
                        ),
                      ],
                    ),
                    Text(c['desc'] as String,
                        style: GoogleFonts.poppins(
                            fontSize: 11, color: AppColors.textSecondary)),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(c['date'] as String,
                            style: GoogleFonts.poppins(
                                fontSize: 10, color: AppColors.textSecondary)),
                        PointsBadge(points: c['points'] as int),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: Duration(milliseconds: 100 + i * 60));
      },
    );
  }
}
