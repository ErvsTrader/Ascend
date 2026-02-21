import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../../core/design_system.dart';
import '../../services/services.dart';
import '../../widgets/widgets.dart';
import '../../widgets/premium_upgrade_card.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    final settings = context.read<SettingsService>();
    _nameController = TextEditingController(text: settings.userName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settingsService = context.watch<SettingsService>();
    final premiumService = context.watch<PremiumService>();
    final isPremium = premiumService.isPremium;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.md),
              Text('Settings', style: AppTypography.headlineLarge.copyWith(
                color: Theme.of(context).textTheme.headlineLarge?.color,
              )),
              const SizedBox(height: AppSpacing.xl),

              // ── Profile Section ────────────────────────────────────
              _buildSectionHeader('PROFILE'),
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  borderRadius: AppRadius.cardBorder,
                  boxShadow: settingsService.isDarkMode ? null : AppShadows.cardSm,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface.withOpacity(settingsService.isDarkMode ? 0.1 : 1.0),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 2),
                      ),
                      child: const Icon(Icons.person_rounded, color: AppColors.primary, size: 32),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Display Name', style: AppTypography.labelSmall.copyWith(color: AppColors.textTertiary)),
                          TextField(
                            controller: _nameController,
                            style: AppTypography.titleMedium.copyWith(
                              color: Theme.of(context).textTheme.titleMedium?.color,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Enter your name',
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              isDense: true,
                              fillColor: Colors.transparent,
                              contentPadding: EdgeInsets.symmetric(vertical: 4),
                            ),
                            onChanged: (val) => settingsService.setUserName(val),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),

              // ── Preferences Section ────────────────────────────────
              _buildSectionHeader('PREFERENCES'),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  borderRadius: AppRadius.cardBorder,
                  boxShadow: settingsService.isDarkMode ? null : AppShadows.cardSm,
                ),
                child: Column(
                  children: [
                    _buildPreferenceTile(
                      icon: Icons.notifications_active_outlined,
                      title: 'Notifications',
                      trailing: Switch.adaptive(
                        value: settingsService.notificationsEnabled,
                        activeColor: AppColors.primary,
                        onChanged: (val) async {
                          if (val) {
                            final granted = await _requestNotificationPermission();
                            if (!granted) return;
                          }

                          await settingsService.setNotificationsEnabled(val);

                          if (mounted) {
                            final habitService = context.read<HabitService>();
                            final notificationService = context.read<NotificationService>();
                            
                            if (val) {
                              final habits = habitService.getAllHabits();
                              for (final habit in habits) {
                                await notificationService.scheduleHabitReminder(
                                  habit, 
                                  sound: settingsService.notificationSound,
                                );
                              }
                            } else {
                              await notificationService.cancelAll();
                            }
                          }
                        },
                      ),
                    ),
                    const Divider(height: 1, indent: 56),
                    _buildPreferenceTile(
                      icon: Icons.music_note_rounded,
                      title: 'Notification Sound',
                      subtitle: _getSoundName(settingsService.notificationSound),
                      onTap: () => _showSoundPicker(context, settingsService),
                    ),
                    const Divider(height: 1, indent: 56),
                    _buildPreferenceTile(
                      icon: Icons.access_time_rounded,
                      title: 'Daily Reminder',
                      subtitle: _formatTimeOfDay(settingsService.defaultReminderTime),
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: settingsService.defaultReminderTime,
                        );
                        if (time != null) {
                          await settingsService.setDefaultReminderTime(time);
                        }
                      },
                    ),
                    const Divider(height: 1, indent: 56),
                    _buildPreferenceTile(
                      icon: Icons.dark_mode_outlined,
                      title: 'Dark Mode',
                      trailing: Switch.adaptive(
                        value: settingsService.isDarkMode,
                        activeColor: AppColors.primary,
                        onChanged: (val) {
                          settingsService.setDarkMode(val);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),

              // ── Premium Section ────────────────────────────────────
              _buildSectionHeader('SUBSCRIPTION'),
              PremiumUpgradeCard(
                isPremium: isPremium,
                onUpgrade: () {
                  premiumService.setPremium(true);
                  _showSuccessDialog(context);
                },
              ),
              const SizedBox(height: AppSpacing.xxl),

              // ── About Section ──────────────────────────────────────
              _buildSectionHeader('ABOUT'),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  borderRadius: AppRadius.cardBorder,
                  boxShadow: settingsService.isDarkMode ? null : AppShadows.cardSm,
                ),
                child: Column(
                  children: [
                    _buildPreferenceTile(
                      icon: Icons.info_outline_rounded,
                      title: 'App Version',
                      subtitle: '1.0.0 (Build 42)',
                    ),
                    const Divider(height: 1, indent: 56),
                    _buildPreferenceTile(
                      icon: Icons.privacy_tip_outlined,
                      title: 'Privacy Policy',
                      onTap: () => _showComingSoon(context, 'Privacy Policy'),
                    ),
                    const Divider(height: 1, indent: 56),
                    _buildPreferenceTile(
                      icon: Icons.description_outlined,
                      title: 'Terms of Service',
                      onTap: () => _showComingSoon(context, 'Terms of Service'),
                    ),
                    const Divider(height: 1, indent: 56),
                    _buildPreferenceTile(
                      icon: Icons.star_outline_rounded,
                      title: 'Rate Us',
                      onTap: () => _showComingSoon(context, 'Rate Us'),
                    ),
                    const Divider(height: 1, indent: 56),
                    _buildPreferenceTile(
                      icon: Icons.support_agent_rounded,
                      title: 'Contact Support',
                      onTap: () => _showComingSoon(context, 'Contact Support'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),

              // ── Sign Out ───────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () => _showSignOutDialog(context),
                  icon: const Icon(Icons.logout_rounded, color: AppColors.habitCoral),
                  label: Text(
                    'Sign Out',
                    style: AppTypography.buttonLarge.copyWith(color: AppColors.habitCoral),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, AppSpacing.md),
      child: Text(
        title,
        style: AppTypography.labelLarge.copyWith(color: AppColors.textTertiary, letterSpacing: 1.5),
      ),
    );
  }

  Widget _buildPreferenceTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: AppTypography.titleSmall.copyWith(
        color: Theme.of(context).textTheme.titleSmall?.color,
      )),
      subtitle: subtitle != null ? Text(subtitle, style: AppTypography.bodySmall) : null,
      trailing: trailing ?? (onTap != null ? const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary) : null),
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 4),
    );
  }

  Future<void> _showSoundPicker(BuildContext context, SettingsService settings) async {
    final sounds = {
      'default': 'System Default',
      'gentle': 'Gentle Breeze',
      'success': 'Success Sparkle',
      'custom_ring': 'Custom Ringtone',
    };

    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  const Icon(Icons.music_note_rounded, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Text('Notification Sound', style: AppTypography.titleLarge),
                ],
              ),
            ),
            const Divider(),
            ...sounds.entries.map((entry) => RadioListTile<String>(
              title: Text(entry.value),
              value: entry.key,
              groupValue: settings.notificationSound,
              activeColor: AppColors.primary,
              onChanged: (val) async {
                if (val != null) {
                  await settings.setNotificationSound(val);
                  if (mounted) {
                    // Update all scheduled notifications with new sound
                    final habitService = context.read<HabitService>();
                    final notificationService = context.read<NotificationService>();
                    if (settings.notificationsEnabled) {
                      final habits = habitService.getAllHabits();
                      for (final habit in habits) {
                        await notificationService.scheduleHabitReminder(habit, sound: val);
                      }
                    }
                    Navigator.pop(context);
                  }
                }
              },
            )),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  String _getSoundName(String key) {
    switch (key) {
      case 'gentle': return 'Gentle Breeze';
      case 'success': return 'Success Sparkle';
      case 'custom_ring': return 'Custom Ringtone';
      default: return 'System Default';
    }
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature feature coming soon!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out? Your habit data is stored locally.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Dummy sign out - just close dialog
              Navigator.pop(context);
              _showComingSoon(context, 'Sign Out');
            },
            child: const Text('Sign Out', style: TextStyle(color: AppColors.habitCoral)),
          ),
        ],
      ),
    );
  }

  Future<bool> _requestNotificationPermission() async {
    final notificationService = context.read<NotificationService>();
    
    // Show explanation dialog
    final proceed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.cardBorder),
        title: const Text('Enable Reminders'),
        content: const Text(
          'Ascend uses daily reminders to help you stay consistent with your habits. '
          'We recommend enabling them for the best experience!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Not Now', style: TextStyle(color: AppColors.textTertiary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(100, 44),
            ),
            child: const Text('Allow'),
          ),
        ],
      ),
    );

    if (proceed == true) {
      return await notificationService.requestPermissions();
    }
    return false;
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat('hh:mm a').format(dt);
  }
  void _showSuccessDialog(BuildContext context, {bool isRestore = false}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.cardBorder),
        title: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 28),
            const SizedBox(width: 12),
            Text(isRestore ? 'Purchase Restored' : 'Premium Unlocked! ✓'),
          ],
        ),
        content: Text(
          isRestore 
            ? 'Your premium access has been successfully restored. Enjoy all features!' 
            : 'Thank you for your purchase! All premium features and ad-free experience are now active.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Great!'),
          ),
        ],
      ),
    );
  }
}
