import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/notification_provider.dart';
import '../../models/privacy_settings_model.dart';

class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<NotificationProvider>().fetchPrivacySettings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(
          'Privacy & Security',
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
      body: Consumer<NotificationProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.privacySettings == null) {
            return Center(
              child: Text(
                'Failed to load privacy settings',
                style: GoogleFonts.poppins(),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Privacy Section
                _SettingSection(
                  title: 'Profile Privacy',
                  description: 'Control who can see your profile and activity',
                  children: [
                    _PrivacyToggleTile(
                      icon: Icons.visibility_outlined,
                      title: 'Show Profile Publicly',
                      subtitle: 'Let others see your profile',
                      value:
                          provider.privacySettings?.showProfilePublicly ?? true,
                      onChanged: (value) {
                        final updated = provider.privacySettings!.copyWith(
                          showProfilePublicly: value,
                        );
                        provider.updatePrivacySettings(updated);
                      },
                    ),
                    _PrivacyToggleTile(
                      icon: Icons.show_chart_outlined,
                      title: 'Show on Leaderboard',
                      subtitle: 'Your activity visible in rankings',
                      value:
                          provider.privacySettings?.showActivityOnLeaderboard ??
                          true,
                      onChanged: (value) {
                        final updated = provider.privacySettings!.copyWith(
                          showActivityOnLeaderboard: value,
                        );
                        provider.updatePrivacySettings(updated);
                      },
                    ),
                  ],
                ).animate().fadeIn(delay: 100.ms).slideY(begin: -0.1, end: 0),
                const SizedBox(height: 20),

                // Communication Settings Section
                _SettingSection(
                  title: 'Communication',
                  description: 'Manage how others can reach you',
                  children: [
                    _PrivacyToggleTile(
                      icon: Icons.mail_outline_rounded,
                      title: 'Messages from Anyone',
                      subtitle: 'Allow messages from all users',
                      value:
                          provider.privacySettings?.allowMessagesFromAnyone ??
                          true,
                      onChanged: (value) {
                        final updated = provider.privacySettings!.copyWith(
                          allowMessagesFromAnyone: value,
                        );
                        provider.updatePrivacySettings(updated);
                      },
                    ),
                    _PrivacyToggleTile(
                      icon: Icons.group_add_outlined,
                      title: 'Group Invites',
                      subtitle: 'Receive invitations to join groups',
                      value:
                          provider.privacySettings?.enableGroupInvites ?? true,
                      onChanged: (value) {
                        final updated = provider.privacySettings!.copyWith(
                          enableGroupInvites: value,
                        );
                        provider.updatePrivacySettings(updated);
                      },
                    ),
                  ],
                ).animate().fadeIn(delay: 150.ms).slideY(begin: -0.1, end: 0),
                const SizedBox(height: 20),

                // Notifications Settings Section
                _SettingSection(
                  title: 'Notifications',
                  description: 'Control how you receive notifications',
                  children: [
                    _PrivacyToggleTile(
                      icon: Icons.notifications_outlined,
                      title: 'Enable Notifications',
                      subtitle: 'Receive all notifications',
                      value:
                          provider.privacySettings?.enableNotifications ?? true,
                      onChanged: (value) {
                        final updated = provider.privacySettings!.copyWith(
                          enableNotifications: value,
                        );
                        provider.updatePrivacySettings(updated);
                      },
                    ),
                    _PrivacyToggleTile(
                      icon: Icons.email_outlined,
                      title: 'Email Notifications',
                      subtitle: 'Receive email notification updates',
                      value:
                          provider.privacySettings?.enableEmailNotifications ??
                          true,
                      onChanged: (value) {
                        final updated = provider.privacySettings!.copyWith(
                          enableEmailNotifications: value,
                        );
                        provider.updatePrivacySettings(updated);
                      },
                    ),
                    _PrivacyToggleTile(
                      icon: Icons.notifications_active_outlined,
                      title: 'Push Notifications',
                      subtitle: 'Receive push notifications on your device',
                      value:
                          provider.privacySettings?.enablePushNotifications ??
                          true,
                      onChanged: (value) {
                        final updated = provider.privacySettings!.copyWith(
                          enablePushNotifications: value,
                        );
                        provider.updatePrivacySettings(updated);
                      },
                    ),
                    _PrivacyToggleTile(
                      icon: Icons.emoji_events_outlined,
                      title: 'Achievement Notifications',
                      subtitle: 'Notify when you earn achievements',
                      value:
                          provider
                              .privacySettings
                              ?.enableAchievementNotifications ??
                          true,
                      onChanged: (value) {
                        final updated = provider.privacySettings!.copyWith(
                          enableAchievementNotifications: value,
                        );
                        provider.updatePrivacySettings(updated);
                      },
                    ),
                    _PrivacyToggleTile(
                      icon: Icons.flash_on_outlined,
                      title: 'Challenge Notifications',
                      subtitle: 'Notify about new challenges',
                      value:
                          provider
                              .privacySettings
                              ?.enableChallengeNotifications ??
                          true,
                      onChanged: (value) {
                        final updated = provider.privacySettings!.copyWith(
                          enableChallengeNotifications: value,
                        );
                        provider.updatePrivacySettings(updated);
                      },
                    ),
                  ],
                ).animate().fadeIn(delay: 200.ms).slideY(begin: -0.1, end: 0),
                const SizedBox(height: 20),

                // Data & Privacy Section
                _SettingSection(
                  title: 'Data & Privacy',
                  description: 'Control data collection and usage',
                  children: [
                    _PrivacyToggleTile(
                      icon: Icons.storage_outlined,
                      title: 'Data Collection',
                      subtitle:
                          'Allow us to collect usage data for improvements',
                      value:
                          provider.privacySettings?.allowDataCollection ??
                          false,
                      onChanged: (value) {
                        final updated = provider.privacySettings!.copyWith(
                          allowDataCollection: value,
                        );
                        provider.updatePrivacySettings(updated);
                      },
                    ),
                  ],
                ).animate().fadeIn(delay: 250.ms).slideY(begin: -0.1, end: 0),
                const SizedBox(height: 24),

                // Info message
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    border: Border.all(
                      color: AppColors.success.withValues(alpha: 0.3),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outlined,
                        color: AppColors.success,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Changes are saved automatically',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: AppColors.success,
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 300.ms),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SettingSection extends StatelessWidget {
  final String title;
  final String description;
  final List<Widget> children;

  const _SettingSection({
    required this.title,
    required this.description,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.textSecondary.withValues(alpha: 0.1),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: List.generate(
              children.length,
              (index) => Column(
                children: [
                  children[index],
                  if (index < children.length - 1)
                    Divider(
                      height: 1,
                      color: AppColors.textSecondary.withValues(alpha: 0.1),
                      indent: 60,
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PrivacyToggleTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _PrivacyToggleTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
            inactiveThumbColor: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
        ],
      ),
    );
  }
}
