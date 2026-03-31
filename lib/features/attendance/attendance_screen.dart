import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/common_widgets.dart';
import 'attendance_history_screen.dart';
import 'attendance_stats_screen.dart';

// Attendance entry class for multiple check-ins/check-outs
class AttendanceEntry {
  final DateTime timestamp;
  final bool isCheckIn;

  AttendanceEntry({required this.timestamp, required this.isCheckIn});
}

// Local attendance record class
class LocalAttendanceRecord {
  final DateTime date;
  final List<AttendanceEntry> entries;
  bool isPresent;
  int pointsEarned;

  LocalAttendanceRecord({
    required this.date,
    List<AttendanceEntry>? entries,
    this.isPresent = false,
    this.pointsEarned = 0,
  }) : entries = entries ?? [];

  Duration get workDuration {
    Duration total = Duration.zero;
    DateTime? lastCheckIn;

    for (final entry in entries) {
      if (entry.isCheckIn) {
        lastCheckIn = entry.timestamp;
      } else if (lastCheckIn != null) {
        total += entry.timestamp.difference(lastCheckIn);
        lastCheckIn = null;
      }
    }
    return total;
  }

  String get status {
    if (!isPresent) return 'Absent';
    if (entries.isEmpty) return 'Absent';
    final firstCheckIn = entries.firstWhere(
      (e) => e.isCheckIn,
      orElse: () => AttendanceEntry(timestamp: DateTime.now(), isCheckIn: true),
    );
    if (firstCheckIn.timestamp.hour >= 10) return 'Late';
    return 'Present';
  }

  bool get isCurrentlyCheckedIn {
    if (entries.isEmpty) return false;
    return entries.last.isCheckIn;
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
              pointsEarned: isPresent ? (i % 2 == 0 ? 20 : 10) : 0,
            );
            if (isPresent) {
              // Create multiple entries for some days
              if (i % 4 == 0) {
                // Multiple check-ins/check-outs (e.g., with lunch break)
                record.entries.addAll([
                  AttendanceEntry(
                    timestamp: DateTime(date.year, date.month, date.day, 9, 0),
                    isCheckIn: true,
                  ),
                  AttendanceEntry(
                    timestamp: DateTime(
                      date.year,
                      date.month,
                      date.day,
                      12,
                      30,
                    ),
                    isCheckIn: false,
                  ), // Lunch out
                  AttendanceEntry(
                    timestamp: DateTime(
                      date.year,
                      date.month,
                      date.day,
                      13,
                      30,
                    ),
                    isCheckIn: true,
                  ), // Lunch back
                  AttendanceEntry(
                    timestamp: DateTime(
                      date.year,
                      date.month,
                      date.day,
                      17,
                      30,
                    ),
                    isCheckIn: false,
                  ),
                ]);
              } else {
                // Single check-in/check-out
                record.entries.addAll([
                  AttendanceEntry(
                    timestamp: DateTime(
                      date.year,
                      date.month,
                      date.day,
                      9 + (i % 2),
                      30,
                    ),
                    isCheckIn: true,
                  ),
                  AttendanceEntry(
                    timestamp: DateTime(
                      date.year,
                      date.month,
                      date.day,
                      17 + (i % 2),
                      0,
                    ),
                    isCheckIn: false,
                  ),
                ]);
              }
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

  void _toggleAttendance() {
    final today = DateTime(
      _currentTime.year,
      _currentTime.month,
      _currentTime.day,
    );

    setState(() {
      final record = _attendanceRecords.putIfAbsent(
        today,
        () => LocalAttendanceRecord(date: today),
      );

      final isCheckIn = !record.isCurrentlyCheckedIn;
      record.entries.add(
        AttendanceEntry(timestamp: _currentTime, isCheckIn: isCheckIn),
      );

      record.isPresent = true;

      if (!isCheckIn) {
        final duration = record.workDuration;
        final previousPoints = record.pointsEarned;
        if (duration.inHours >= 8) {
          record.pointsEarned = 20;
        } else if (duration.inMinutes > 0) {
          record.pointsEarned = 10;
        }
        _totalPoints += record.pointsEarned - previousPoints;
      }

      _calculateStats();
    });

    final record = _attendanceRecords[today]!;
    final isCheckIn = record.isCurrentlyCheckedIn;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${isCheckIn ? 'Checked in' : 'Checked out'} at ${_formatTime(_currentTime)} ✓',
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
                  builder: (_) =>
                      AttendanceHistoryScreen(records: _attendanceRecords),
                ),
              ),
              child: const Text('History',style: TextStyle(color: AppColors.gold),),
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
              child: const Text('Stats',style: TextStyle(color: AppColors.gold),),
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

                    // Check-In/Out Section
                    if (todayRecord == null || todayRecord.entries.isEmpty)
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
                          onPressed: _toggleAttendance,
                        ),
                      )
                    else
                      Column(
                        children: [
                          // Today's Entries List
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
                                ...todayRecord.entries.map(
                                  (entry) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          entry.isCheckIn
                                              ? 'Check In'
                                              : 'Check Out',
                                          style: TextStyle(
                                            color: entry.isCheckIn
                                                ? AppColors.success
                                                : AppColors.warning,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          _formatTime(entry.timestamp),
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
                                      '${todayRecord.workDuration.inHours}h ${todayRecord.workDuration.inMinutes.remainder(60)}m',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF10B981),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Points Earned',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '+${todayRecord.pointsEarned}',
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
                          const SizedBox(height: 12),
                          // Toggle Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                backgroundColor:
                                    todayRecord.isCurrentlyCheckedIn
                                    ? AppColors.warning
                                    : AppColors.success,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: Icon(
                                todayRecord.isCurrentlyCheckedIn
                                    ? Icons.logout
                                    : Icons.login,
                              ),
                              label: Text(
                                todayRecord.isCurrentlyCheckedIn
                                    ? 'Check Out'
                                    : 'Check In',
                                style: const TextStyle(fontSize: 16),
                              ),
                              onPressed: _toggleAttendance,
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
      ),
    );
  }
}
