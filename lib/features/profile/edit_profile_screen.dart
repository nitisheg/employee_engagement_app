import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/common_widgets.dart';
import '../../providers/profile_provider.dart';
import '../../providers/auth_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _departmentController;
  late TextEditingController _designationController;
  late TextEditingController _currentPasswordController;
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmPasswordController;

  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _showPasswordSection = false;
  XFile? _selectedImage;

  final _formKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
    _departmentController = TextEditingController();
    _designationController = TextEditingController();
    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();

    // Fetch profile data
    Future.microtask(() {
      context.read<ProfileProvider>().fetchProfile();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final user = context.watch<AuthProvider>().user;
    if (user != null && _nameController.text.isEmpty) {
      _nameController.text = user.name ?? '';
      _phoneController.text = user.phone ?? '';
      _addressController.text = user.address ?? '';
      _departmentController.text = user.department ?? '';
      _designationController.text = user.designation ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _departmentController.dispose();
    _designationController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _selectedImage = image);
    }
  }

  void _handleProfileUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await context.read<ProfileProvider>().updateProfile(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      department: _departmentController.text.trim(),
      designation: _designationController.text.trim(),
    );

    if (mounted) {
      if (success) {
        final updatedUser = context.read<ProfileProvider>().user;
        if (updatedUser != null) {
          context.read<AuthProvider>().updateUser(updatedUser);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Profile updated successfully',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      } else {
        final error =
            context.read<ProfileProvider>().errorMessage ??
            'Failed to update profile';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error, style: GoogleFonts.poppins()),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _handleChangePassword() async {
    if (!_passwordFormKey.currentState!.validate()) return;

    final success = await context.read<ProfileProvider>().changePassword(
      currentPassword: _currentPasswordController.text,
      newPassword: _newPasswordController.text,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Password changed successfully',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: AppColors.success,
          ),
        );
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
        setState(() => _showPasswordSection = false);
      } else {
        final error =
            context.read<ProfileProvider>().errorMessage ??
            'Failed to change password';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error, style: GoogleFonts.poppins()),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _handleUploadAvatar() async {
    if (_selectedImage == null) return;

    final success = await context.read<ProfileProvider>().uploadAvatar(
      _selectedImage!.path,
    );

    if (mounted) {
      if (success) {
        final updatedUser = context.read<ProfileProvider>().user;
        if (updatedUser != null) {
          context.read<AuthProvider>().updateUser(updatedUser);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Avatar updated successfully',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: AppColors.success,
          ),
        );
        setState(() => _selectedImage = null);
      } else {
        final error =
            context.read<ProfileProvider>().errorMessage ??
            'Failed to upload avatar';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error, style: GoogleFonts.poppins()),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final _ = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(
          'Edit Profile',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Consumer2<ProfileProvider, AuthProvider>(
          builder: (context, profileProvider, authProvider, _) {
            return SafeArea(
              top: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF6B35), Color(0xFFFF8E53)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primary,
                              width: 2,
                            ),
                          ),
                          child: _selectedImage != null
                              ? ClipOval(
                                  child: Image.file(
                                    File(_selectedImage!.path),
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Center(
                                  child: Text(
                                    authProvider.user?.initials ?? '?',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.image_outlined),
                          label: Text(
                            'Change Avatar',
                            style: GoogleFonts.poppins(),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                        ),
                        if (_selectedImage != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Consumer<ProfileProvider>(
                              builder: (context, provider, _) {
                                return provider.isUploadingAvatar
                                    ? const SizedBox(
                                        height: 36,
                                        width: 36,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : ElevatedButton(
                                        onPressed: _handleUploadAvatar,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.success,
                                          foregroundColor: Colors.white,
                                        ),
                                        child: Text(
                                          'Upload Avatar',
                                          style: GoogleFonts.poppins(),
                                        ),
                                      );
                              },
                            ),
                          ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 100.ms).slideY(begin: -0.1, end: 0),
                  const SizedBox(height: 28),

                  // Personal Information Section
                  Text(
                    'Personal Information',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Name
                        TextFormField(
                          controller: _nameController,
                          textCapitalization: TextCapitalization.words,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Name is required';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            labelText: 'Full Name',
                            prefixIcon: Icon(Icons.person_outline_rounded),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Phone
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: 'Phone Number',
                            prefixIcon: Icon(Icons.phone_outlined),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Address
                        TextFormField(
                          controller: _addressController,
                          decoration: const InputDecoration(
                            labelText: 'Address',
                            prefixIcon: Icon(Icons.location_on_outlined),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Department
                        TextFormField(
                          controller: _departmentController,
                          decoration: const InputDecoration(
                            labelText: 'Department',
                            prefixIcon: Icon(Icons.business_outlined),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Designation
                        TextFormField(
                          controller: _designationController,
                          decoration: const InputDecoration(
                            labelText: 'Designation',
                            prefixIcon: Icon(Icons.badge_outlined),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Submit Profile Button
                        Consumer<ProfileProvider>(
                          builder: (context, provider, _) {
                            return provider.isUpdating
                                ? Container(
                                    height: 54,
                                    decoration: BoxDecoration(
                                      gradient: AppColors.primaryGradient,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    ),
                                  )
                                : GradientButton(
                                    label: 'Save Changes',
                                    icon: Icons.save_rounded,
                                    onTap: _handleProfileUpdate,
                                  );
                          },
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 150.ms).slideY(begin: -0.1, end: 0),
                  const SizedBox(height: 28),

                  // Change Password Section
                  Text(
                    'Security',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (!_showPasswordSection)
                    ElevatedButton.icon(
                      onPressed: () =>
                          setState(() => _showPasswordSection = true),
                      icon: const Icon(Icons.lock_outline_rounded),
                      label: Text(
                        'Change Password',
                        style: GoogleFonts.poppins(),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.warning,
                        foregroundColor: Colors.white,
                      ),
                    )
                  else
                    Form(
                      key: _passwordFormKey,
                      child: Column(
                        children: [
                          // Current Password
                          TextFormField(
                            controller: _currentPasswordController,
                            obscureText: _obscureCurrentPassword,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Current password is required';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: 'Current Password',
                              prefixIcon: const Icon(Icons.lock_outline_rounded),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureCurrentPassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                ),
                                onPressed: () => setState(
                                  () => _obscureCurrentPassword =
                                      !_obscureCurrentPassword,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // New Password
                          TextFormField(
                            controller: _newPasswordController,
                            obscureText: _obscureNewPassword,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'New password is required';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: 'New Password',
                              prefixIcon: const Icon(Icons.lock_outline_rounded),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureNewPassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                ),
                                onPressed: () => setState(
                                  () =>
                                      _obscureNewPassword = !_obscureNewPassword,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Confirm Password
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirmPassword,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please confirm your password';
                              }
                              if (value != _newPasswordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: 'Confirm Password',
                              prefixIcon: const Icon(Icons.lock_outline_rounded),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                ),
                                onPressed: () => setState(
                                  () => _obscureConfirmPassword =
                                      !_obscureConfirmPassword,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Password Buttons
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => setState(
                                    () => _showPasswordSection = false,
                                  ),
                                  child: Text(
                                    'Cancel',
                                    style: GoogleFonts.poppins(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Consumer<ProfileProvider>(
                                  builder: (context, provider, _) {
                                    return provider.isChangingPassword
                                        ? Container(
                                            height: 44,
                                            decoration: BoxDecoration(
                                              gradient: AppColors.primaryGradient,
                                              borderRadius: BorderRadius.circular(
                                                8,
                                              ),
                                            ),
                                            child: const Center(
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2,
                                              ),
                                            ),
                                          )
                                        : ElevatedButton(
                                            onPressed: _handleChangePassword,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppColors.primary,
                                              foregroundColor: Colors.white,
                                            ),
                                            child: Text(
                                              'Update',
                                              style: GoogleFonts.poppins(),
                                            ),
                                          );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
