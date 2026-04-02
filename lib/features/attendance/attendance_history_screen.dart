import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/common_widgets.dart';
import '../../models/attendance_model.dart';
import '../../providers/attendance_provider.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  State<AttendanceHistoryScreen> createState() =>
      _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  String? _selectedMonth;

  @override
  void initState() {
    super.initState();
    // Fetch initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AttendanceProvider>();
      provider.fetchAttendanceHistory();
    });
  }

  Color _getStatusColor(AttendanceRecord record) {
    if (record.sessions.isNotEmpty) {
      return AppColors.success; // Present if has sessions
    }
    return AppColors.error; // Absent if no sessions
  }

  String _formatDate(DateTime date) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${days[date.weekday - 1]}, ${date.day} ${months[date.month - 1]}';
  }

  String _formatTime(DateTime? time) {
    if (time == null) return '--:--';
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }

  String _getStatusText(AttendanceRecord record) {
    if (record.sessions.isNotEmpty) {
      return 'Present';
    }
    return 'Absent';
  }

  void _showMonthPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        final now = DateTime.now();
        final months = List.generate(12, (index) {
          final date = DateTime(now.year, index + 1);
          return '${date.year}-${(index + 1).toString().padLeft(2, '0')}';
        });

        return Container(
          height: 300,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Select Month',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: months.length,
                  itemBuilder: (context, index) {
                    final month = months[index];
                    return ListTile(
                      title: Text(month),
                      onTap: () {
                        setState(() {
                          _selectedMonth = month;
                        });
                        context
                            .read<AttendanceProvider>()
                            .fetchAttendanceHistory(month: month);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AttendanceProvider>(
      builder: (context, provider, child) {
        final attendanceHistory = provider.attendanceHistory;

        return SafeArea(
          top: false,
          child: Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              title: const Text('Attendance History'),
              centerTitle: true,
              backgroundColor: AppColors.primary,
              surfaceTintColor: Colors.white,
              elevation: 0,
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1),
                child: Container(color: Colors.grey.shade300, height: 1),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.calendar_month),
                  onPressed: _showMonthPicker,
                  tooltip: 'Filter by month',
                ),
              ],
            ),
            body: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : attendanceHistory == null || attendanceHistory.records.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 48,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No attendance records',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      if (_selectedMonth != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          color: AppColors.primary.withOpacity(0.1),
                          child: Row(
                            children: [
                              const Icon(Icons.filter_list, size: 16),
                              const SizedBox(width: 8),
                              Text('Filtered by: $_selectedMonth'),
                              const Spacer(),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _selectedMonth = null;
                                  });
                                  provider.fetchAttendanceHistory();
                                },
                                child: const Text('Clear'),
                              ),
                            ],
                          ),
                        ),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: attendanceHistory.records.length,
                          itemBuilder: (context, index) {
                            final record = attendanceHistory.records[index];
                            final statusColor = _getStatusColor(record);

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: AppCard(
                                child: Row(
                                  children: [
                                    Container(
                                      width: 4,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        color: statusColor,
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(16),
                                          bottomLeft: Radius.circular(16),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                _formatDate(
                                                  DateTime.parse(record.date),
                                                ),
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: statusColor
                                                      .withOpacity(0.2),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  _getStatusText(record),
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: statusColor,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    if (record
                                                        .sessions
                                                        .isNotEmpty) ...[
                                                      Text(
                                                        'First In: ${_formatTime(record.sessions.first.checkIn)}',
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                          color: Colors
                                                              .grey
                                                              .shade700,
                                                        ),
                                                      ),
                                                      if (record
                                                              .sessions
                                                              .length >
                                                          1)
                                                        Text(
                                                          '${record.sessions.length} sessions',
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color: Colors
                                                                .grey
                                                                .shade500,
                                                          ),
                                                        ),
                                                      if (record
                                                              .sessions
                                                              .last
                                                              .checkOut !=
                                                          null)
                                                        Text(
                                                          'Last Out: ${_formatTime(record.sessions.last.checkOut)}',
                                                          style: TextStyle(
                                                            fontSize: 13,
                                                            color: Colors
                                                                .grey
                                                                .shade700,
                                                          ),
                                                        ),
                                                    ],
                                                  ],
                                                ),
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    '${record.totalMinutes ~/ 60}h ${record.totalMinutes % 60}m',
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Color(0xFF10B981),
                                                    ),
                                                  ),
                                                  Text(
                                                    '+${record.pointsEarned} pts',
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Color(0xFFE53935),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}
