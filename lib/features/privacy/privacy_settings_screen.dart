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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().fetchPrivacySettings();
    });
  }

  Future<void> _updateSetting(
    NotificationProvider provider,
    PrivacySettingsModel? current,
    PrivacySettingsModel updated,
  ) async {
    if (current == null) return;

    final success = await provider.updatePrivacySettings(updated);

    if (!success && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to update setting')));
    }
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

          if (provider.errorMessage != null) {
            return Center(
              child: Text(
                provider.errorMessage!,
                style: GoogleFonts.poppins(color: Colors.red),
              ),
            );
          }

          final settings = provider.privacySettings;

          if (settings == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Profile Privacy
                _SettingSection(
                  title: 'Profile Privacy',
                  description: 'Control who can see your profile and activity',
                  children: [
                    _PrivacyToggleTile(
                      icon: Icons.visibility_outlined,
                      title: 'Show Profile Publicly',
                      subtitle: 'Let others see your profile',
                      value: settings.showProfilePublicly,
                      onChanged: (value) {
                        final updated = settings.copyWith(
                          showProfilePublicly: value,
                        );
                        _updateSetting(provider, settings, updated);
                      },
                    ),
                    _PrivacyToggleTile(
                      icon: Icons.show_chart_outlined,
                      title: 'Show on Leaderboard',
                      subtitle: 'Your activity visible in rankings',
                      value: settings.showActivityOnLeaderboard,
                      onChanged: (value) {
                        final updated = settings.copyWith(
                          showActivityOnLeaderboard: value,
                        );
                        _updateSetting(provider, settings, updated);
                      },
                    ),
                  ],
                ).animate().fadeIn(delay: 100.ms),

                const SizedBox(height: 20),

                /// Communication
                _SettingSection(
                  title: 'Communication',
                  description: 'Manage how others can reach you',
                  children: [
                    _PrivacyToggleTile(
                      icon: Icons.mail_outline_rounded,
                      title: 'Messages from Anyone',
                      subtitle: 'Allow messages from all users',
                      value: settings.allowMessagesFromAnyone,
                      onChanged: (value) {
                        final updated = settings.copyWith(
                          allowMessagesFromAnyone: value,
                        );
                        _updateSetting(provider, settings, updated);
                      },
                    ),
                    _PrivacyToggleTile(
                      icon: Icons.group_add_outlined,
                      title: 'Group Invites',
                      subtitle: 'Receive invitations to join groups',
                      value: settings.enableGroupInvites,
                      onChanged: (value) {
                        final updated = settings.copyWith(
                          enableGroupInvites: value,
                        );
                        _updateSetting(provider, settings, updated);
                      },
                    ),
                  ],
                ).animate().fadeIn(delay: 150.ms),

                const SizedBox(height: 20),

                /// Notifications
                _SettingSection(
                  title: 'Notifications',
                  description: 'Control how you receive notifications',
                  children: [
                    _PrivacyToggleTile(
                      icon: Icons.notifications_outlined,
                      title: 'Enable Notifications',
                      subtitle: 'Receive all notifications',
                      value: settings.enableNotifications,
                      onChanged: (value) {
                        final updated = settings.copyWith(
                          enableNotifications: value,
                        );
                        _updateSetting(provider, settings, updated);
                      },
                    ),
                    _PrivacyToggleTile(
                      icon: Icons.email_outlined,
                      title: 'Email Notifications',
                      subtitle: 'Receive email notification updates',
                      value: settings.enableEmailNotifications,
                      onChanged: (value) {
                        final updated = settings.copyWith(
                          enableEmailNotifications: value,
                        );
                        _updateSetting(provider, settings, updated);
                      },
                    ),
                    _PrivacyToggleTile(
                      icon: Icons.notifications_active_outlined,
                      title: 'Push Notifications',
                      subtitle: 'Receive push notifications on your device',
                      value: settings.enablePushNotifications,
                      onChanged: (value) {
                        final updated = settings.copyWith(
                          enablePushNotifications: value,
                        );
                        _updateSetting(provider, settings, updated);
                      },
                    ),
                    _PrivacyToggleTile(
                      icon: Icons.emoji_events_outlined,
                      title: 'Achievement Notifications',
                      subtitle: 'Notify when you earn achievements',
                      value: settings.enableAchievementNotifications,
                      onChanged: (value) {
                        final updated = settings.copyWith(
                          enableAchievementNotifications: value,
                        );
                        _updateSetting(provider, settings, updated);
                      },
                    ),
                    _PrivacyToggleTile(
                      icon: Icons.flash_on_outlined,
                      title: 'Challenge Notifications',
                      subtitle: 'Notify about new challenges',
                      value: settings.enableChallengeNotifications,
                      onChanged: (value) {
                        final updated = settings.copyWith(
                          enableChallengeNotifications: value,
                        );
                        _updateSetting(provider, settings, updated);
                      },
                    ),
                  ],
                ).animate().fadeIn(delay: 200.ms),

                const SizedBox(height: 20),

                /// Data & Privacy
                _SettingSection(
                  title: 'Data & Privacy',
                  description: 'Control data collection and usage',
                  children: [
                    _PrivacyToggleTile(
                      icon: Icons.storage_outlined,
                      title: 'Data Collection',
                      subtitle:
                          'Allow us to collect usage data for improvements',
                      value: settings.allowDataCollection,
                      onChanged: (value) {
                        final updated = settings.copyWith(
                          allowDataCollection: value,
                        );
                        _updateSetting(provider, settings, updated);
                      },
                    ),
                  ],
                ).animate().fadeIn(delay: 250.ms),

                const SizedBox(height: 24),

                /// Info
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
                      Icon(Icons.info_outlined, color: AppColors.success),
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
              ],
            ),
          );
        },
      ),
    );
  }
}

/// SECTION WIDGET
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
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(description, style: GoogleFonts.poppins(fontSize: 12)),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: List.generate(
              children.length,
              (index) => Column(
                children: [
                  children[index],
                  if (index < children.length - 1) const Divider(height: 1),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// TOGGLE TILE
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
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: GoogleFonts.poppins()),
      subtitle: Text(subtitle, style: GoogleFonts.poppins(fontSize: 12)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppColors.primary,
      ),
    );
  }
}
