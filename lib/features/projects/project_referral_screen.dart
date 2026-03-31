import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/common_widgets.dart';

class ProjectReferralScreen extends StatefulWidget {
  const ProjectReferralScreen({super.key});

  @override
  State<ProjectReferralScreen> createState() => _ProjectReferralScreenState();
}

class _ProjectReferralScreenState extends State<ProjectReferralScreen> {
  static const String _referralCode = 'ENG-AJ-2026';

  static const List<Map<String, dynamic>> _referrals = [
    {
      'company': 'TechNova Solutions',
      'referredBy': 'You',
      'project': 'Cloud Migration',
      'status': 'Completed',
      'reward': 8000,
      'currency': '₹',
      'date': 'Jan 2026',
    },
    {
      'company': 'DataStream Inc.',
      'referredBy': 'You',
      'project': 'Analytics Platform',
      'status': 'In Progress',
      'reward': 5000,
      'currency': '₹',
      'date': 'Feb 2026',
    },
    {
      'company': 'GreenTech Pvt Ltd',
      'referredBy': 'You',
      'project': 'IoT Dashboard',
      'status': 'Pending',
      'reward': 6000,
      'currency': '₹',
      'date': 'Mar 2026',
    },
  ];

  void _copyCode() {
    Clipboard.setData(const ClipboardData(text: _referralCode));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Referral code copied!',
            style: GoogleFonts.poppins()),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Completed':
        return AppColors.success;
      case 'In Progress':
        return AppColors.warning;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.primary,
            leading: Navigator.of(context).canPop()
                ? IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  )
                : null,
            title: Text('Referral Rewards',
                style: GoogleFonts.poppins(
                    color: Colors.white, fontWeight: FontWeight.w600)),
            flexibleSpace: Container(
                decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient)),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary cards
                  Row(
                    children: [
                      Expanded(
                        child: _SummaryCard(
                          label: 'Total Earned',
                          value: '₹15,000',
                          icon: Icons.account_balance_wallet_rounded,
                          color: AppColors.success,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _SummaryCard(
                          label: 'Pending',
                          value: '₹5,000',
                          icon: Icons.pending_rounded,
                          color: AppColors.warning,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _SummaryCard(
                          label: 'Projects',
                          value: '3',
                          icon: Icons.folder_rounded,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 100.ms),
                  const SizedBox(height: 20),

                  // Referral code card
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.share_rounded,
                                  color: Colors.white, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Text('Your Referral Code',
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16)),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: AppColors.primary
                                    .withValues(alpha: 0.3),
                                style: BorderStyle.solid),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _referralCode,
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 20,
                                    color: AppColors.primary,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: _copyCode,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    gradient: AppColors.primaryGradient,
                                    borderRadius:
                                        BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.copy_rounded,
                                          color: Colors.white, size: 14),
                                      const SizedBox(width: 4),
                                      Text('Copy',
                                          style: GoogleFonts.poppins(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Share this code with companies you refer. Earn up to ₹10,000 per successful project placement.',
                          style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              height: 1.5),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 150.ms),
                  const SizedBox(height: 20),

                  // Referral history
                  SectionHeader(title: 'Referral History')
                      .animate()
                      .fadeIn(delay: 200.ms),
                  const SizedBox(height: 12),

                  ..._referrals.asMap().entries.map((entry) {
                    final i = entry.key;
                    final r = entry.value;
                    final statusColor = _statusColor(r['status'] as String);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 3))
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  color: statusColor
                                      .withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(Icons.business_rounded,
                                    color: statusColor, size: 24),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(r['company'] as String,
                                        style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                            color:
                                                AppColors.textPrimary)),
                                    Text(r['project'] as String,
                                        style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color:
                                                AppColors.textSecondary)),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: statusColor
                                      .withValues(alpha: 0.12),
                                  borderRadius:
                                      BorderRadius.circular(20),
                                ),
                                child: Text(r['status'] as String,
                                    style: GoogleFonts.poppins(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: statusColor)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Divider(color: Colors.grey.shade100),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                      Icons.calendar_today_rounded,
                                      size: 12,
                                      color: AppColors.textSecondary),
                                  const SizedBox(width: 4),
                                  Text(r['date'] as String,
                                      style: GoogleFonts.poppins(
                                          fontSize: 11,
                                          color: AppColors.textSecondary)),
                                ],
                              ),
                              Text(
                                '${r['currency']}${r['reward']}',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: r['status'] == 'Completed'
                                      ? AppColors.success
                                      : r['status'] == 'In Progress'
                                          ? AppColors.warning
                                          : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ).animate().fadeIn(
                        delay: Duration(milliseconds: 250 + i * 70));
                  }),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          SliverSafeArea(
            top: false,
            sliver: const SliverToBoxAdapter(child: SizedBox.shrink()),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 3))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(value,
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: AppColors.textPrimary)),
          Text(label,
              style: GoogleFonts.poppins(
                  fontSize: 10, color: AppColors.textSecondary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
