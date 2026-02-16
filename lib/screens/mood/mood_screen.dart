import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/design_system.dart';
import '../../services/services.dart';
import '../../widgets/widgets.dart';
import 'mood_check_in_sheet.dart';

class MoodScreen extends StatelessWidget {
  const MoodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final moodService = context.watch<MoodService>();
    final entries = moodService.getAllEntries();
    final avgMood = moodService.overallAverageMood;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.md),
              Text('Mood History', style: AppTypography.headlineLarge),
              const SizedBox(height: AppSpacing.xl),

              // ── Summary Card ──────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, Color(0xFF818CF8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: AppRadius.cardLargeBorder,
                  boxShadow: AppShadows.cardMd,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'How\'s your mood?',
                            style: AppTypography.headlineMedium.copyWith(color: Colors.white),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            avgMood != null 
                              ? 'Your average mood is ${avgMood.toStringAsFixed(1)}. You\'re doing great!'
                              : 'You haven\'t checked in recently. Start your journey today.',
                            style: AppTypography.bodyMedium.copyWith(color: Colors.white.withOpacity(0.9)),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          ElevatedButton(
                            onPressed: () => _showMoodCheckIn(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.primary,
                              elevation: 0,
                            ),
                            child: const Text('Check In Now'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    const Icon(Icons.sentiment_satisfied_alt_rounded, size: 64, color: Colors.white24),
                  ],
                ),
              ),
              
              const SizedBox(height: AppSpacing.xxl),

              _buildCorrelationSection(context),

              const SizedBox(height: AppSpacing.xxl),

              Text(
                'RECENT ENTRIES',
                style: AppTypography.labelLarge.copyWith(color: AppColors.textPrimary, letterSpacing: 1.2),
              ),
              const SizedBox(height: AppSpacing.lg),

              if (entries.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 48),
                    child: Column(
                      children: [
                        const Icon(Icons.auto_awesome_rounded, size: 48, color: AppColors.border),
                        const SizedBox(height: 16),
                        Text(
                          'No mood entries yet.\nCheck in once a day!',
                          textAlign: TextAlign.center,
                          style: AppTypography.bodySmall,
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: entries.length,
                  separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    return Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: AppRadius.cardBorder,
                        boxShadow: AppShadows.cardSm,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.primarySurface,
                              shape: BoxShape.circle,
                            ),
                            child: Text(entry.moodEmoji, style: const TextStyle(fontSize: 24)),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      DateFormat('EEEE, MMM d').format(entry.date),
                                      style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      entry.moodLabel,
                                      style: AppTypography.labelSmall.copyWith(color: AppColors.primary),
                                    ),
                                  ],
                                ),
                                if (entry.note.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    entry.note,
                                    style: AppTypography.bodySmall,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCorrelationSection(BuildContext context) {
    final moodService = context.watch<MoodService>();
    final habitService = context.watch<HabitService>();
    final isPremium = context.watch<PremiumService>().isPremium;
    final correlations = moodService.getMoodHabitCorrelation();

    if (correlations.isEmpty) return const SizedBox.shrink();

    // Sort habits by mood score descending
    final sortedHabitIds = correlations.keys.toList()
      ..sort((a, b) => correlations[b]!.compareTo(correlations[a]!));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'MOOD CORRELATION',
              style: AppTypography.labelLarge.copyWith(color: AppColors.textPrimary, letterSpacing: 1.2),
            ),
            if (!isPremium)
              const Icon(Icons.lock_rounded, size: 16, color: AppColors.textTertiary),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Stack(
          children: [
            Column(
              children: sortedHabitIds.take(3).map((id) {
                final habit = habitService.getHabitById(id);
                if (habit == null) return const SizedBox.shrink();
                final score = correlations[id]!;

                return Container(
                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppRadius.cardBorder,
                    boxShadow: AppShadows.cardSm,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Color(habit.colorValue),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(habit.name, style: AppTypography.titleSmall),
                      ),
                      Text(
                        score.toStringAsFixed(1),
                        style: AppTypography.titleSmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.star_rounded, size: 16, color: AppColors.primary),
                    ],
                  ),
                );
              }).toList(),
            ),
            if (!isPremium)
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: AppRadius.cardBorder,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                    child: Container(
                      color: Colors.white.withOpacity(0.6),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.lock_rounded, color: AppColors.primary, size: 32),
                            const SizedBox(height: 8),
                            Text(
                              'Upgrade to Premium\nto see mood correlations',
                              textAlign: TextAlign.center,
                              style: AppTypography.labelLarge.copyWith(color: AppColors.primary),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  void _showMoodCheckIn(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const MoodCheckInSheet(),
    );
  }
}
