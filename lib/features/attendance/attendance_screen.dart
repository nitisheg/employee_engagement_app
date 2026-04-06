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
    final localTime = time.toLocal();
    final hour = localTime.hour % 12 == 0 ? 12 : localTime.hour % 12;
    final amPm = localTime.hour >= 12 ? 'PM' : 'AM';

    return "${hour.toString().padLeft(2, '0')}:"
        "${localTime.minute.toString().padLeft(2, '0')}:"
        "${localTime.second.toString().padLeft(2, '0')} $amPm";
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
              surfaceTintColor: AppColors.white,
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
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 2,
                              ),
                              icon: provider.isCheckingIn
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              AppColors.white,
                                            ),
                                      ),
                                    )
                                  : const Icon(Icons.login_rounded),
                              label: Text(
                                provider.isCheckingIn
                                    ? 'Punching In...'
                                    : 'Punch In',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
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
                              // Today's Sessions Card
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.06),
                                      blurRadius: 10,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Header
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.success.withOpacity(
                                          0.1,
                                        ),
                                        borderRadius:
                                            const BorderRadius.vertical(
                                              top: Radius.circular(16),
                                            ),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.today_rounded,
                                            color: AppColors.success,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          const Text(
                                            "Today's Activity",
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.success,
                                            ),
                                          ),
                                          const Spacer(),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.success,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              '${todayStatus.sessions.length} Session${todayStatus.sessions.length != 1 ? 's' : ''}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Sessions list
                                    ...List.generate(todayStatus.sessions.length, (
                                      i,
                                    ) {
                                      final session = todayStatus.sessions[i];
                                      final isActive = session.checkOut == null;
                                      Duration? dur;
                                      if (session.checkOut != null) {
                                        dur = session.checkOut!.difference(
                                          session.checkIn,
                                        );
                                      }

                                      return Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 12,
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                // Session label
                                                Row(
                                                  children: [
                                                    Container(
                                                      width: 24,
                                                      height: 24,
                                                      alignment:
                                                          Alignment.center,
                                                      decoration: BoxDecoration(
                                                        color: isActive
                                                            ? AppColors.success
                                                            : Colors
                                                                  .grey
                                                                  .shade400,
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Text(
                                                        '${i + 1}',
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      'Session ${i + 1}',
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: 13,
                                                        color: Colors.black87,
                                                      ),
                                                    ),
                                                    if (isActive) ...[
                                                      const SizedBox(width: 8),
                                                      Container(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 8,
                                                              vertical: 2,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color: AppColors
                                                              .success
                                                              .withOpacity(
                                                                0.15,
                                                              ),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                10,
                                                              ),
                                                        ),
                                                        child: const Text(
                                                          'Active',
                                                          style: TextStyle(
                                                            color: AppColors
                                                                .success,
                                                            fontSize: 10,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                    if (dur != null) ...[
                                                      const Spacer(),
                                                      Text(
                                                        '${dur.inHours}h ${dur.inMinutes.remainder(60)}m',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color: Colors
                                                              .grey
                                                              .shade600,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ],
                                                  ],
                                                ),
                                                const SizedBox(height: 10),
                                                // Punch In / Punch Out row
                                                Row(
                                                  children: [
                                                    // Punch In
                                                    Expanded(
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 12,
                                                              vertical: 10,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color: const Color(
                                                            0xFFE8F5E9,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                10,
                                                              ),
                                                        ),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Row(
                                                              children: const [
                                                                Icon(
                                                                  Icons
                                                                      .login_rounded,
                                                                  size: 14,
                                                                  color: Color(
                                                                    0xFF2E7D32,
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  width: 4,
                                                                ),
                                                                Text(
                                                                  'Punch In',
                                                                  style: TextStyle(
                                                                    fontSize:
                                                                        11,
                                                                    color: Color(
                                                                      0xFF2E7D32,
                                                                    ),
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            const SizedBox(
                                                              height: 4,
                                                            ),
                                                            Text(
                                                              _formatTime(
                                                                session.checkIn,
                                                              ),
                                                              style: const TextStyle(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Color(
                                                                  0xFF1B5E20,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 10),
                                                    // Arrow
                                                    Icon(
                                                      Icons
                                                          .arrow_forward_rounded,
                                                      size: 16,
                                                      color:
                                                          Colors.grey.shade400,
                                                    ),
                                                    const SizedBox(width: 10),
                                                    // Punch Out
                                                    Expanded(
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 12,
                                                              vertical: 10,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color: isActive
                                                              ? Colors
                                                                    .grey
                                                                    .shade100
                                                              : const Color(
                                                                  0xFFFFF3E0,
                                                                ),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                10,
                                                              ),
                                                        ),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                Icon(
                                                                  Icons
                                                                      .logout_rounded,
                                                                  size: 14,
                                                                  color:
                                                                      isActive
                                                                      ? Colors
                                                                            .grey
                                                                      : const Color(
                                                                          0xFFE65100,
                                                                        ),
                                                                ),
                                                                const SizedBox(
                                                                  width: 4,
                                                                ),
                                                                Text(
                                                                  'Punch Out',
                                                                  style: TextStyle(
                                                                    fontSize:
                                                                        11,
                                                                    color:
                                                                        isActive
                                                                        ? Colors
                                                                              .grey
                                                                        : const Color(
                                                                            0xFFE65100,
                                                                          ),
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            const SizedBox(
                                                              height: 4,
                                                            ),
                                                            Text(
                                                              session.checkOut !=
                                                                      null
                                                                  ? _formatTime(
                                                                      session
                                                                          .checkOut!,
                                                                    )
                                                                  : '--:-- --',
                                                              style: TextStyle(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: isActive
                                                                    ? Colors
                                                                          .grey
                                                                          .shade400
                                                                    : const Color(
                                                                        0xFFBF360C,
                                                                      ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          if (i <
                                              todayStatus.sessions.length - 1)
                                            Divider(
                                              height: 1,
                                              color: Colors.grey.shade200,
                                              indent: 16,
                                              endIndent: 16,
                                            ),
                                        ],
                                      );
                                    }),

                                    // Total Duration footer
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade50,
                                        borderRadius:
                                            const BorderRadius.vertical(
                                              bottom: Radius.circular(16),
                                            ),
                                        border: Border(
                                          top: BorderSide(
                                            color: Colors.grey.shade200,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: const [
                                              Icon(
                                                Icons.timer_outlined,
                                                size: 16,
                                                color: Colors.black54,
                                              ),
                                              SizedBox(width: 6),
                                              Text(
                                                'Total Duration',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.black54,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            '${todayStatus.totalMinutes ~/ 60}h ${todayStatus.totalMinutes % 60}m',
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.success,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Check Out Button
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    backgroundColor: const Color(0xFFE65100),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    elevation: 2,
                                  ),
                                  icon: provider.isCheckingOut
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  AppColors.white,
                                                ),
                                          ),
                                        )
                                      : const Icon(Icons.logout_rounded),
                                  label: Text(
                                    provider.isCheckingOut
                                        ? 'Checking Out...'
                                        : 'Punch Out',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
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
                            color: AppColors.info.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.info.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.info, color: Color(0xFF1976D2)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Attendance Points',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF1976D2),
                                      ),
                                    ),
                                    Text(
                                      'Earn points based on your attendance and work duration',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: const Color(0xFF1E88E5),
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
