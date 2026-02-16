import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/design_system.dart';
import '../../services/services.dart';
import '../../widgets/widgets.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  bool _isWeekly = true;

  @override
  Widget build(BuildContext context) {
    final habitService = context.watch<HabitService>();
    final moodService = context.watch<MoodService>();
    final premiumService = context.watch<PremiumService>();
    final isPremium = premiumService.isPremium;

    // Aggregate weekly data (last 7 days or 30 days)
    final daysToFetch = _isWeekly ? 7 : 30;
    final chartData = habitService.getDailyCompletionRates(daysToFetch);

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final currentWeekStart = today.subtract(const Duration(days: 6));

    final avgCompletion = habitService.getCompletionRateInRange(currentWeekStart, today);
    final totalCheckIns = habitService.getTotalGlobalCheckIns();
    final bestStreak = habitService.getGlobalBestStreak();
    final avgMood = moodService.overallAverageMood;
    final moodLabel = avgMood != null ? moodService.getMoodLabelFromScore(avgMood) : 'No mood data';
    final trend = habitService.getCompletionPointTrend();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: habitService.habits.isEmpty || totalCheckIns == 0
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xxxxl),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.xxl),
                        decoration: BoxDecoration(
                          color: AppColors.primarySurface,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.bar_chart_rounded,
                          size: 64,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Text(
                        'No statistics yet!',
                        style: AppTypography.titleLarge,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Complete some habits to see your progress insights and trends.',
                        textAlign: TextAlign.center,
                        style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.md),
                    Text('Statistics', style: AppTypography.headlineLarge),
                    const SizedBox(height: AppSpacing.xxl),

                    // ── Progress Report Section ────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: AppRadius.cardBorder,
                        boxShadow: AppShadows.cardSm,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text('Progress Report', style: AppTypography.titleMedium),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.trending_up_rounded, color: AppColors.success, size: 20),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'You completed ${(avgCompletion * 100).toInt()}% of your habits this week. Keep ascending!',
                                  style: AppTypography.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    // ── Activity Filter Section ────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'ACTIVITY',
                          style: AppTypography.labelLarge.copyWith(color: AppColors.textPrimary, letterSpacing: 1.2),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              _FilterPill(
                                label: 'Weekly',
                                isActive: _isWeekly,
                                onTap: () => setState(() => _isWeekly = true),
                              ),
                              _FilterPill(
                                label: 'Monthly',
                                isActive: !_isWeekly,
                                isLocked: !isPremium,
                                onTap: () {
                                  if (isPremium) {
                                    setState(() => _isWeekly = false);
                                  } else {
                                    _showUpgradePrompt();
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // ── Completion Rate Chart ──────────────────────────────
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: AppRadius.cardBorder,
                        boxShadow: AppShadows.cardSm,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Completion Rate', style: AppTypography.titleMedium),
                                      Text('Based on last ${daysToFetch} days', style: AppTypography.bodySmall),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      trend >= 0 ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                                      color: trend >= 0 ? AppColors.success : AppColors.habitCoral,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${trend >= 0 ? "+" : ""}${trend.toStringAsFixed(0)}%',
                                      style: AppTypography.labelLarge.copyWith(
                                        color: trend >= 0 ? AppColors.success : AppColors.habitCoral,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          CompletionRateChart(weeklyData: chartData),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxxl),

                    // ── Daily Insights Grid ────────────────────────────────
                    Text(
                      'DAILY INSIGHTS',
                      style: AppTypography.labelLarge.copyWith(color: AppColors.textPrimary, letterSpacing: 1.2),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: AppSpacing.md,
                      crossAxisSpacing: AppSpacing.md,
                      childAspectRatio: 1,
                      children: [
                        StatGridCard(
                          icon: Icons.local_fire_department_rounded,
                          value: '$bestStreak days',
                          label: 'Best Streak',
                          sublabel: 'Consistent progress',
                          badgeText: '+3',
                          badgeColor: AppColors.success,
                        ),
                        StatGridCard(
                          icon: Icons.track_changes_rounded,
                          value: '${(avgCompletion * 100).toInt()}%',
                          label: 'Completion',
                          sublabel: 'All habits combined',
                          badgeText: 'Good',
                          badgeColor: AppColors.primary,
                        ),
                        StatGridCard(
                          icon: Icons.sentiment_satisfied_rounded,
                          value: avgMood?.toStringAsFixed(1) ?? '--',
                          label: 'Avg Mood',
                          sublabel: moodLabel,
                          isBlurred: !isPremium,
                        ),
                        StatGridCard(
                          icon: Icons.check_circle_outline_rounded,
                          value: '$totalCheckIns',
                          label: 'Check-ins',
                          sublabel: 'Total tasks checked',
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    // ── History Log Button ─────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (isPremium) {
                            // TODO: Navigate to history log
                          } else {
                            _showUpgradePrompt();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: AppRadius.cardBorder),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.calendar_month_rounded, color: Colors.white),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('History Log', style: AppTypography.titleMedium.copyWith(color: Colors.white)),
                                Text('View your full journey', style: AppTypography.bodySmall.copyWith(color: Colors.white70)),
                              ],
                            ),
                            const Spacer(),
                            const Icon(Icons.chevron_right_rounded, color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // const AdBanner(), // Handled by AppShell
                    const SizedBox(height: AppSpacing.lg / 2),
                    
                    // ── Export Data Button ─────────────────────────────────
                    SliverToBoxAdapter(
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            if (isPremium) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Exporting records to PDF...')),
                              );
                            } else {
                              _showUpgradePrompt();
                            }
                          },
                          icon: Icon(
                            Icons.ios_share_rounded, 
                            size: 20, 
                            color: isPremium ? AppColors.primary : AppColors.textTertiary,
                          ),
                          label: Text(
                            'Export Data to PDF',
                            style: TextStyle(
                              color: isPremium ? AppColors.primary : AppColors.textTertiary,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
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

  void _showUpgradePrompt() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const PremiumUpgradePrompt(),
    );
  }
}

class _FilterPill extends StatelessWidget {
  final String label;
  final bool isActive;
  final bool isLocked;
  final VoidCallback onTap;

  const _FilterPill({
    required this.label,
    required this.isActive,
    required this.onTap,
    this.isLocked = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isActive ? AppShadows.cardSm : null,
        ),
        child: Row(
          children: [
            Text(
              label,
              style: AppTypography.labelLarge.copyWith(
                color: isActive ? AppColors.primary : AppColors.textTertiary,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (isLocked) ...[
              const SizedBox(width: 4),
              const Icon(Icons.lock_rounded, size: 12, color: AppColors.textTertiary),
            ],
          ],
        ),
      ),
    );
  }
}
