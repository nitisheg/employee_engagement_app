import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../core/widgets/common_widgets.dart';
import 'package:file_picker/file_picker.dart';

import '../../providers/certifications_provider.dart';

class CertificationsScreen extends StatefulWidget {
  const CertificationsScreen({super.key});

  @override
  State<CertificationsScreen> createState() => _CertificationsScreenState();
}

class _CertificationsScreenState extends State<CertificationsScreen> {
  final _nameCtrl = TextEditingController();
  final _orgCtrl = TextEditingController();
  final _issueDateCtrl = TextEditingController();
  final _expiryCtrl = TextEditingController();
  final _credIdCtrl = TextEditingController();
  String _visibilityOption = 'Organization';
  File? _selectedFile;

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
      backgroundColor: AppColors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
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
                  Text(
                    'Add Certification',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _FormField(
                    controller: _nameCtrl,
                    label: 'Certificate Name',
                    hint: 'e.g. AWS Cloud Practitioner',
                  ),
                  const SizedBox(height: 12),
                  _FormField(
                    controller: _orgCtrl,
                    label: 'Issuing Organization',
                    hint: 'e.g. Amazon Web Services',
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: ctx,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1970),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setModalState(() {
                          _issueDateCtrl.text =
                              "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                        });
                      }
                    },
                    child: AbsorbPointer(
                      child: _FormField(
                        controller: _issueDateCtrl,
                        label: 'Issue Date',
                        hint: 'YYYY-MM-DD',
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: ctx,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1970),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setModalState(() {
                          _expiryCtrl.text =
                              "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                        });
                      }
                    },
                    child: AbsorbPointer(
                      child: _FormField(
                        controller: _expiryCtrl,
                        label: 'Expiry Date (optional)',
                        hint: 'YYYY-MM-DD',
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _selectedFile != null
                              ? _selectedFile!.path.split('/').last
                              : 'No file selected',
                          style: GoogleFonts.poppins(fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        icon: const Icon(Icons.attach_file, size: 18),
                        label: const Text('Upload'),
                        onPressed: () async {
                          // Use file_picker package for picking files
                          // (You must add file_picker to pubspec.yaml)
                          final result = await FilePicker.platform.pickFiles(
                            type: FileType.custom,
                            allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
                          );
                          if (result != null &&
                              result.files.single.path != null) {
                            setModalState(() {
                              _selectedFile = File(result.files.single.path!);
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _FormField(
                    controller: _credIdCtrl,
                    label: 'Credential ID',
                    hint: 'e.g. AWS-CLF-001234',
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Visibility',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...['Organization', 'Team', 'Management only'].map(
                    (opt) => GestureDetector(
                      onTap: () => setModalState(() => _visibilityOption = opt),
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
                                    : AppColors.transparent,
                              ),
                              child: _visibilityOption == opt
                                  ? const Icon(
                                      Icons.check_rounded,
                                      size: 12,
                                      color: AppColors.white,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              opt,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: _visibilityOption == opt
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: _visibilityOption == opt
                                    ? AppColors.primary
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  GradientButton(
                    label: 'Add Certification',
                    icon: Icons.add_rounded,
                    onTap: () async {
                      String? error;
                      if (_nameCtrl.text.trim().isEmpty) {
                        error = 'Certificate Name is required';
                      } else if (_orgCtrl.text.trim().isEmpty) {
                        error = 'Issuing Organization is required';
                      } else if (_issueDateCtrl.text.trim().isEmpty) {
                        error = 'Issue Date is required';
                      } else if (_credIdCtrl.text.trim().isEmpty) {
                        error = 'Credential ID is required';
                      } else if (_selectedFile == null) {
                        error = 'Certificate file is required';
                      }
                      if (error != null) {
                        AppSnackBar.show(
                          context,
                          message: error,
                          type: AppSnackBarType.error,
                        );
                        return;
                      }

                      final provider = Provider.of<CertificationsProvider>(
                        context,
                        listen: false,
                      );
                      final success = await provider.uploadCertificate(
                        certificateId: _credIdCtrl.text.trim(),
                        title: _nameCtrl.text.trim(),
                        issuer: _orgCtrl.text.trim(),
                        issueDate: _issueDateCtrl.text.trim(),
                        completionDate: _expiryCtrl.text.trim().isEmpty
                            ? null
                            : _expiryCtrl.text.trim(),
                        description: null,
                        file: _selectedFile!,
                      );
                      if (success) {
                        _nameCtrl.clear();
                        _orgCtrl.clear();
                        _issueDateCtrl.clear();
                        _expiryCtrl.clear();
                        _credIdCtrl.clear();
                        setState(() => _selectedFile = null);
                        Navigator.pop(context);
                        AppSnackBar.show(
                          context,
                          message: 'Certification submitted!',
                          type: AppSnackBarType.success,
                        );
                      } else {
                        AppSnackBar.show(
                          context,
                          message:
                              provider.errorMessage ??
                              'Failed to submit certification',
                          type: AppSnackBarType.error,
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CertificationsProvider>(
      builder: (context, provider, _) {
        final certifications = provider.certifications;
        final verifiedCount = certifications
            .where((c) => c.status == 'verified')
            .length;
        return Scaffold(
          backgroundColor: AppColors.background,
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _showAddCertSheet,
            backgroundColor: AppColors.primary,
            icon: const Icon(Icons.add_rounded, color: AppColors.white),
            label: Text(
              'Add Cert',
              style: GoogleFonts.poppins(
                color: AppColors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                backgroundColor: AppColors.primary,
                leading: Navigator.of(context).canPop()
                    ? IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: AppColors.white,
                        ),
                        onPressed: () => Navigator.pop(context),
                      )
                    : null,
                title: Text(
                  'Certifications',
                  style: GoogleFonts.poppins(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                flexibleSpace: Container(
                  decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: (MediaQuery.of(context).size.width * 0.042)
                        .clamp(12.0, 24.0),
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // AppCard(
                      //   child: Row(
                      //     children: [
                      //       Container(
                      //         width: 56,
                      //         height: 56,
                      //         decoration: BoxDecoration(
                      //           gradient: AppColors.primaryGradient,
                      //           borderRadius: BorderRadius.circular(14),
                      //         ),
                      //         child: const Icon(
                      //           Icons.workspace_premium_rounded,
                      //           color: AppColors.white,
                      //           size: 28,
                      //         ),
                      //       ),
                      //       const SizedBox(width: 14),
                      //       Expanded(
                      //         child: Column(
                      //           crossAxisAlignment: CrossAxisAlignment.start,
                      //           children: [
                      //             Text(
                      //               'Certification Points',
                      //               style: GoogleFonts.poppins(
                      //                 fontWeight: FontWeight.w700,
                      //                 fontSize: 15,
                      //               ),
                      //             ),
                      //             Text(
                      //               '$verifiedCount verified • ${certifications.length} total',
                      //               style: GoogleFonts.poppins(
                      //                 fontSize: 12,
                      //                 color: AppColors.textSecondary,
                      //               ),
                      //             ),
                      //           ],
                      //         ),
                      //       ),
                      //       PointsBadge(points: verifiedCount * 100),
                      //     ],
                      //   ),
                      // ).animate().fadeIn(delay: 100.ms),
                      const SizedBox(height: 20),

                      if (provider.isLoading)
                        const Center(child: CircularProgressIndicator()),
                      if (!provider.isLoading && certifications.isEmpty)
                        Center(
                          child: Column(
                            children: [
                              Icon(Icons.workspace_premium_rounded),
                              const SizedBox(height: 12),

                              Text('No certificate found.'),
                            ],
                          ),
                        ),
                      ...certifications.asMap().entries.map((entry) {
                        final cert = entry.value;
                        final isVerified = cert.status == 'verified';
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isVerified
                                  ? AppColors.success.withValues(alpha: 0.3)
                                  : AppColors.warning.withValues(alpha: 0.3),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.black.withValues(alpha: 0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
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
                                      color: AppColors.teal.withValues(
                                        alpha: 0.12,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.workspace_premium_rounded,
                                      color: AppColors.teal,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          cert.title,
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        Text(
                                          cert.issuer,
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          (isVerified
                                                  ? AppColors.success
                                                  : AppColors.warning)
                                              .withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      cert.status,
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: isVerified
                                            ? AppColors.success
                                            : AppColors.warning,
                                      ),
                                    ),
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
                                    label:
                                        'Issued: ${cert.issueDate.toLocal().toString().split('T').first}',
                                  ),
                                  if (cert.completionDate != null)
                                    _InfoChip(
                                      icon: Icons.event_rounded,
                                      label:
                                          'Expires: ${cert.completionDate!.toLocal().toString().split('T').first}',
                                    ),
                                  _InfoChip(
                                    icon: Icons.badge_rounded,
                                    label: cert.certificateId,
                                  ),
                                  if (cert.certificateUrl.isNotEmpty)
                                    _InfoChip(
                                      icon: Icons.link_rounded,
                                      label: 'View File',
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ).animate().fadeIn(
                          delay: Duration(milliseconds: 200 + entry.key * 60),
                        );
                      }),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
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

class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;

  const _FormField({
    required this.controller,
    required this.label,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label, hintText: hint),
    );
  }
}
