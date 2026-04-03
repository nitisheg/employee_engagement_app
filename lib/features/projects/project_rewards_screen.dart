import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../core/widgets/common_widgets.dart';

class ProjectRewardsScreen extends StatefulWidget {
  const ProjectRewardsScreen({super.key});

  @override
  State<ProjectRewardsScreen> createState() => _ProjectRewardsScreenState();
}

class _ProjectRewardsScreenState extends State<ProjectRewardsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const List<Map<String, dynamic>> _activeProjects = [
    {
      'name': 'Mobile App Redesign',
      'desc': 'Help redesign our customer-facing mobile application with modern UI/UX principles.',
      'points': 1500,
      'team': 5,
      'duration': '3 months',
      'skills': ['Flutter', 'UI/UX', 'Figma'],
      'color': AppColors.primary,
      'icon': Icons.phone_android_rounded,
    },
    {
      'name': 'Data Analytics Dashboard',
      'desc': 'Build an internal analytics dashboard to visualize KPIs and business metrics.',
      'points': 2000,
      'team': 3,
      'duration': '2 months',
      'skills': ['Python', 'SQL', 'Tableau'],
      'color': Color(0xFF10B981),
      'icon': Icons.bar_chart_rounded,
    },
    {
      'name': 'Onboarding Automation',
      'desc': 'Automate the employee onboarding workflow to reduce manual effort and improve experience.',
      'points': 1200,
      'team': 4,
      'duration': '6 weeks',
      'skills': ['HR', 'Automation', 'Process Design'],
      'color': Color(0xFFF59E0B),
      'icon': Icons.auto_awesome_rounded,
    },
    {
      'name': 'Internal Knowledge Base',
      'desc': 'Create and maintain a comprehensive internal knowledge base for all departments.',
      'points': 800,
      'team': 6,
      'duration': '1 month',
      'skills': ['Writing', 'Documentation', 'Research'],
      'color': Color(0xFFEC4899),
      'icon': Icons.menu_book_rounded,
    },
  ];

  static const List<Map<String, dynamic>> _myProjects = [
    {
      'name': 'API Integration Sprint',
      'status': 'Completed',
      'earned': 1000,
      'pending': 0,
      'role': 'Lead Developer',
      'color': Color(0xFF10B981),
      'icon': Icons.api_rounded,
    },
    {
      'name': 'Security Audit',
      'status': 'In Progress',
      'earned': 400,
      'pending': 600,
      'role': 'Contributor',
      'color': Color(0xFFF59E0B),
      'icon': Icons.security_rounded,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showVolunteerDialog(String projectName) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Volunteer for Project',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        content: Text(
          'Would you like to volunteer for "$projectName"?\n\nYour manager will be notified for approval.',
          style: GoogleFonts.poppins(fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: GoogleFonts.poppins(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              AppSnackBar.show(
                context,
                message: 'Volunteered for $projectName!',
                type: AppSnackBarType.success,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Volunteer',
                style: GoogleFonts.poppins(
                    color: AppColors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: Row(
                      children: [
                        if (Navigator.of(context).canPop())
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                                color: AppColors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Project Rewards',
                                  style: GoogleFonts.poppins(
                                      color: AppColors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700)),
                              Text(
                                  'Volunteer for projects to earn bonus rewards',
                                  style: GoogleFonts.poppins(
                                      color:
                                          AppColors.white.withValues(alpha: 0.8),
                                      fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  TabBar(
                    controller: _tabController,
                    indicatorColor: AppColors.white,
                    indicatorWeight: 3,
                    labelColor: AppColors.white,
                    unselectedLabelColor:
                        AppColors.white.withValues(alpha: 0.6),
                    labelStyle: GoogleFonts.poppins(
                        fontSize: 14, fontWeight: FontWeight.w600),
                    tabs: const [
                      Tab(text: 'Active Projects'),
                      Tab(text: 'My Projects'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Active projects tab
                ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _activeProjects.length,
                  itemBuilder: (context, i) {
                    final p = _activeProjects[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                              color: AppColors.black.withValues(alpha: 0.06),
                              blurRadius: 10,
                              offset: const Offset(0, 3))
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: (p['color'] as Color)
                                  .withValues(alpha: 0.08),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(18),
                                topRight: Radius.circular(18),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: (p['color'] as Color)
                                        .withValues(alpha: 0.15),
                                    borderRadius:
                                        BorderRadius.circular(12),
                                  ),
                                  child: Icon(p['icon'] as IconData,
                                      color: p['color'] as Color,
                                      size: 24),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(p['name'] as String,
                                          style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 15)),
                                      Row(
                                        children: [
                                          Icon(
                                              Icons.access_time_rounded,
                                              size: 12,
                                              color:
                                                  AppColors.textSecondary),
                                          const SizedBox(width: 3),
                                          Text(p['duration'] as String,
                                              style: GoogleFonts.poppins(
                                                  fontSize: 11,
                                                  color: AppColors
                                                      .textSecondary)),
                                          const SizedBox(width: 10),
                                          Icon(Icons.people_rounded,
                                              size: 12,
                                              color:
                                                  AppColors.textSecondary),
                                          const SizedBox(width: 3),
                                          Text(
                                              '${p['team']} members',
                                              style: GoogleFonts.poppins(
                                                  fontSize: 11,
                                                  color: AppColors
                                                      .textSecondary)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                PointsBadge(points: p['points'] as int),
                              ],
                            ),
                          ),
                          // Body
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(p['desc'] as String,
                                    style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                        height: 1.5)),
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 6,
                                  children:
                                      (p['skills'] as List<String>)
                                          .map((s) => Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 3),
                                                decoration: BoxDecoration(
                                                  color: (p['color']
                                                          as Color)
                                                      .withValues(alpha: 0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8),
                                                ),
                                                child: Text(s,
                                                    style:
                                                        GoogleFonts.poppins(
                                                            fontSize: 10,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: p['color']
                                                                as Color)),
                                              ))
                                          .toList(),
                                ),
                                const SizedBox(height: 12),
                                GestureDetector(
                                  onTap: () => _showVolunteerDialog(
                                      p['name'] as String),
                                  child: Container(
                                    width: double.infinity,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      gradient: AppColors.primaryGradient,
                                      borderRadius:
                                          BorderRadius.circular(10),
                                    ),
                                    child: Center(
                                      child: Text('Volunteer',
                                          style: GoogleFonts.poppins(
                                              color: AppColors.white,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(
                        delay: Duration(milliseconds: 100 + i * 70));
                  },
                ),

                // My projects tab
                ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _myProjects.length,
                  itemBuilder: (context, i) {
                    final p = _myProjects[i];
                    final isCompleted = p['status'] == 'Completed';
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: (p['color'] as Color)
                                .withValues(alpha: 0.3)),
                        boxShadow: [
                          BoxShadow(
                              color: AppColors.black.withValues(alpha: 0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 3))
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: (p['color'] as Color)
                                  .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(p['icon'] as IconData,
                                color: p['color'] as Color, size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(p['name'] as String,
                                    style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14)),
                                Text(p['role'] as String,
                                    style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        color: AppColors.textSecondary)),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: (isCompleted
                                                ? AppColors.success
                                                : AppColors.warning)
                                            .withValues(alpha: 0.12),
                                        borderRadius:
                                            BorderRadius.circular(10),
                                      ),
                                      child: Text(p['status'] as String,
                                          style: GoogleFonts.poppins(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                              color: isCompleted
                                                  ? AppColors.success
                                                  : AppColors.warning)),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                        '+${p['earned']} pts earned',
                                        style: GoogleFonts.poppins(
                                            fontSize: 11,
                                            color: AppColors.success,
                                            fontWeight: FontWeight.w600)),
                                    if ((p['pending'] as int) > 0) ...[
                                      const SizedBox(width: 4),
                                      Text(
                                          '(+${p['pending']} pending)',
                                          style: GoogleFonts.poppins(
                                              fontSize: 10,
                                              color: AppColors.warning)),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(
                        delay: Duration(milliseconds: 100 + i * 80));
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

