import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/common_widgets.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  bool _checkedIn = false;
  String? _checkInTime;

  final List<Map<String, dynamic>> _history = [
    {'date': 'Mon, Mar 24', 'time': '09:02 AM', 'pts': 10, 'status': true},
    {'date': 'Tue, Mar 25', 'time': '08:58 AM', 'pts': 10, 'status': true},
    {'date': 'Wed, Mar 26', 'time': '09:15 AM', 'pts': 10, 'status': true},
    {'date': 'Thu, Mar 27', 'time': '--', 'pts': 0, 'status': false},
  ];

  final List<Map<String, dynamic>> _weekDays = [
    {'day': 'M', 'checked': true},
    {'day': 'T', 'checked': true},
    {'day': 'W', 'checked': true},
    {'day': 'T', 'checked': true},
    {'day': 'F', 'checked': true},
    {'day': 'S', 'checked': false},
    {'day': 'S', 'checked': false},
  ];

  void _handleCheckIn() {
    setState(() {
      _checkedIn = true;
      final now = TimeOfDay.now();
      _checkInTime =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} ${now.period.name.toUpperCase()}';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Checked in successfully! +10 pts',
            style: GoogleFonts.poppins()),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.primary,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text('Attendance',
                style: GoogleFonts.poppins(
                    color: Colors.white, fontWeight: FontWeight.w600)),
            flexibleSpace: Container(
                decoration:
                    const BoxDecoration(gradient: AppColors.primaryGradient)),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: (MediaQuery.of(context).size.width * 0.042).clamp(12.0, 24.0),
                vertical: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date/time card
                  AppCard(
                    child: Column(
                      children: [
                        Text(
                          'Thursday, March 27, 2026',
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _checkedIn
                              ? 'Checked in at $_checkInTime'
                              : 'Not checked in yet',
                          style: GoogleFonts.poppins(
                              fontSize: 13, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 20),

                        // Check-in button
                        GestureDetector(
                          onTap: _checkedIn ? null : _handleCheckIn,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: (MediaQuery.of(context).size.width * 0.42).clamp(130.0, 180.0),
                            height: (MediaQuery.of(context).size.width * 0.42).clamp(130.0, 180.0),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: _checkedIn
                                  ? const LinearGradient(
                                      colors: [
                                        AppColors.success,
                                        Color(0xFF059669)
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    )
                                  : AppColors.primaryGradient,
                              boxShadow: [
                                BoxShadow(
                                  color: (_checkedIn
                                          ? AppColors.success
                                          : AppColors.primary)
                                      .withValues(alpha: 0.4),
                                  blurRadius: 24,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _checkedIn
                                      ? Icons.check_circle_rounded
                                      : Icons.touch_app_rounded,
                                  color: Colors.white,
                                  size: 48,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _checkedIn ? 'CHECKED IN' : 'CHECK IN',
                                  style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16,
                                      letterSpacing: 1),
                                ),
                              ],
                            ),
                          ),
                        ).animate().scale(
                            duration: 400.ms, curve: Curves.elasticOut),
                        const SizedBox(height: 16),

                        // Streak row
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('🔥',
                                  style: TextStyle(fontSize: 20)),
                              const SizedBox(width: 8),
                              Text('7 Day Streak!',
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                      color: AppColors.secondary)),
                              const SizedBox(width: 8),
                              Text('Keep it going!',
                                  style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 100.ms),
                  const SizedBox(height: 20),

                  // Weekly view
                  SectionHeader(title: 'This Week')
                      .animate()
                      .fadeIn(delay: 200.ms),
                  const SizedBox(height: 12),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final dayCircle = (constraints.maxWidth / 9).clamp(32.0, 44.0);
                      return AppCard(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: _weekDays.map((day) {
                            return Column(
                              children: [
                                Text(day['day'] as String,
                                    style: GoogleFonts.poppins(
                                        fontSize: (constraints.maxWidth * 0.031).clamp(10.0, 14.0),
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textSecondary)),
                                const SizedBox(height: 6),
                                Container(
                                  width: dayCircle,
                                  height: dayCircle,
                                  decoration: BoxDecoration(
                                    color: day['checked'] as bool
                                        ? AppColors.success
                                        : Colors.grey.shade200,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    day['checked'] as bool
                                        ? Icons.check_rounded
                                        : Icons.close_rounded,
                                    color: day['checked'] as bool
                                        ? Colors.white
                                        : Colors.grey.shade400,
                                    size: 18,
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      );
                    },
                  ).animate().fadeIn(delay: 250.ms),
                  const SizedBox(height: 20),

                  // Monthly summary
                  SectionHeader(title: 'Monthly Summary')
                      .animate()
                      .fadeIn(delay: 300.ms),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                          child: StatCard(
                              title: 'Present Days',
                              value: '22',
                              icon: Icons.calendar_today_rounded,
                              color: AppColors.success)),
                      const SizedBox(width: 10),
                      Expanded(
                          child: StatCard(
                              title: 'Streak Record',
                              value: '7',
                              icon: Icons.local_fire_department_rounded,
                              color: AppColors.secondary)),
                      const SizedBox(width: 10),
                      Expanded(
                          child: StatCard(
                              title: 'Pts Earned',
                              value: '220',
                              icon: Icons.stars_rounded,
                              color: AppColors.primary)),
                    ],
                  ).animate().fadeIn(delay: 350.ms),
                  const SizedBox(height: 20),

                  // Check-in history
                  SectionHeader(title: 'Check-in History')
                      .animate()
                      .fadeIn(delay: 400.ms),
                  const SizedBox(height: 12),
                  AppCard(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      children: _history.map((item) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 8),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: (item['status'] as bool
                                          ? AppColors.success
                                          : Colors.grey)
                                      .withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  item['status'] as bool
                                      ? Icons.check_circle_rounded
                                      : Icons.cancel_rounded,
                                  color: item['status'] as bool
                                      ? AppColors.success
                                      : Colors.grey,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(item['date'] as String,
                                        style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                            color: AppColors.textPrimary)),
                                    Text(
                                        item['status'] as bool
                                            ? 'Checked in at ${item['time']}'
                                            : 'No check-in',
                                        style: GoogleFonts.poppins(
                                            fontSize: 11,
                                            color: AppColors.textSecondary)),
                                  ],
                                ),
                              ),
                              if (item['pts'] as int > 0)
                                PointsBadge(points: item['pts'] as int),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ).animate().fadeIn(delay: 450.ms),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          SliverSafeArea(
            top: false,
            sliver: const SliverToBoxAdapter(child: SizedBox.shrink()),
          ),
        ],
      ),
    );
  }
}
