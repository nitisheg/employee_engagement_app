import 'package:employee_engagement_app/features/profile/edit_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/common_widgets.dart';
import '../../providers/auth_provider.dart';
import '../certifications/certifications_screen.dart';
import '../auth/login_screen.dart';
import '../notifications/notifications_screen.dart';
import '../privacy/privacy_settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final auth = context.read<AuthProvider>();
      auth.clearError();
      auth.init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    if (user == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: (MediaQuery.of(context).size.height * 0.27).clamp(
              190.0,
              250.0,
            ),
            pinned: true,
            automaticallyImplyLeading: false,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 16),
                      Container(
                        width: (MediaQuery.of(context).size.width * 0.23).clamp(
                          72.0,
                          100.0,
                        ),
                        height: (MediaQuery.of(context).size.width * 0.23)
                            .clamp(72.0, 100.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.black.withValues(alpha: 0.2),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: user.avatar != null && user.avatar!.isNotEmpty
                              ? Image.network(
                                  user.avatar!,
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                        color: AppColors.primary,
                                        child: Center(
                                          child: Text(
                                            user.initials,
                                            style: const TextStyle(
                                              color: AppColors.white,
                                              fontSize: 28,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ),
                                      ),
                                )
                              : Container(
                                  color: AppColors.primary,
                                  child: Center(
                                    child: Text(
                                      user.initials,
                                      style: const TextStyle(
                                        color: AppColors.white,
                                        fontSize: 28,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        user.name,
                        style: GoogleFonts.poppins(
                          color: AppColors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '${user.designation ?? 'Employee'} • ${user.department}',
                        style: GoogleFonts.poppins(
                          color: AppColors.white.withValues(alpha: 0.85),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            title: Text(
              'My Profile',
              style: GoogleFonts.poppins(
                color: AppColors.white,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: AppColors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const EditProfileScreen(),
                    ),
                  );
                },
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: (MediaQuery.of(context).size.width * 0.042).clamp(
                  12.0,
                  24.0,
                ),
                vertical: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _ProfileStatCard(
                          value: user.totalPoints.toString(),
                          label: 'Points',
                          icon: Icons.stars_rounded,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _ProfileStatCard(
                          value: '#${user.rank}',
                          label: 'Rank',
                          icon: Icons.leaderboard_rounded,
                          color: AppColors.warning,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _ProfileStatCard(
                          value: user.level,
                          label: 'Level',
                          icon: Icons.emoji_events_rounded,
                          color: AppColors.gold,
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 100.ms),
                  const SizedBox(height: 20),

                  // Level progress
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Level Progress',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.gold.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.emoji_events_rounded,
                                    color: AppColors.gold,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Gold → Platinum',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.gold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        LinearPercentIndicator(
                          lineHeight: 12,
                          percent:
                              (user.levelTargetPoints > 0
                                      ? user.levelProgressPoints /
                                            user.levelTargetPoints
                                      : 0.0)
                                  .clamp(0.0, 1.0),
                          backgroundColor: AppColors.primary.withValues(
                            alpha: 0.12,
                          ),
                          linearGradient: const LinearGradient(
                            colors: [AppColors.primary, AppColors.primaryDark],
                          ),
                          barRadius: const Radius.circular(6),
                          padding: EdgeInsets.zero,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${user.levelProgressPoints} / ${user.levelTargetPoints} pts',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              '${(user.levelTargetPoints > 0 ? (user.levelProgressPoints / user.levelTargetPoints * 100).clamp(0, 100).toStringAsFixed(0) : '0')}% to next',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 150.ms),
                  const SizedBox(height: 20),

                  // Profile Information
                  SectionHeader(
                    title: 'Profile Information',
                  ).animate().fadeIn(delay: 180.ms),
                  const SizedBox(height: 12),
                  AppCard(
                    child: Column(
                      children: [
                        if (user.employeeId.isNotEmpty)
                          _ProfileInfoRow(
                            icon: Icons.badge_outlined,
                            label: 'Employee ID',
                            value: user.employeeId,
                          ),
                        _ProfileInfoRow(
                          icon: Icons.email_outlined,
                          label: 'Email',
                          value: user.email,
                        ),
                        if (user.phone != null && user.phone!.isNotEmpty)
                          _ProfileInfoRow(
                            icon: Icons.phone_outlined,
                            label: 'Phone',
                            value: user.phone!,
                          ),
                        if (user.address != null && user.address!.isNotEmpty)
                          _ProfileInfoRow(
                            icon: Icons.location_on_outlined,
                            label: 'Address',
                            value: user.address!,
                          ),
                        _ProfileInfoRow(
                          icon: Icons.business_outlined,
                          label: 'Department',
                          value: user.department,
                        ),
                        _ProfileInfoRow(
                          icon: Icons.work_outline_rounded,
                          label: 'Designation',
                          value: user.designation ?? 'Employee',
                        ),
                        if (user.joiningDate != null && user.joiningDate!.isNotEmpty)
                          _ProfileInfoRow(
                            icon: Icons.calendar_today_outlined,
                            label: 'Joining Date',
                            value: _formatDate(user.joiningDate!),
                          ),
                        _ProfileInfoRow(
                          icon: Icons.verified_user_outlined,
                          label: 'Status',
                          value: user.status[0].toUpperCase() + user.status.substring(1),
                          valueColor: user.status == 'active' ? AppColors.success : AppColors.warning,
                        ),
                        if (user.lastCheckInDate != null)
                          _ProfileInfoRow(
                            icon: Icons.event_available_outlined,
                            label: 'Last Check-In',
                            value: user.lastCheckInDate!,
                            isLast: true,
                          ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 190.ms),
                  const SizedBox(height: 20),

                  // Achievements
                  SectionHeader(
                    title: 'Achievements',
                  ).animate().fadeIn(delay: 200.ms),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: user.badges.isEmpty
                        ? [
                            _AchievementBadge(
                              label: '🏆 Quiz Master',
                              color: AppColors.warning,
                            ),
                            _AchievementBadge(
                              label: '🔥 Streak King',
                              color: AppColors.secondary,
                            ),
                            _AchievementBadge(
                              label: '⚡ Fast Solver',
                              color: AppColors.primary,
                            ),
                            _AchievementBadge(
                              label: '🌟 Team Player',
                              color: AppColors.success,
                            ),
                            _AchievementBadge(
                              label: '📚 Learner',
                              color: AppColors.teal,
                            ),
                          ]
                        : [
                            ...user.badges.map(
                              (badge) => _AchievementBadge(
                                label: badge,
                                color: AppColors.primary,
                              ),
                            ),
                            _AchievementBadge(
                              label: '📚 Learner',
                              color: AppColors.teal,
                            ),
                          ],
                  ).animate().fadeIn(delay: 250.ms),
                  const SizedBox(height: 20),
                  SectionHeader(
                    title: 'My Stats',
                  ).animate().fadeIn(delay: 300.ms),
                  const SizedBox(height: 12),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final crossAxisCount = constraints.maxWidth > 500 ? 4 : 2;
                      final childAspectRatio = constraints.maxWidth > 500
                          ? 1.4
                          : 1.2;
                      return GridView.count(
                        crossAxisCount: crossAxisCount,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: childAspectRatio,
                        children: [
                          StatCard(
                            title: 'Total Points',
                            value: user.totalPoints.toString(),
                            icon: Icons.stars_rounded,
                            color: AppColors.primary,
                          ),
                          StatCard(
                            title: 'Current Streak',
                            value: '${user.currentStreak}d',
                            icon: Icons.local_fire_department_rounded,
                            color: AppColors.secondary,
                          ),
                          StatCard(
                            title: 'Longest Streak',
                            value: '${user.longestStreak}d',
                            icon: Icons.emoji_events_rounded,
                            color: AppColors.gold,
                          ),
                          StatCard(
                            title: 'Rank',
                            value: '#${user.rank}',
                            icon: Icons.leaderboard_rounded,
                            color: AppColors.warning,
                          ),
                        ],
                      );
                    },
                  ).animate().fadeIn(delay: 350.ms),
                  const SizedBox(height: 20),

                  // Recent Activity
                  SectionHeader(
                    title: 'Recent Activity',
                  ).animate().fadeIn(delay: 400.ms),
                  const SizedBox(height: 12),
                  AppCard(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      children: const [
                        _ActivityItem(
                          icon: Icons.quiz_rounded,
                          color: AppColors.primary,
                          title: 'Completed Daily Quiz',
                          subtitle: '+50 pts earned',
                          time: '2h ago',
                        ),
                        _ActivityItem(
                          icon: Icons.emoji_events_rounded,
                          color: AppColors.gold,
                          title: 'Won Sudoku Challenge',
                          subtitle: '+120 pts earned',
                          time: '5h ago',
                        ),
                        _ActivityItem(
                          icon: Icons.check_circle_rounded,
                          color: AppColors.success,
                          title: 'Checked In',
                          subtitle: '+10 pts earned',
                          time: 'Today 9:02 AM',
                        ),
                        _ActivityItem(
                          icon: Icons.workspace_premium_rounded,
                          color: AppColors.teal,
                          title: 'Added Certification',
                          subtitle: 'AWS Cloud Practitioner',
                          time: 'Yesterday',
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 450.ms),
                  const SizedBox(height: 20),

                  // Certifications preview
                  SectionHeader(
                    title: 'Certifications',
                    actionLabel: 'View All',
                    onAction: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CertificationsScreen(),
                      ),
                    ),
                  ).animate().fadeIn(delay: 500.ms),
                  const SizedBox(height: 12),
                  AppCard(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      children: [
                        _CertPreviewItem(
                          name: 'AWS Cloud Practitioner',
                          org: 'Amazon Web Services',
                          status: 'Verified',
                          statusColor: AppColors.success,
                        ),
                        _CertPreviewItem(
                          name: 'Google Data Analytics',
                          org: 'Google',
                          status: 'Pending',
                          statusColor: AppColors.warning,
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 550.ms),
                  const SizedBox(height: 20),

                  // Settings
                  SectionHeader(
                    title: 'Settings',
                  ).animate().fadeIn(delay: 600.ms),
                  const SizedBox(height: 12),
                  AppCard(
                    padding: const EdgeInsets.all(4),
                    child: Column(
                      children: [
                        _SettingsTile(
                          icon: Icons.edit_outlined,
                          label: 'Edit Profile',
                          color: AppColors.primary,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const EditProfileScreen(),
                              ),
                            );
                          },
                        ),
                        _SettingsTile(
                          icon: Icons.notifications_outlined,
                          label: 'Notifications',
                          color: AppColors.warning,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const NotificationsScreen(),
                              ),
                            );
                          },
                        ),
                        _SettingsTile(
                          icon: Icons.lock_outline_rounded,
                          label: 'Privacy',
                          color: AppColors.success,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const PrivacySettingsScreen(),
                              ),
                            );
                          },
                        ),
                        _SettingsTile(
                          icon: Icons.logout_rounded,
                          label: 'Logout',
                          color: AppColors.errorAccent,
                          onTap: () async {
                            final shouldLogout = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text(
                                  'Confirm Logout',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                content: Text(
                                  'Are you sure you want to log out?',
                                  style: GoogleFonts.poppins(),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                    child: Text(
                                      'Cancel',
                                      style: GoogleFonts.poppins(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(true),
                                    child: Text(
                                      'Logout',
                                      style: GoogleFonts.poppins(
                                        color: AppColors.errorAccent,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );

                            if (shouldLogout == true) {
                              await context.read<AuthProvider>().logout();
                              if (!context.mounted) return;
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LoginScreen(),
                                ),
                                (route) => false,
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 650.ms),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileStatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _ProfileStatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _AchievementBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _AchievementBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color.withValues(alpha: 1.0),
        ),
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String time;

  const _ActivityItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _CertPreviewItem extends StatelessWidget {
  final String name;
  final String org;
  final String status;
  final Color statusColor;

  const _CertPreviewItem({
    required this.name,
    required this.org,
    required this.status,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.teal.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.workspace_premium_rounded,
              color: AppColors.teal,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  org,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final bool isLast;

  const _ProfileInfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
          child: Row(
            children: [
              Icon(icon, size: 18, color: AppColors.textSecondary),
              const SizedBox(width: 12),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            color: AppColors.textSecondary.withValues(alpha: 0.12),
          ),
      ],
    );
  }
}

String _formatDate(String rawDate) {
  try {
    final dt = DateTime.parse(rawDate);
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  } catch (_) {
    return rawDate;
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
      title: Text(
        label,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w500,
          fontSize: 14,
          color: label == 'Logout' ? AppColors.errorAccent : AppColors.textPrimary,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: AppColors.textSecondary,
        size: 20,
      ),
      dense: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }
}

