import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/design_system.dart';
import '../../models/habit.dart';
import '../../services/services.dart';
import '../../widgets/widgets.dart';

class HabitDetailScreen extends StatefulWidget {
  final String habitId;

  const HabitDetailScreen({super.key, required this.habitId});

  @override
  State<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends State<HabitDetailScreen> {
  bool _markedCompleteThisSession = false;

  @override
  Widget build(BuildContext context) {
    final habitService = context.watch<HabitService>();
    final premiumService = context.watch<PremiumService>();
    final adService = context.watch<AdService>();
    final moodService = context.watch<MoodService>();
    
    final habit = habitService.getHabitById(widget.habitId);

    if (habit == null) {
      return const Scaffold(body: Center(child: Text('Habit not found')));
    }

    final isPremium = premiumService.isPremium;
    final isCompletedToday = habit.isCompletedToday();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () {
            // Requirement 3: Show when navigating away after marking complete
            if (_markedCompleteThisSession && !isPremium) {
              adService.showInterstitialAd();
            }
            Navigator.pop(context);
          },
        ),
        title: Text(habit.name, style: AppTypography.titleMedium),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: AppColors.textPrimary),
            onSelected: (value) {
              if (value == 'delete') {
                _showDeleteDialog(context, habitService);
              } else if (value == 'edit') {
                // TODO: Implement Edit
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'edit', child: Text('Edit Habit')),
              const PopupMenuItem(
                value: 'delete',
                child: Text('Delete Habit', style: TextStyle(color: AppColors.habitCoral)),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero Card ────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: AppRadius.cardLargeBorder,
              ),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.surface.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          habit.category,
                          style: AppTypography.labelSmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(habit.name, style: AppTypography.headlineMedium.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Consistency is the secret to mastery.',
                        style: AppTypography.bodyMedium,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            final success = await habitService.markComplete(habit.id, DateTime.now());
                            if (success) {
                              setState(() => _markedCompleteThisSession = true);
                              
                              // Requirement 3: Show after 5 completions
                              if (habitService.shouldShowAd && !isPremium) {
                                adService.showInterstitialAd();
                                habitService.resetAdCounter();
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isCompletedToday ? AppColors.success : AppColors.primary,
                          ),
                          child: Text(isCompletedToday ? 'Completed for Today' : 'Mark for Today'),
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.local_fire_department_rounded, color: AppColors.primary, size: 24),
                            const SizedBox(width: 4),
                            Text(
                              '${habit.getCurrentStreak()}',
                              style: AppTypography.displayLarge.copyWith(fontSize: 32),
                            ),
                          ],
                        ),
                        Text(
                          'DAY STREAK',
                          style: AppTypography.labelSmall.copyWith(color: AppColors.textTertiary, letterSpacing: 1),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // ── History Section ──────────────────────────────────────
            HabitHistoryCalendar(
              completedDates: habit.completedDates,
              createdDate: habit.createdDate,
            ),
            const SizedBox(height: AppSpacing.xxxl),

            // ── Insights Section ─────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Insights', style: AppTypography.titleMedium.copyWith(fontSize: 18)),
                TextButton(
                  onPressed: () {},
                  child: Text('View All', style: AppTypography.labelLarge.copyWith(color: AppColors.primary)),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              child: Row(
                children: [
                  HabitInsightCard(
                    title: 'SUCCESS RATE',
                    value: '${(habit.getSuccessRate() * 100).toInt()}%',
                    subtitle: '+4% from last month',
                    icon: Icons.trending_up_rounded,
                    iconColor: AppColors.primary,
                    isLocked: !isPremium,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  HabitInsightCard(
                    title: 'BEST STREAK',
                    value: '${habit.getBestStreak()} Days',
                    subtitle: 'Achieved in August',
                    icon: Icons.emoji_events_outlined,
                    iconColor: AppColors.habitCoral,
                    isLocked: !isPremium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxxl),

            // ── Recent Activity Section ──────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Recent Activity', style: AppTypography.titleMedium.copyWith(fontSize: 18)),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.filter_list_rounded, size: 16),
                  label: const Text('Filter'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                    minimumSize: const Size(0, 32),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _buildActivityLog(habit, moodService, isPremium),
            
      ),
      bottomNavigationBar: isPremium
          ? null
          : const SafeArea(
              top: false,
              child: AdBanner(),
            ),
    );
  }

  Widget _buildActivityLog(Habit habit, MoodService moodService, bool isPremium) {
    // Generate simulated logs for the last 5 days
    final now = DateTime.now();
    final logs = <Widget>[];
    final limit = isPremium ? 10 : 5;

    for (int i = 0; i < limit; i++) {
      final date = now.subtract(Duration(days: i));
      final dateOnly = DateTime(date.year, date.month, date.day);
      final isCompleted = habit.completedDates.any((d) => DateTime(d.year, d.month, d.day) == dateOnly);
      
      // Try to get mood for this date
      final mood = moodService.getMoodByDate(dateOnly);

      logs.add(HabitActivityTile(
        date: date,
        isCompleted: isCompleted,
        moodLabel: mood?.moodLabel,
        moodEmoji: mood?.moodEmoji,
      ));
    }

    return Column(children: logs);
  }

  void _showDeleteDialog(BuildContext context, HabitService service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Habit'),
        content: const Text('Are you sure you want to delete this habit? All progress data will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              service.deleteHabit(widget.habitId);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Back to Home
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.habitCoral)),
          ),
        ],
      ),
    );
  }
}
}
