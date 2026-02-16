import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/design_system.dart';
import '../../models/habit.dart';
import '../../services/habit_service.dart';
import '../../services/premium_service.dart';
import '../../widgets/daily_progress_card.dart';
import '../../widgets/habit_card.dart';
import '../../widgets/weekly_streak.dart';
import '../../widgets/ad_banner.dart';

// ---------------------------------------------------------------------------
// HomeScreen – matches Visily /UI/Home.png
// ---------------------------------------------------------------------------

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _userName = 'there';

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _setupAdListener();
  }

  void _setupAdListener() {
    // We use context.read because we just want to load the ad once
    context.read<AdService>().loadInterstitialAd();

    // Listen for completion count changes in HabitService
    final habitService = context.read<HabitService>();
    habitService.addListener(_handleHabitCompletion);
  }

  void _handleHabitCompletion() {
    final habitService = context.read<HabitService>();
    final adService = context.read<AdService>();

    if (habitService.shouldShowAd) {
      adService.showInterstitialAd();
      habitService.resetAdCounter();
    }
  }

  @override
  void dispose() {
    context.read<HabitService>().removeListener(_handleHabitCompletion);
    super.dispose();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('user_name') ?? 'there';
    if (mounted) setState(() => _userName = name);
  }

  @override
  Widget build(BuildContext context) {
    final habitService = context.watch<HabitService>();
    final habits = habitService.getAllHabits();
    final completedCount = habitService.completedTodayCount;
    final totalCount = habitService.totalCount;

    // Collect completed dates this week for the streak widget.
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final completedThisWeek = <DateTime>{};
    for (final habit in habits) {
      for (final d in habit.completedDates) {
        final dateOnly = DateTime(d.year, d.month, d.day);
        if (!dateOnly.isBefore(DateTime(monday.year, monday.month, monday.day))) {
          completedThisWeek.add(dateOnly);
        }
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── App logo header ──────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageHorizontal,
                  AppSpacing.pageTop,
                  AppSpacing.pageHorizontal,
                  AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.bolt_rounded,
                        color: AppColors.textOnPrimary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Ascend',
                      style: AppTypography.headlineSmall.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Divider accent ───────────────────────────────────────
            SliverToBoxAdapter(
              child: Container(
                height: 3,
                margin: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pageHorizontal,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryLight],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // ── Greeting ─────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageHorizontal,
                  AppSpacing.xxl,
                  AppSpacing.pageHorizontal,
                  AppSpacing.xs,
                ),
                child: Text(
                  'Hello, $_userName! 👋',
                  style: AppTypography.headlineLarge,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pageHorizontal,
                ),
                child: Text(
                  'Consistency is the key to excellence.',
                  style: AppTypography.bodyLarge,
                ),
              ),
            ),

            // ── Daily Progress card ──────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageHorizontal,
                  AppSpacing.xxl,
                  AppSpacing.pageHorizontal,
                  0,
                ),
                child: DailyProgressCard(
                  completedCount: completedCount,
                  totalCount: totalCount,
                ),
              ),
            ),

            // ── Active Habits header ─────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageHorizontal,
                  AppSpacing.xxxl,
                  AppSpacing.pageHorizontal,
                  AppSpacing.lg,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ACTIVE HABITS',
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.textPrimary,
                        letterSpacing: 1.2,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        // TODO: navigate to edit habit list
                      },
                      child: Text('Edit List', style: AppTypography.buttonMedium),
                    ),
                  ],
                ),
              ),
            ),

            // ── Habit list ───────────────────────────────────────────
            if (habits.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.pageHorizontal,
                    vertical: AppSpacing.xxxl,
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.add_circle_outline_rounded,
                          size: 48,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'No habits yet.\nTap + to create your first habit.',
                          textAlign: TextAlign.center,
                          style: AppTypography.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pageHorizontal,
                ),
                sliver: SliverList.builder(
                  itemCount: habits.length,
                  itemBuilder: (context, index) {
                    final habit = habits[index];
                    return HabitCard(
                      habit: habit,
                      onToggle: () {
                        habitService.markComplete(habit.id, DateTime.now());
                      },
                      onTap: () {
                        // TODO: navigate to habit detail
                      },
                    );
                  },
                ),
              ),

            // ── Weekly Streak ────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageHorizontal,
                  AppSpacing.lg,
                  AppSpacing.pageHorizontal,
                  AppSpacing.lg,
                ),
                child: WeeklyStreak(completedDates: completedThisWeek),
              ),
            ),

            // ── Bottom spacer for FAB clearance ──────────────────────
            const SliverToBoxAdapter(
              child: SizedBox(height: 80),
            ),
          ],
        ),
      ),
    );
  }
}
