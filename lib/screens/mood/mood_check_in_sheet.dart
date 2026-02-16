import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/design_system.dart';
import '../../models/mood_entry.dart';
import '../../services/services.dart';
import '../../widgets/widgets.dart';
import '../../widgets/mood_option_tile.dart';

class MoodCheckInSheet extends StatefulWidget {
  const MoodCheckInSheet({super.key});

  @override
  State<MoodCheckInSheet> createState() => _MoodCheckInSheetState();
}

class _MoodCheckInSheetState extends State<MoodCheckInSheet> {
  String _selectedMood = 'happy';
  final TextEditingController _noteController = TextEditingController();

  final Map<String, Map<String, String>> _moodData = {
    'ecstatic': {
      'emoji': '🤩',
      'label': 'Ecstatic',
      'description': 'You are on cloud nine! Today is absolutely brilliant.',
    },
    'happy': {
      'emoji': '😊',
      'label': 'Happy',
      'description': "Life is good and I'm feeling positive.",
    },
    'calm': {
      'emoji': '😌',
      'label': 'Calm',
      'description': 'Feeling peaceful, steady, and at ease with the world.',
    },
    'neutral': {
      'emoji': '😐',
      'label': 'Neutral',
      'description': 'Productive and balanced. Just a regular, okay day.',
    },
    'tired': {
      'emoji': '🌙',
      'label': 'Tired',
      'description': "Energy is low. Looking forward to some rest and recharge.",
    },
    'sad': {
      'emoji': '😢',
      'label': 'Sad',
      'description': "Feeling a bit down. It's okay to not be okay sometimes.",
    },
    'stressed': {
      'emoji': '⚡',
      'label': 'Stressed',
      'description': 'Overwhelmed or pressured. Deep breaths, you got this.',
    },
    'grateful': {
      'emoji': '❤️',
      'label': 'Grateful',
      'description': 'Appreciating the small things and big wins today.',
    },
    'gloomy': {
      'emoji': '😞',
      'label': 'Gloomy',
      'description': 'Feeling a bit gray. Tomorrow is a fresh start.',
    },
  };

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final premiumService = context.watch<PremiumService>();
    final isPremium = premiumService.isPremium;
    final moodService = context.read<MoodService>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageHorizontal),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
                Text('Mood Check-in', style: AppTypography.titleMedium),
                const SizedBox(width: 48), // Spacer for balance
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'How are you today?',
              style: AppTypography.headlineLarge.copyWith(fontSize: 24),
            ),
            const SizedBox(height: 8),
            Text(
              'Take a moment to check in with yourself. How is your internal weather?',
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.xl),

            // ── Mood Grid ────────────────────────────────────────────
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: _moodData.entries.map((entry) {
                return MoodOptionTile(
                  label: entry.value['label']!,
                  emoji: entry.value['emoji']!,
                  isSelected: _selectedMood == entry.key,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedMood = entry.key);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.xl),

            // ── Mood Detail Card ─────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: AppRadius.cardBorder,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          _moodData[_selectedMood]!['emoji']!,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _moodData[_selectedMood]!['label']!,
                              style: AppTypography.titleMedium.copyWith(color: AppColors.primary),
                            ),
                            Text(
                              _moodData[_selectedMood]!['description']!,
                              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: _noteController,
                    enabled: isPremium,
                    style: AppTypography.bodySmall,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: isPremium ? 'Tap to add a quick note...' : 'Upgrade to Premium to add notes',
                      hintStyle: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: isPremium ? null : const Icon(Icons.lock_rounded, size: 16, color: AppColors.textTertiary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // ── Actions ──────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  HapticFeedback.mediumImpact();
                  final habitService = context.read<HabitService>();
                  final completedHabitIds = habitService
                      .getAllHabits()
                      .where((h) => h.isCompletedToday())
                      .map((h) => h.id)
                      .toList();

                  await moodService.addMoodEntry(
                    moodType: _selectedMood,
                    note: _noteController.text,
                    habitIdsCompleted: completedHabitIds,
                  );
                  
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Mood logged! Keep it up. 🌈'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Log Check-in'),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Skip for now',
                style: AppTypography.labelLarge.copyWith(color: AppColors.textTertiary),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}
