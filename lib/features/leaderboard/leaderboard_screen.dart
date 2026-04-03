import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/common_widgets.dart';
import '../../providers/leaderboard_provider.dart';
import '../../models/leaderboard_model.dart';

class _Employee {
  final String name;
  final String department;
  final int points;
  final int rank;
  final int change;
  final String initials;
  final Color avatarColor;

  const _Employee({
    required this.name,
    required this.department,
    required this.points,
    required this.rank,
    required this.change,
    required this.initials,
    required this.avatarColor,
  });

  factory _Employee.fromLeaderboardEntry(LeaderboardEntry e) {
    return _Employee(
      name: e.name,
      department: '',
      points: e.points,
      rank: e.rank,
      change: 0,
      initials: e.initials.isNotEmpty
          ? e.initials
          : (e.name.isNotEmpty
                ? e.name.split(' ').map((s) => s[0]).join()
                : '?'),
      avatarColor: AppColors.primary,
    );
  }
}

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  LeaderboardPeriod _currentPeriod = LeaderboardPeriod.allTime;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_onTabChanged);

    // Fetch initial data
    Future.microtask(() {
      context.read<LeaderboardProvider>().fetchLeaderboard(_currentPeriod);
    });
  }

  static const List<LeaderboardPeriod> _periodTabs = [
    LeaderboardPeriod.allTime,
    LeaderboardPeriod.monthly,
    LeaderboardPeriod.weekly,
    LeaderboardPeriod.today,
  ];

  static String _periodLabel(LeaderboardPeriod period) {
    switch (period) {
      case LeaderboardPeriod.allTime:
        return 'All Time';
      case LeaderboardPeriod.monthly:
        return 'Monthly';
      case LeaderboardPeriod.weekly:
        return 'Weekly';
      case LeaderboardPeriod.today:
        return 'Today';
      default:
        return 'All Time';
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    final newPeriod = _periodTabs[_tabController.index];
    if (newPeriod != _currentPeriod) {
      setState(() => _currentPeriod = newPeriod);
      context.read<LeaderboardProvider>().fetchLeaderboard(newPeriod);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header
          Container(
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(0),
                bottomRight: Radius.circular(0),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: Row(
                      children: [
                        Text(
                          'Leaderboard',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.emoji_events_rounded,
                          color: AppColors.gold,
                          size: 28,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    indicatorColor: Colors.white,
                    indicatorWeight: 3,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white.withValues(alpha: 0.6),
                    labelStyle: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    unselectedLabelStyle: GoogleFonts.poppins(fontSize: 13),
                    tabs: _periodTabs
                        .map((p) => Tab(text: _periodLabel(p)))
                        .toList(),
                  ),
                ],
              ),
            ),
          ),

          // Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _periodTabs.map((period) {
                return _LeaderboardTab(period: period);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _LeaderboardTab extends StatelessWidget {
  final LeaderboardPeriod period;

  const _LeaderboardTab({required this.period});

  @override
  Widget build(BuildContext context) {
    return Consumer<LeaderboardProvider>(
      builder: (context, provider, child) {
        if (provider.currentPeriod != period) {
          // Ensure we show loading state only for this period
          return const SizedBox.shrink();
        }

        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.errorMessage != null) {
          return Center(child: Text('Error: ${provider.errorMessage}'));
        }

        final entries = provider.entries;
        final userEntry = provider.currentUserEntry;

        if (entries.isEmpty) {
          return const Center(child: Text('No leaderboard data available'));
        }

        final employees = entries
            .map((entry) => _Employee.fromLeaderboardEntry(entry))
            .toList();

        return _LeaderboardList(
          employees: employees,
          userEntry: userEntry != null
              ? _Employee.fromLeaderboardEntry(userEntry)
              : null,
        );
      },
    );
  }
}

class _LeaderboardList extends StatelessWidget {
  final List<_Employee> employees;
  final _Employee? userEntry;

  const _LeaderboardList({required this.employees, this.userEntry});

  @override
  Widget build(BuildContext context) {
    final top3 = employees.take(3).toList();
    final rest = employees.skip(3).toList();

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: (MediaQuery.of(context).size.width * 0.04).clamp(
                12.0,
                24.0,
              ),
              vertical: 16,
            ),
            child: Column(
              children: [
                // Podium
                _PodiumWidget(
                  top3: top3,
                ).animate().fadeIn(delay: 100.ms).slideY(begin: -0.1, end: 0),
                const SizedBox(height: 16),

                // Rank 4-10
                ...rest.asMap().entries.map((entry) {
                  final emp = entry.value;
                  return _RankRow(employee: emp)
                      .animate()
                      .fadeIn(
                        delay: Duration(milliseconds: 150 + entry.key * 50),
                      )
                      .slideX(begin: 0.05, end: 0);
                }),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),

        // Your rank footer
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      userEntry?.initials ?? 'U',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Builder(
                        builder: (context) {
                          final user = userEntry;
                          final nameText = user != null
                              ? '${user.name} (You)'
                              : 'You';
                          return Text(
                            nameText,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          );
                        },
                      ),
                      if (userEntry?.department.isNotEmpty ?? false)
                        Text(
                          userEntry!.department,
                          style: GoogleFonts.poppins(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 11,
                          ),
                        ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Rank #${userEntry?.rank ?? employees.first.rank}',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '${userEntry?.points ?? employees.first.points} pts',
                      style: GoogleFonts.poppins(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PodiumWidget extends StatelessWidget {
  final List<_Employee> top3;

  const _PodiumWidget({required this.top3});

  @override
  Widget build(BuildContext context) {
    if (top3.length < 3) return const SizedBox.shrink();
    final w = MediaQuery.of(context).size.width;
    final podiumScale = (w / 400).clamp(0.75, 1.2);
    return AppCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 2nd place
          _PodiumColumn(
            employee: top3[1],
            medal: '🥈',
            height: 80 * podiumScale,
            medalColor: const Color(0xFFC0C0C0),
            scale: podiumScale,
          ),
          // 1st place
          _PodiumColumn(
            employee: top3[0],
            medal: '🥇',
            height: 110 * podiumScale,
            medalColor: AppColors.gold,
            scale: podiumScale,
          ),
          // 3rd place
          _PodiumColumn(
            employee: top3[2],
            medal: '🥉',
            height: 60 * podiumScale,
            medalColor: const Color(0xFFCD7F32),
            scale: podiumScale,
          ),
        ],
      ),
    );
  }
}

class _PodiumColumn extends StatelessWidget {
  final _Employee employee;
  final String medal;
  final double height;
  final Color medalColor;
  final double scale;

  const _PodiumColumn({
    required this.employee,
    required this.medal,
    required this.height,
    required this.medalColor,
    this.scale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final avatarSize = 52.0 * scale;
    final podiumWidth = 80.0 * scale;
    final nameWidth = 90.0 * scale;
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(medal, style: TextStyle(fontSize: 24 * scale)),
        const SizedBox(height: 4),
        Container(
          width: avatarSize,
          height: avatarSize,
          decoration: BoxDecoration(
            color: employee.avatarColor,
            shape: BoxShape.circle,
            border: Border.all(color: medalColor, width: 2.5),
          ),
          child: Center(
            child: Text(
              employee.initials,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: nameWidth,
          child: Text(
            employee.name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Text(
          '${employee.points} pts',
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: podiumWidth,
          height: height,
          decoration: BoxDecoration(
            color: medalColor.withValues(alpha: 0.15),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
            border: Border.all(color: medalColor.withValues(alpha: 0.4)),
          ),
          child: Center(
            child: Text(
              '#${employee.rank}',
              style: GoogleFonts.poppins(
                fontSize: (18 * scale).clamp(12.0, 20.0),
                fontWeight: FontWeight.w800,
                color: medalColor,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RankRow extends StatelessWidget {
  final _Employee employee;

  const _RankRow({required this.employee});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '#${employee.rank}',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: employee.avatarColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                employee.initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  employee.name,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  employee.department,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${employee.points}',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              Row(
                children: [
                  Icon(
                    employee.change > 0
                        ? Icons.arrow_upward_rounded
                        : employee.change < 0
                        ? Icons.arrow_downward_rounded
                        : Icons.remove_rounded,
                    size: 12,
                    color: employee.change > 0
                        ? AppColors.success
                        : employee.change < 0
                        ? Colors.redAccent
                        : AppColors.textSecondary,
                  ),
                  if (employee.change != 0)
                    Text(
                      '${employee.change.abs()}',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: employee.change > 0
                            ? AppColors.success
                            : Colors.redAccent,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ignore: unused_element
class _TeamsTab extends StatelessWidget {
  final List<Map<String, dynamic>> teams = const [
    {
      'name': 'Engineering',
      'points': 18400,
      'members': 12,
      'rank': 1,
      'color': Color(0xFFE53935),
    },
    {
      'name': 'Marketing',
      'points': 14200,
      'members': 8,
      'rank': 2,
      'color': Color(0xFFFF6B35),
    },
    {
      'name': 'Sales',
      'points': 12800,
      'members': 10,
      'rank': 3,
      'color': Color(0xFF10B981),
    },
    {
      'name': 'HR',
      'points': 9600,
      'members': 6,
      'rank': 4,
      'color': Color(0xFFF59E0B),
    },
    {
      'name': 'Finance',
      'points': 7200,
      'members': 5,
      'rank': 5,
      'color': Color(0xFFEC4899),
    },
  ];

  const _TeamsTab();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: teams.length,
      itemBuilder: (context, i) {
        final team = teams[i];
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
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: (team['color'] as Color).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    '#${team['rank']}',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: team['color'] as Color,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      team['name'] as String,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${team['members']} members',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              PointsBadge(points: team['points'] as int),
            ],
          ),
        ).animate().fadeIn(delay: Duration(milliseconds: 100 + i * 60));
      },
    );
  }
}
