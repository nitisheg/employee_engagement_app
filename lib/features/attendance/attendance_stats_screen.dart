import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/common_widgets.dart';
import '../../providers/attendance_provider.dart';
import '../../models/attendance_model.dart';
import 'package:percent_indicator/percent_indicator.dart';

class AttendanceStatsScreen extends StatefulWidget {
  const AttendanceStatsScreen({super.key});

  @override
  State<AttendanceStatsScreen> createState() => _AttendanceStatsScreenState();
}

class _AttendanceStatsScreenState extends State<AttendanceStatsScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AttendanceProvider>();
      provider.fetchAttendanceHistory();
    });
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
              title: const Text('Attendance Statistics'),
              centerTitle: true,
              backgroundColor: AppColors.primary,
              surfaceTintColor: Colors.white,
              elevation: 0,
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1),
                child: Container(color: Colors.grey.shade300, height: 1),
              ),
            ),
            body: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : attendanceHistory == null
              ? const EmptyStateWidget(
                title: 'No Attendance Data',
                message:
                  'No attendance records were found for this period.',
                icon: Icons.insights_rounded,
                )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Overview Card
                        AppCard(
                          child: Column(
                            children: [
                              const Text(
                                'Attendance Overview',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildChart(attendanceHistory),
                              const SizedBox(height: 24),
                              _buildStats(attendanceHistory),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Streak Section
                        AppCard(child: _buildStreakSection(provider)),
                        const SizedBox(height: 16),
                        // Points Section
                        AppCard(child: _buildPointsSection(attendanceHistory)),
                        const SizedBox(height: 16),
                        // Distribution Chart
                        AppCard(child: _buildDistribution(attendanceHistory)),
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildChart(AttendanceHistory attendanceHistory) {
    final presentDays = attendanceHistory.records
        .where((record) => record.sessions.isNotEmpty)
        .length;
    final totalDays = attendanceHistory.records.length;
    final presentPercentage = totalDays > 0
        ? (presentDays / totalDays) * 100
        : 0.0;

    return CircularPercentIndicator(
      radius: 100,
      lineWidth: 8,
      percent: presentPercentage / 100,
      center: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${presentPercentage.toStringAsFixed(1)}%',
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const Text('Present'),
        ],
      ),
      progressColor: AppColors.success,
      backgroundColor: Colors.grey.shade200,
    );
  }

  Widget _buildStats(AttendanceHistory attendanceHistory) {
    final presentDays = attendanceHistory.records
        .where((record) => record.sessions.isNotEmpty)
        .length;
    final absentDays = attendanceHistory.records
        .where((record) => record.sessions.isEmpty)
        .length;
    final totalDays = presentDays + absentDays;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Column(
          children: [
            Text(
              '$presentDays',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF10B981),
              ),
            ),
            const Text('Present'),
            const SizedBox(height: 8),
            Text(
              '$absentDays',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFFD32F2F),
              ),
            ),
            const Text('Absent'),
          ],
        ),
        Container(width: 1, height: 100, color: Colors.grey.shade300),
        Column(
          children: [
            Text(
              '$totalDays',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6B7280),
              ),
            ),
            const Text('Total'),
            const SizedBox(height: 8),
            const Text('Days', style: TextStyle(fontSize: 14)),
          ],
        ),
      ],
    );
  }

  Widget _buildStreakSection(AttendanceProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Streak Information',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${provider.currentStreak}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF10B981),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('Current Streak'),
                  const Text(
                    'days',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF7043).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${provider.longestStreak}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF7043),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('Best Streak'),
                  const Text(
                    'days',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (provider.streakWarning != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning, color: Colors.orange, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    provider.streakWarning!,
                    style: const TextStyle(color: Colors.orange, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPointsSection(AttendanceHistory attendanceHistory) {
    final totalPoints = attendanceHistory.records.fold<int>(
      0,
      (sum, record) => sum + record.pointsEarned,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Points Earned',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Keep up the good attendance!',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Text(
            '$totalPoints',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFFE53935),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDistribution(AttendanceHistory attendanceHistory) {
    final presentDays = attendanceHistory.records
        .where((record) => record.sessions.isNotEmpty)
        .length;
    final absentDays = attendanceHistory.records
        .where((record) => record.sessions.isEmpty)
        .length;
    final totalDays = presentDays + absentDays;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Daily Distribution',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildStatBar('Present', presentDays, totalDays, AppColors.success),
        const SizedBox(height: 12),
        _buildStatBar('Absent', absentDays, totalDays, AppColors.error),
      ],
    );
  }

  Widget _buildStatBar(String label, int count, int total, Color color) {
    final percentage = total > 0 ? (count / total) * 100 : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text(
              '$count days (${percentage.toStringAsFixed(1)}%)',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage / 100,
            minHeight: 8,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
