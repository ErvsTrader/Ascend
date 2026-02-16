import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/design_system.dart';
import '../../services/services.dart';
import '../app_shell.dart';

class NameCollectionScreen extends StatefulWidget {
  const NameCollectionScreen({super.key});

  @override
  State<NameCollectionScreen> createState() => _NameCollectionScreenState();
}

class _NameCollectionScreenState extends State<NameCollectionScreen> {
  final TextEditingController _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    if (_formKey.currentState!.validate()) {
      final String name = _nameController.text.trim();
      final prefs = await SharedPreferences.getInstance();
      
      // Save data
      await prefs.setString('user_name', name);
      await prefs.setBool('onboardingComplete', true);

      if (mounted) {
        // Show permission explanation
        await _showPermissionExplanation(context, prefs);
        
        if (mounted) {
          // Navigate to Home
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const AppShell()),
            (route) => false,
          );
        }
      }
    }
  }

  Future<void> _showPermissionExplanation(BuildContext context, SharedPreferences prefs) async {
    final notificationService = context.read<NotificationService>();
    
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.cardBorder),
        title: const Text('One Last Thing! 🔔'),
        content: const Text(
          'Ascend works best when we can nudge you at the right time. '
          'Enable notifications to help stay consistent with your habits.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Not Now', style: TextStyle(color: AppColors.textTertiary)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await notificationService.requestPermissions();
              await prefs.setBool('notification_permission_requested', true);
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(100, 44),
            ),
            child: const Text('Enable'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'What should we call you?',
                  style: AppTypography.headlineLarge,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Your name helps us personalise your experience.',
                  style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppSpacing.xxxxl),
                TextFormField(
                  controller: _nameController,
                  autofocus: true,
                  style: AppTypography.titleLarge,
                  decoration: const InputDecoration(
                    hintText: 'Enter your name...',
                    contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) => _completeOnboarding(),
                ),
                const SizedBox(height: AppSpacing.xxxxl),
                ElevatedButton(
                  onPressed: _completeOnboarding,
                  child: const Text('Continue'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
