import 'dart:async';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../core/constants/color_constants.dart';
import '../../core/enums/attendance_module.dart';

class AttendanceView extends StatefulWidget {
  const AttendanceView({super.key});

  @override
  State<AttendanceView> createState() => _AttendanceViewState();
}

class _AttendanceViewState extends State<AttendanceView> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime _currentTime = DateTime.now();
  Timer? _timer;

  final Map<DateTime, AttendanceRecord> _attendanceData = {};
  final List<DateTime> _holidays = [
    DateTime.utc(2025, 10, 2),
    DateTime.utc(2025, 12, 25),
  ];

  int _points = 0;
  int _streak = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _currentTime = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  AttendanceRecord _getOrCreateTodayRecord() {
    final today = DateTime.utc(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );

    if (!_attendanceData.containsKey(today)) {
      _attendanceData[today] = AttendanceRecord(
        date: today,
        status: AttendanceStatus.absent,
      );
    }
    return _attendanceData[today]!;
  }

  void _punchIn() {
    final record = _getOrCreateTodayRecord();
    if (record.punchIn != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Already punched in today!')),
      );
      return;
    }

    setState(() {
      record.punchIn = DateTime.now();
      record.status = AttendanceStatus.present;
      _points += 10;
      _streak += 1;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Punch In Success! +10 points. Streak: $_streak')),
    );
  }

  void _punchOut() {
    final record = _getOrCreateTodayRecord();
    if (record.punchIn == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('You must punch in first!')));
      return;
    }
    if (record.punchOut != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Already punched out today!')),
      );
      return;
    }

    setState(() {
      record.punchOut = DateTime.now();
      final workedHours = record.workDuration.inMinutes / 60.0;

      if (workedHours >= 9) {
        record.status = AttendanceStatus.present;
        _points += 20;
      } else if (workedHours > 0) {
        record.status = AttendanceStatus.halfDay;
        _points += 10;
      } else {
        record.status = AttendanceStatus.absent;
        _streak = 0;
      }
    });

    final duration = record.workDuration;
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Work Duration: $hours h $minutes m. Total Points: $_points',
        ),
      ),
    );
  }

  AttendanceStatus? _getStatusForDay(DateTime day) {
    if (_holidays.any((h) => isSameDay(h, day))) {
      return AttendanceStatus.holiday;
    }
    if (day.weekday == DateTime.saturday || day.weekday == DateTime.sunday) {
      return AttendanceStatus.weekend;
    }

    final record = _attendanceData[DateTime.utc(day.year, day.month, day.day)];
    if (record != null) {
      final now = DateTime.now();
      final dayEnd = DateTime.utc(day.year, day.month, day.day, 23, 59, 59);
      if (record.punchIn == null && dayEnd.isBefore(now)) {
        return AttendanceStatus.absent;
      }
      return record.status;
    }

    return null;
  }

  Color _getStatusColor(AttendanceStatus? status) {
    switch (status) {
      case AttendanceStatus.present:
        return Colors.green;
      case AttendanceStatus.halfDay:
        return Colors.orange;
      case AttendanceStatus.absent:
        return Colors.red;
      case AttendanceStatus.leave:
        return Colors.blue;
      case AttendanceStatus.holiday:
        return Colors.purple;
      case AttendanceStatus.weekend:
        return Colors.grey;
      default:
        return Colors.transparent;
    }
  }

  String _formatTime(DateTime time) {
    return "${time.hour.toString().padLeft(2, '0')}:"
        "${time.minute.toString().padLeft(2, '0')}:"
        "${time.second.toString().padLeft(2, '0')}";
  }

  String _formatDate(DateTime time) {
    return "${time.day.toString().padLeft(2, '0')}-"
        "${time.month.toString().padLeft(2, '0')}-"
        "${time.year}";
  }

  @override
  Widget build(BuildContext context) {
    final record = _getOrCreateTodayRecord();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Attendance Mark"),
        centerTitle: true,
        backgroundColor: ColorConstants.white,
        surfaceTintColor: ColorConstants.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.shade300, height: 1),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      "Today: ${_formatDate(_currentTime)}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Current Time: ${_formatTime(_currentTime)}",
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: record.punchIn == null
                            ? Colors.green
                            : (record.punchOut == null
                            ? Colors.orange
                            : Colors.grey),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: Icon(
                        record.punchIn == null
                            ? Icons.login
                            : (record.punchOut == null
                            ? Icons.logout
                            : Icons.check),
                      ),
                      label: Text(
                        record.punchIn == null
                            ? "Punch In"
                            : (record.punchOut == null ? "Punch Out" : "Done"),
                        style: const TextStyle(fontSize: 18),
                      ),
                      onPressed: () {
                        if (record.punchIn == null) {
                          _punchIn();
                        } else if (record.punchOut == null) {
                          _punchOut();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'You have already punched out today!',
                              ),
                            ),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    if (record.punchIn != null)
                      Text("Punch In: ${_formatTime(record.punchIn!)}"),
                    if (record.punchOut != null)
                      Text("Punch Out: ${_formatTime(record.punchOut!)}"),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              child: TableCalendar(
                focusedDay: _focusedDay,
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, day, events) {
                    final status = _getStatusForDay(day);
                    if (status != null) {
                      return Positioned(
                        bottom: 8,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: _getStatusColor(status),
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    }
                    return null;
                  },
                  todayBuilder: (context, day, focusedDay) {
                    final status = _getStatusForDay(day);
                    final color = _getStatusColor(status);

                    return Container(
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        border: Border.all(color: color, width: 2),
                        color: color.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${day.day}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 12,
                runSpacing: 6,
                children: [
                  _buildLegendDot(Colors.green, 'Present'),
                  _buildLegendDot(Colors.red, 'Absent'),
                  _buildLegendDot(Colors.orange, 'Half Day'),
                  _buildLegendDot(Colors.blue, 'Leave'),
                  _buildLegendDot(Colors.purple, 'Holiday'),
                  _buildLegendDot(Colors.grey, 'Weekend'),
                ],
              ),
            ),
            const SizedBox(height: 60),
            Text("Total Points: $_points"),
            Text("Current Streak: $_streak days"),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
