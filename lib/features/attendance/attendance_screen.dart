import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/common_widgets.dart';
import 'attendance_history_screen.dart';
import 'attendance_stats_screen.dart';

// Local attendance record class
class LocalAttendanceRecord {
  final DateTime date;
  DateTime? checkInTime;
  DateTime? checkOutTime;
  bool isPresent;
  int pointsEarned;

  LocalAttendanceRecord({
    required this.date,
    this.checkInTime,
    this.checkOutTime,
    this.isPresent = false,
    this.pointsEarned = 0,
  });

  Duration get workDuration {
    if (checkInTime == null || checkOutTime == null) {
      return Duration.zero;
    }
    return checkOutTime!.difference(checkInTime!);
  }

  String get status {
    if (!isPresent) return 'Absent';
    if (checkInTime != null && checkInTime!.hour >= 10) return 'Late';
    return 'Present';
  }
}

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  Timer? _timer;
  DateTime _currentTime = DateTime.now();

  // Local data storage
  static final Map<DateTime, LocalAttendanceRecord> _attendanceRecords = {};
  static int _totalPoints = 0;
  static int _currentStreak = 0;
  static int _bestStreak = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _currentTime = DateTime.now();
      });
    });
    _initializeSampleData();
  }

  void _initializeSampleData() {
    // Add some sample data for the past 30 days
    final now = DateTime.now();
    for (int i = 0; i < 30; i++) {
      final date = now.subtract(Duration(days: i));
      // Skip weekends
      if (date.weekday != DateTime.saturday &&
          date.weekday != DateTime.sunday) {
        _attendanceRecords.putIfAbsent(
          DateTime(date.year, date.month, date.day),
          () {
            final isPresent = i % 3 != 0; // Mark some days as absent
            final record = LocalAttendanceRecord(
              date: DateTime(date.year, date.month, date.day),
              isPresent: isPresent,
              pointsEarned: isPresent ? 10 : 0,
            );
            if (isPresent) {
              record.checkInTime = DateTime(
                date.year,
                date.month,
                date.day,
                9 + (i % 2), // 9 or 10 AM
                30,
              );
              record.checkOutTime = DateTime(
                date.year,
                date.month,
                date.day,
                17 + (i % 2), // 5 or 6 PM
                0,
              );
            }
            return record;
          },
        );
      }
    }
    _calculateStats();
  }

  void _calculateStats() {
    _totalPoints = 0;
    _currentStreak = 0;
    int tempStreak = 0;

    final sortedDates = _attendanceRecords.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    for (final date in sortedDates) {
      final record = _attendanceRecords[date]!;
      _totalPoints += record.pointsEarned;

      if (record.isPresent) {
        tempStreak++;
        if (tempStreak > _bestStreak) {
          _bestStreak = tempStreak;
        }
      } else {
        _currentStreak = tempStreak;
        tempStreak = 0;
      }
    }
  }

  void _checkIn() {
    final today = DateTime(
      _currentTime.year,
      _currentTime.month,
      _currentTime.day,
    );

    if (_attendanceRecords.containsKey(today)) {
      final record = _attendanceRecords[today]!;
      if (record.checkInTime != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Already checked in today!')),
        );
        return;
      }
    }

    setState(() {
      final record = _attendanceRecords.putIfAbsent(
        today,
        () => LocalAttendanceRecord(date: today),
      );
      record.checkInTime = _currentTime;
      record.isPresent = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Checked in at ${_formatTime(_currentTime)} ✓'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _checkOut() {
    final today = DateTime(
      _currentTime.year,
      _currentTime.month,
      _currentTime.day,
    );

    if (!_attendanceRecords.containsKey(today)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please check in first!')));
      return;
    }

    final record = _attendanceRecords[today]!;
    if (record.checkInTime == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please check in first!')));
      return;
    }

    if (record.checkOutTime != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Already checked out today!')),
      );
      return;
    }

    setState(() {
      record.checkOutTime = _currentTime;
      final duration = record.workDuration;
      if (duration.inHours >= 8) {
        record.pointsEarned = 20;
        _totalPoints += 20;
        _currentStreak++;
      } else if (duration.inMinutes > 0) {
        record.pointsEarned = 10;
        _totalPoints += 10;
      }
    });

    final duration = record.workDuration;
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Checked out at ${_formatTime(_currentTime)} | Duration: ${hours}h ${minutes}m | +${record.pointsEarned} points',
        ),
        backgroundColor: AppColors.success,
      ),
    );
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

  LocalAttendanceRecord? getTodayRecord() {
    final today = DateTime(
      _currentTime.year,
      _currentTime.month,
      _currentTime.day,
    );
    return _attendanceRecords[today];
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final todayRecord = getTodayRecord();
    final presentDays = _attendanceRecords.values
        .where((r) => r.isPresent)
        .length;
    final absentDays = _attendanceRecords.values
        .where((r) => !r.isPresent)
        .length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Attendance'),
        centerTitle: true,
        backgroundColor: Colors.white,
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
                builder: (_) =>
                    AttendanceHistoryScreen(records: _attendanceRecords),
              ),
            ),
            child: const Text('History'),
          ),
          TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AttendanceStatsScreen(
                  records: _attendanceRecords,
                  totalPoints: _totalPoints,
                  currentStreak: _currentStreak,
                  bestStreak: _bestStreak,
                ),
              ),
            ),
            child: const Text('Stats'),
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
                  // Current Time Card
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

                  // Check-In/Out Buttons
                  if (todayRecord?.checkInTime == null)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: AppColors.success,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.login),
                        label: const Text(
                          'Check In',
                          style: TextStyle(fontSize: 16),
                        ),
                        onPressed: _checkIn,
                      ),
                    )
                  else if (todayRecord?.checkOutTime == null)
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Checked In At'),
                                  Text(
                                    _formatTime(todayRecord!.checkInTime!),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF10B981),
                                    ),
                                  ),
                                ],
                              ),
                              Icon(
                                Icons.check_circle,
                                color: AppColors.success,
                                size: 32,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: AppColors.warning,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(Icons.logout),
                            label: const Text(
                              'Check Out',
                              style: TextStyle(fontSize: 16),
                            ),
                            onPressed: _checkOut,
                          ),
                        ),
                      ],
                    )
                  else
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Checked Out',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Icon(
                                Icons.done_all,
                                color: AppColors.success,
                                size: 32,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Check In Time'),
                                  Text(
                                    _formatTime(todayRecord!.checkInTime!),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text('Check Out Time'),
                                  Text(
                                    _formatTime(todayRecord!.checkOutTime!),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Divider(color: Colors.grey.shade300),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total Duration',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '${todayRecord!.workDuration.inHours}h ${todayRecord!.workDuration.inMinutes.remainder(60)}m',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF10B981),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Points Earned',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '+${todayRecord!.pointsEarned}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFE53935),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
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
                                '$_currentStreak',
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
                                '$_totalPoints',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFE53935),
                                ),
                              ),
                              const Text(
                                'Total Points',
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
                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
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
                                'Work 8+ hours',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                              Text(
                                'Earn 20 points, else 10 points',
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
    );
  }
}
