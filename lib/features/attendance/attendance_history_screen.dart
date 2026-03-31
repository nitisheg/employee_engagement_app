import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/common_widgets.dart';
import 'attendance_screen.dart';

class AttendanceHistoryScreen extends StatelessWidget {
  final Map<DateTime, LocalAttendanceRecord> records;

  const AttendanceHistoryScreen({Key? key, required this.records})
    : super(key: key);

  Color _getStatusColor(String status) {
    if (status == 'Present') return AppColors.success;
    if (status == 'Late') return AppColors.warning;
    return AppColors.error;
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

  @override
  Widget build(BuildContext context) {
    final sortedEntries = records.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));

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
        ),
        body: sortedEntries.isEmpty
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
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: sortedEntries.length,
                itemBuilder: (context, index) {
                  final entry = sortedEntries[index];
                  final record = entry.value;
                  final statusColor = _getStatusColor(record.status);

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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _formatDate(record.date),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: statusColor.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        record.status,
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
                                          if (record.entries.isNotEmpty) ...[
                                            Text(
                                              'First In: ${_formatTime(record.entries.first.timestamp)}',
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey.shade700,
                                              ),
                                            ),
                                            if (record.entries.length > 2)
                                              Text(
                                                '${record.entries.length} entries',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey.shade500,
                                                ),
                                              ),
                                            if (record.entries.last.isCheckIn ==
                                                false)
                                              Text(
                                                'Last Out: ${_formatTime(record.entries.last.timestamp)}',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.grey.shade700,
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
                                          '${record.workDuration.inHours}h ${record.workDuration.inMinutes.remainder(60)}m',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF10B981),
                                          ),
                                        ),
                                        Text(
                                          '+${record.pointsEarned} pts',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
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
    );
  }
}
