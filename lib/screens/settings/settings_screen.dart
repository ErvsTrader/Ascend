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
  final TextEditingController _nameController = TextEditingController();
  bool _notificationsOn = true;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 8, minute: 0);
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text = prefs.getString('user_name') ?? 'Alex';
      _notificationsOn = prefs.getBool('notifications_enabled') ?? true;
      final hour = prefs.getInt('reminder_hour') ?? 8;
      final minute = prefs.getInt('reminder_minute') ?? 0;
      _reminderTime = TimeOfDay(hour: hour, minute: minute);
      _isDarkMode = prefs.getBool('dark_mode_enabled') ?? false;
    });
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is String) await prefs.setString(key, value);
    if (value is bool) await prefs.setBool(key, value);
    if (value is int) await prefs.setInt(key, value);
  }

  @override
  Widget build(BuildContext context) {
    final premiumService = context.watch<PremiumService>();
    final isPremium = premiumService.isPremium;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.md),
              Text('Settings', style: AppTypography.headlineLarge),
              const SizedBox(height: AppSpacing.xl),

              // ── Profile Section ────────────────────────────────────
              _buildSectionHeader('PROFILE'),
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppRadius.cardBorder,
                  boxShadow: AppShadows.cardSm,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
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
                            style: AppTypography.titleMedium,
                            decoration: const InputDecoration(
                              hintText: 'Enter your name',
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 4),
                            ),
                            onChanged: (val) => _saveSetting('user_name', val),
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
                  color: AppColors.surface,
                  borderRadius: AppRadius.cardBorder,
                  boxShadow: AppShadows.cardSm,
                ),
                child: Column(
                  children: [
                    _buildPreferenceTile(
                      icon: Icons.notifications_active_outlined,
                      title: 'Notifications',
                      trailing: Switch.adaptive(
                        value: _notificationsOn,
                        activeColor: AppColors.primary,
                        onChanged: (val) async {
                          if (val) {
                            // Show explanation dialog first if it's the first time
                            final granted = await _requestNotificationPermission();
                            if (!granted) return;
                          }

                          setState(() => _notificationsOn = val);
                          await _saveSetting('notifications_enabled', val);

                          if (mounted) {
                            final habitService = context.read<HabitService>();
                            final notificationService = context.read<NotificationService>();
                            
                            if (val) {
                              // Reschedule all
                              final habits = habitService.getAllHabits();
                              for (final habit in habits) {
                                await notificationService.scheduleHabitReminder(habit);
                              }
                            } else {
                              // Cancel all
                              await notificationService.cancelAll();
                            }
                          }
                        },
                      ),
                    ),
                    const Divider(height: 1, indent: 56),
                    _buildPreferenceTile(
                      icon: Icons.access_time_rounded,
                      title: 'Daily Reminder',
                      subtitle: _formatTimeOfDay(_reminderTime),
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: _reminderTime,
                        );
                        if (time != null) {
                          setState(() => _reminderTime = time);
                          await _saveSetting('reminder_hour', time.hour);
                          await _saveSetting('reminder_minute', time.minute);
                          // This is the "default" time for new habits, no need to reschedule existing ones
                          // unless the user expects a global change. The requirement says:
                          // "Time picker to set default reminder time for new habits"
                        }
                      },
                    ),
                    const Divider(height: 1, indent: 56),
                    _buildPreferenceTile(
                      icon: Icons.dark_mode_outlined,
                      title: 'Dark Mode',
                      trailing: Switch.adaptive(
                        value: _isDarkMode,
                        activeColor: AppColors.primary,
                        onChanged: (val) {
                          setState(() => _isDarkMode = val);
                          _saveSetting('dark_mode_enabled', val);
                          // Future: Trigger theme change
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
                  color: AppColors.surface,
                  borderRadius: AppRadius.cardBorder,
                  boxShadow: AppShadows.cardSm,
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
                      onTap: () {},
                    ),
                    const Divider(height: 1, indent: 56),
                    _buildPreferenceTile(
                      icon: Icons.description_outlined,
                      title: 'Terms of Service',
                      onTap: () {},
                    ),
                    const Divider(height: 1, indent: 56),
                    _buildPreferenceTile(
                      icon: Icons.star_outline_rounded,
                      title: 'Rate Us',
                      onTap: () {},
                    ),
                    const Divider(height: 1, indent: 56),
                    _buildPreferenceTile(
                      icon: Icons.support_agent_rounded,
                      title: 'Contact Support',
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),

              // ── Sign Out ───────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () {},
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
      title: Text(title, style: AppTypography.titleSmall),
      subtitle: subtitle != null ? Text(subtitle, style: AppTypography.bodySmall) : null,
      trailing: trailing ?? (onTap != null ? const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary) : null),
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 4),
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
