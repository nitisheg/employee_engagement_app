import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/common_widgets.dart';
import '../../providers/attendance_provider.dart';
import 'attendance_history_screen.dart';
import 'attendance_stats_screen.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  Timer? _timer;
  DateTime _currentTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _currentTime = DateTime.now();
      });
    });

    // Fetch initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AttendanceProvider>();
      provider.fetchTodayStatus();
      provider.fetchAttendanceHistory();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTime(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final amPm = time.hour >= 12 ? 'PM' : 'AM';

    return "${hour.toString().padLeft(2, '0')}:"
        "${time.minute.toString().padLeft(2, '0')}:"
        "${time.second.toString().padLeft(2, '0')} $amPm";
  }

  String _formatDate(DateTime time) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return "${time.day.toString().padLeft(2, '0')} "
        "${months[time.month - 1]} "
        "${time.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AttendanceProvider>(
      builder: (context, provider, child) {
        final todayStatus = provider.todayStatus;
        final attendanceHistory = provider.attendanceHistory;

        // Calculate stats from history
        final presentDays =
            attendanceHistory?.records
                .where((record) => record.sessions.isNotEmpty)
                .length ??
            0;
        final absentDays =
            attendanceHistory?.records
                .where((record) => record.sessions.isEmpty)
                .length ??
            0;

        return SafeArea(
          top: false,
          child: Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              title: const Text('Attendance'),
              centerTitle: true,
              backgroundColor: AppColors.primary,
              surfaceTintColor: Colors.white,
              elevation: 0,
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1),
                child: Container(color: Colors.grey.shade300, height: 1),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AttendanceHistoryScreen(),
                    ),
                  ),
                  child: const Text(
                    'History',
                    style: TextStyle(color: AppColors.gold),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AttendanceStatsScreen()),
                  ),
                  child: const Text(
                    'Stats',
                    style: TextStyle(color: AppColors.gold),
                  ),
                ),
              ],
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        AppCard(
                          child: Column(
                            children: [
                              Text(
                                _formatDate(_currentTime),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _formatTime(_currentTime),
                                style: const TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFE53935),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Error/Success Messages
                        if (provider.errorMessage != null)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.red.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error, color: Colors.red),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    provider.errorMessage!,
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        if (provider.successMessage != null)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.green.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    provider.successMessage!,
                                    style: const TextStyle(color: Colors.green),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // Streak Warning
                        if (provider.streakWarning != null)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.orange.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.warning, color: Colors.orange),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    provider.streakWarning!,
                                    style: const TextStyle(
                                      color: Colors.orange,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 20),

                        // Check-In/Out Section
                        if (todayStatus == null)
                          const Center(child: CircularProgressIndicator())
                        else if (!provider.isCheckedInToday)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                backgroundColor: AppColors.success,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: provider.isCheckingIn
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                  : const Icon(Icons.login),
                              label: Text(
                                provider.isCheckingIn
                                    ? 'Checking In...'
                                    : 'Check In',
                                style: const TextStyle(fontSize: 16),
                              ),
                              onPressed: provider.isCheckingIn
                                  ? null
                                  : () async {
                                      final success = await provider.checkIn();
                                      if (success) {
                                        provider.clearMessages();
                                      }
                                    },
                            ),
                          )
                        else
                          Column(
                            children: [
                              // Today's Sessions
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.success.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Today\'s Activity',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    ...todayStatus.sessions.map(
                                      (session) => Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 4,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Session ${todayStatus.sessions.indexOf(session) + 1}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            Text(
                                              '${_formatTime(session.checkIn)} - ${session.checkOut != null ? _formatTime(session.checkOut!) : '--'}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Divider(color: Colors.grey.shade300),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Total Duration',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '${todayStatus.totalMinutes ~/ 60}h ${todayStatus.totalMinutes % 60}m',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF10B981),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Check Out Button
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    backgroundColor: AppColors.warning,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  icon: provider.isCheckingOut
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Colors.white,
                                                ),
                                          ),
                                        )
                                      : const Icon(Icons.logout),
                                  label: Text(
                                    provider.isCheckingOut
                                        ? 'Checking Out...'
                                        : 'Check Out',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  onPressed: provider.isCheckingOut
                                      ? null
                                      : () async {
                                          final success = await provider
                                              .checkOut();
                                          if (success) {
                                            provider.clearMessages();
                                          }
                                        },
                                ),
                              ),
                            ],
                          ),

                        const SizedBox(height: 20),

                        // Stats Summary
                        Row(
                          children: [
                            Expanded(
                              child: AppCard(
                                child: Column(
                                  children: [
                                    const Icon(
                                      Icons.done,
                                      color: Color(0xFF10B981),
                                      size: 28,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '$presentDays',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Text(
                                      'Present',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: AppCard(
                                child: Column(
                                  children: [
                                    const Icon(
                                      Icons.close,
                                      color: Color(0xFFD32F2F),
                                      size: 28,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '$absentDays',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Text(
                                      'Absent',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Streak & Points
                        Row(
                          children: [
                            Expanded(
                              child: AppCard(
                                child: Column(
                                  children: [
                                    const Icon(
                                      Icons.local_fire_department,
                                      color: Color(0xFFFF7043),
                                      size: 28,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '${provider.currentStreak}',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Text(
                                      'Current Streak',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: AppCard(
                                child: Column(
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      color: Color(0xFFFFD700),
                                      size: 28,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '${provider.longestStreak}',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFE53935),
                                      ),
                                    ),
                                    const Text(
                                      'Best Streak',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Info Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.blue.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info, color: Colors.blue.shade700),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Attendance Points',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue.shade700,
                                      ),
                                    ),
                                    Text(
                                      'Earn points based on your attendance and work duration',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.blue.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
