import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/common_widgets.dart';

class _Cert {
  final String name;
  final String org;
  final String issueDate;
  final String? expiryDate;
  final String credentialId;
  final String status;
  final String visibility;

  const _Cert({
    required this.name,
    required this.org,
    required this.issueDate,
    this.expiryDate,
    required this.credentialId,
    required this.status,
    required this.visibility,
  });
}

class CertificationsScreen extends StatefulWidget {
  const CertificationsScreen({super.key});

  @override
  State<CertificationsScreen> createState() => _CertificationsScreenState();
}

class _CertificationsScreenState extends State<CertificationsScreen> {
  final List<_Cert> _certs = [
    const _Cert(
      name: 'AWS Cloud Practitioner',
      org: 'Amazon Web Services',
      issueDate: 'Jan 2026',
      expiryDate: 'Jan 2029',
      credentialId: 'AWS-CLF-001234',
      status: 'Verified',
      visibility: 'Organization',
    ),
    const _Cert(
      name: 'Google Data Analytics',
      org: 'Google',
      issueDate: 'Mar 2026',
      expiryDate: null,
      credentialId: 'GDA-56789',
      status: 'Pending',
      visibility: 'Team',
    ),
    const _Cert(
      name: 'PMP Certification',
      org: 'PMI',
      issueDate: 'Dec 2025',
      expiryDate: 'Dec 2028',
      credentialId: 'PMP-9871234',
      status: 'Verified',
      visibility: 'Organization',
    ),
    const _Cert(
      name: 'Scrum Master',
      org: 'Scrum Alliance',
      issueDate: 'Feb 2026',
      expiryDate: 'Feb 2028',
      credentialId: 'CSM-456789',
      status: 'Pending',
      visibility: 'Management',
    ),
  ];

  // Add certification form fields
  final _nameCtrl = TextEditingController();
  final _orgCtrl = TextEditingController();
  final _issueDateCtrl = TextEditingController();
  final _expiryCtrl = TextEditingController();
  final _credIdCtrl = TextEditingController();
  String _visibilityOption = 'Organization';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _orgCtrl.dispose();
    _issueDateCtrl.dispose();
    _expiryCtrl.dispose();
    _credIdCtrl.dispose();
    super.dispose();
  }

  void _showAddCertSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 48,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Add Certification',
                    style: GoogleFonts.poppins(
                        fontSize: 20, fontWeight: FontWeight.w700)),
                const SizedBox(height: 20),
                _FormField(controller: _nameCtrl, label: 'Certificate Name', hint: 'e.g. AWS Cloud Practitioner'),
                const SizedBox(height: 12),
                _FormField(controller: _orgCtrl, label: 'Issuing Organization', hint: 'e.g. Amazon Web Services'),
                const SizedBox(height: 12),
                _FormField(controller: _issueDateCtrl, label: 'Issue Date', hint: 'MM/YYYY'),
                const SizedBox(height: 12),
                _FormField(controller: _expiryCtrl, label: 'Expiry Date (optional)', hint: 'MM/YYYY'),
                const SizedBox(height: 12),
                _FormField(controller: _credIdCtrl, label: 'Credential ID', hint: 'e.g. AWS-CLF-001234'),
                const SizedBox(height: 16),
                Text('Visibility',
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 8),
                ...['Organization', 'Team', 'Management only'].map(
                  (opt) => GestureDetector(
                    onTap: () => setModalState(
                        () => _visibilityOption = opt),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _visibilityOption == opt
                                    ? AppColors.primary
                                    : Colors.grey.shade400,
                                width: 2,
                              ),
                              color: _visibilityOption == opt
                                  ? AppColors.primary
                                  : Colors.transparent,
                            ),
                            child: _visibilityOption == opt
                                ? const Icon(Icons.check_rounded,
                                    size: 12, color: Colors.white)
                                : null,
                          ),
                          const SizedBox(width: 10),
                          Text(opt,
                              style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: _visibilityOption == opt
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  color: _visibilityOption == opt
                                      ? AppColors.primary
                                      : AppColors.textPrimary)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                GradientButton(
                  label: 'Add Certification',
                  icon: Icons.add_rounded,
                  onTap: () {
                    if (_nameCtrl.text.isNotEmpty &&
                        _orgCtrl.text.isNotEmpty) {
                      setState(() {
                        _certs.add(_Cert(
                          name: _nameCtrl.text,
                          org: _orgCtrl.text,
                          issueDate: _issueDateCtrl.text.isEmpty
                              ? 'Mar 2026'
                              : _issueDateCtrl.text,
                          expiryDate: _expiryCtrl.text.isEmpty
                              ? null
                              : _expiryCtrl.text,
                          credentialId: _credIdCtrl.text.isEmpty
                              ? 'CRED-000'
                              : _credIdCtrl.text,
                          status: 'Pending',
                          visibility: _visibilityOption,
                        ));
                      });
                      _nameCtrl.clear();
                      _orgCtrl.clear();
                      _issueDateCtrl.clear();
                      _expiryCtrl.clear();
                      _credIdCtrl.clear();
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Certification added!',
                              style: GoogleFonts.poppins()),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final verifiedCount =
        _certs.where((c) => c.status == 'Verified').length;

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddCertSheet,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text('Add Cert',
            style: GoogleFonts.poppins(
                color: Colors.white, fontWeight: FontWeight.w600)),
      ),
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
            title: Text('Certifications',
                style: GoogleFonts.poppins(
                    color: Colors.white, fontWeight: FontWeight.w600)),
            flexibleSpace: Container(
                decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient)),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: (MediaQuery.of(context).size.width * 0.042).clamp(12.0, 24.0),
                vertical: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Points summary
                  AppCard(
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                              Icons.workspace_premium_rounded,
                              color: Colors.white,
                              size: 28),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Certification Points',
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15)),
                              Text(
                                  '$verifiedCount verified • ${_certs.length} total',
                                  style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                        PointsBadge(points: verifiedCount * 100),
                      ],
                    ),
                  ).animate().fadeIn(delay: 100.ms),
                  const SizedBox(height: 20),

                  SectionHeader(title: 'My Certifications')
                      .animate()
                      .fadeIn(delay: 150.ms),
                  const SizedBox(height: 12),

                  ..._certs.asMap().entries.map((entry) {
                    final cert = entry.value;
                    final isVerified = cert.status == 'Verified';
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: isVerified
                                ? AppColors.success.withValues(alpha: 0.3)
                                : AppColors.warning.withValues(alpha: 0.3)),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
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
                                  color:
                                      Colors.teal.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                    Icons.workspace_premium_rounded,
                                    color: Colors.teal,
                                    size: 24),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(cert.name,
                                        style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                            color: AppColors.textPrimary)),
                                    Text(cert.org,
                                        style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: AppColors.textSecondary)),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: (isVerified
                                          ? AppColors.success
                                          : AppColors.warning)
                                      .withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(cert.status,
                                    style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: isVerified
                                            ? AppColors.success
                                            : AppColors.warning)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              _InfoChip(
                                  icon: Icons.calendar_today_rounded,
                                  label: 'Issued: ${cert.issueDate}'),
                              if (cert.expiryDate != null)
                                _InfoChip(
                                    icon: Icons.event_rounded,
                                    label: 'Expires: ${cert.expiryDate}'),
                              _InfoChip(
                                  icon: Icons.badge_rounded,
                                  label: cert.credentialId),
                              _InfoChip(
                                  icon: Icons.visibility_rounded,
                                  label: cert.visibility),
                            ],
                          ),
                        ],
                      ),
                    ).animate().fadeIn(
                        delay: Duration(
                            milliseconds: 200 + entry.key * 60));
                  }),
                  const SizedBox(height: 100),
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

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(label,
              style: GoogleFonts.poppins(
                  fontSize: 11, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;

  const _FormField(
      {required this.controller,
      required this.label,
      required this.hint});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
      ),
    );
  }
}
