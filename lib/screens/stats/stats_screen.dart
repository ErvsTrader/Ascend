import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
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
  void initState() {
    super.initState();
    // Use addPostFrameCallback to ensure context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData({bool forceRefresh = false}) async {
    await context.read<StatsService>().loadStats(forceRefresh: forceRefresh);
  }

  @override
  Widget build(BuildContext context) {
    final statsService = context.watch<StatsService>();
    final premiumService = context.watch<PremiumService>();
    final isPremium = premiumService.isPremium;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _loadData(forceRefresh: true),
          displacement: 20,
          color: AppColors.primary,
          child: statsService.isLoading
              ? _buildSkeleton()
              : SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.pageHorizontal,
                    vertical: AppSpacing.lg,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Statistics',
                        style: AppTypography.headlineMedium.copyWith(fontSize: 24),
                      ),
                      const SizedBox(height: AppSpacing.xxl),

                      // ── Progress Report Section ────────────────────────────
                      _buildProgressReport(statsService),
                      const SizedBox(height: AppSpacing.xxl),

                      // ── Activity Section ──────────────────────────────────
                      _buildActivityHeader(isPremium),
                      const SizedBox(height: AppSpacing.lg),

                      // ── Completion Rate Chart ──────────────────────────────
                      _buildChartSection(statsService),
                      const SizedBox(height: AppSpacing.xxxl),

                      // ── Daily Insights ────────────────────────────────────
                      _buildInsightsGrid(statsService, isPremium),
                      const SizedBox(height: AppSpacing.xxl),

                      // ── History Log Button ─────────────────────────────────
                      _buildHistoryLogButton(isPremium),
                      const SizedBox(height: AppSpacing.xxxl),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildProgressReport(StatsService stats) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.cardBorder,
        boxShadow: AppShadows.cardSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Progress Report', style: AppTypography.headlineSmall),
              const Icon(Icons.trending_up, color: AppColors.primary, size: 24),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            stats.progressReportText,
            style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityHeader(bool isPremium) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'ACTIVITY',
          style: AppTypography.labelLarge.copyWith(color: AppColors.textTertiary, fontSize: 12),
        ),
        Container(
          height: 36,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              _buildToggleChip(
                label: 'Weekly',
                isSelected: _isWeekly,
                onTap: () => setState(() => _isWeekly = true),
              ),
              _buildToggleChip(
                label: 'Monthly',
                isSelected: !_isWeekly,
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
    );
  }

  Widget _buildToggleChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    bool isLocked = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Center(
          child: Row(
            children: [
              Text(
                label,
                style: AppTypography.labelLarge.copyWith(
                  color: isSelected ? Colors.white : AppColors.textTertiary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              if (isLocked) ...[
                const SizedBox(width: 4),
                const Icon(Icons.lock, size: 12, color: AppColors.textTertiary),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChartSection(StatsService stats) {
    final trend = stats.completionTrend;
    final isPositive = trend.startsWith('+');

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.cardBorder,
        boxShadow: AppShadows.cardSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Completion Rate', style: AppTypography.headlineSmall),
                  Text('Based on last 7 days', style: AppTypography.bodySmall.copyWith(fontSize: 14)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (isPositive ? AppColors.success : AppColors.error).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  trend,
                  style: AppTypography.labelLarge.copyWith(
                    color: isPositive ? AppColors.success : AppColors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          CompletionRateChart(
            weeklyData: stats.weeklyCompletionData.values.map((v) => v / 100).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsGrid(StatsService stats, bool isPremium) {
    final bestStreak = stats.bestStreakData;
    final overall = stats.overallCompletionData;
    final avgMood = stats.avgMoodData;
    final totalCheckIns = stats.totalCheckIns;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DAILY INSIGHTS',
          style: AppTypography.labelLarge.copyWith(color: AppColors.textTertiary, fontSize: 12),
        ),
        const SizedBox(height: AppSpacing.lg),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: AppSpacing.md,
          crossAxisSpacing: AppSpacing.md,
          childAspectRatio: 0.9,
          children: [
            StatGridCard(
              icon: Icons.local_fire_department,
              value: '${bestStreak['streak']} days',
              label: 'Best Streak',
              sublabel: bestStreak['habitName'],
              badgeText: '+${bestStreak['improvement']}',
              badgeColor: AppColors.success,
            ),
            StatGridCard(
              icon: Icons.track_changes,
              value: '${(overall['percentage'] as double).toInt()}%',
              label: 'Completion',
              sublabel: 'All habits combined',
              badgeText: overall['badge'],
              badgeColor: AppColors.primary,
            ),
            StatGridCard(
              icon: Icons.sentiment_satisfied_alt,
              value: avgMood != null ? '${avgMood['average']}' : '--',
              label: 'Avg Mood',
              sublabel: avgMood != null ? avgMood['description'] : 'No data',
              isBlurred: !isPremium,
            ),
            StatGridCard(
              icon: Icons.check_circle_outline,
              value: '$totalCheckIns',
              label: 'Check-ins',
              sublabel: 'Total tasks checked',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHistoryLogButton(bool isPremium) {
    return GestureDetector(
      onTap: () {
        if (isPremium) {
          // Navigate to history
        } else {
          _showUpgradePrompt();
        }
      },
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.bannerStart, AppColors.bannerEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: AppRadius.cardBorder,
          boxShadow: AppShadows.cardMd,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.calendar_month, color: Colors.white, size: 28),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'History Log',
                    style: AppTypography.titleLarge.copyWith(color: Colors.white, fontSize: 16),
                  ),
                  Text(
                    'View your full journey',
                    style: AppTypography.bodySmall.copyWith(color: Colors.white.withOpacity(0.8), fontSize: 14),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeleton() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.md),
            Container(width: 120, height: 28, color: Colors.white),
            const SizedBox(height: AppSpacing.xxl),
            Container(width: double.infinity, height: 100, decoration: BoxDecoration(color: Colors.white, borderRadius: AppRadius.cardBorder)),
            const SizedBox(height: AppSpacing.xxl),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(width: 80, height: 16, color: Colors.white),
                Container(width: 140, height: 36, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18))),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Container(width: double.infinity, height: 240, decoration: BoxDecoration(color: Colors.white, borderRadius: AppRadius.cardBorder)),
            const SizedBox(height: AppSpacing.xxxl),
            Container(width: 100, height: 16, color: Colors.white),
            const SizedBox(height: AppSpacing.lg),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              mainAxisSpacing: AppSpacing.md,
              crossAxisSpacing: AppSpacing.md,
              children: List.generate(4, (_) => Container(decoration: BoxDecoration(color: Colors.white, borderRadius: AppRadius.cardBorder))),
            ),
          ],
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
