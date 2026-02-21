import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:confetti/confetti.dart';

import '../../core/design_system.dart';
import '../../models/habit.dart';
import '../../services/habit_service.dart';
import '../../services/premium_service.dart';
import '../../widgets/daily_progress_card.dart';
import '../../widgets/habit_card.dart';
import '../../widgets/weekly_streak.dart';
import '../../widgets/ad_banner.dart';
import '../../services/ad_service.dart';
import '../../services/mood_service.dart';
import '../mood/mood_check_in_sheet.dart';
import 'habit_detail_screen.dart';
import 'add_habit_screen.dart';

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
  late ConfettiController _confettiController;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
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
    _confettiController.dispose();
    context.read<HabitService>().removeListener(_handleHabitCompletion);
    super.dispose();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('user_name') ?? 'there';
    if (mounted) setState(() => _userName = name);
  }

  Future<void> _deleteHabit(BuildContext context, Habit habit) async {
    final streak = habit.getCurrentStreak();
    final bool confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: AppRadius.cardBorder),
            title: const Text('Delete Habit?'),
            content: Text(
              streak > 0
                  ? 'Your $streak-day streak will be lost. Are you sure you want to delete "${habit.name}"?'
                  : 'Are you sure you want to delete "${habit.name}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancel', style: TextStyle(color: AppColors.textTertiary)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete', style: TextStyle(color: AppColors.error)),
              ),
            ],
          ),
        ) ??
        false;

    if (confirm && mounted) {
      await context.read<HabitService>().deleteHabit(habit.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"${habit.name}" deleted'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _editHabit(Habit habit) {
    // Navigate to AddHabitScreen with habit for editing
    // For now, I'll navigate to AddHabitScreen (I'll update AddHabitScreen to handle editing next)
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddHabitScreen(habit: habit),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final habitService = context.watch<HabitService>();
    final moodService = context.watch<MoodService>();
    final habits = habitService.getAllHabits();
    final completedCount = habitService.getCompletedCountForDate(_selectedDate);
    final totalCount = habitService.totalCount;
    // Collect completed dates this week for the streak widget.
    final now = DateTime.now();
    final todayMood = moodService.getMoodByDate(now);
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
        child: Stack(
          children: [
            RefreshIndicator(
              onRefresh: () async {
                // Mock refresh
                await Future.delayed(const Duration(seconds: 1));
                if (mounted) setState(() {});
              },
              color: AppColors.primary,
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

                  if (todayMood == null)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.pageHorizontal,
                          AppSpacing.md,
                          AppSpacing.pageHorizontal,
                          0,
                        ),
                        child: _buildMoodPrompt(context),
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
                              Container(
                                padding: const EdgeInsets.all(AppSpacing.xxl),
                                decoration: BoxDecoration(
                                  color: AppColors.primarySurface,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.add_task_rounded,
                                  size: 64,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xl),
                              Text(
                                'No habits yet!',
                                style: AppTypography.titleLarge,
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                'Tap the + button to add your first habit',
                                textAlign: TextAlign.center,
                                style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                              ),
                              const SizedBox(height: AppSpacing.xxl),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => AddHabitScreen()),
                                  );
                                },
                                child: const Text('Add My First Habit'),
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
                          return Dismissible(
                            key: Key(habit.id),
                            background: _buildDismissibleBackground(
                              color: AppColors.success,
                              icon: Icons.edit_rounded,
                              label: 'Edit',
                              alignment: Alignment.centerLeft,
                            ),
                            secondaryBackground: _buildDismissibleBackground(
                              color: AppColors.error,
                              icon: Icons.delete_rounded,
                              label: 'Delete',
                              alignment: Alignment.centerRight,
                            ),
                            confirmDismiss: (direction) async {
                              if (direction == DismissDirection.startToEnd) {
                                _editHabit(habit);
                                return false; // Prevent dismiss
                              } else {
                                await _deleteHabit(context, habit);
                                return false; // Handled by helper, don't let Dismissible remove it automagically
                              }
                            },
                            child: HabitCard(
                              habit: habit,
                              targetDate: _selectedDate,
                              onToggle: () async {
                                final wasCompleted = habit.isCompletedOn(_selectedDate);
                                final completed = await habitService.markComplete(habit.id, _selectedDate);
                                
                                if (completed && !wasCompleted) {
                                  final streak = habit.getCurrentStreak();
                                  if (streak >= 7 && 
                                      DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day) == 
                                      DateTime(now.year, now.month, now.day)) {
                                    _confettiController.play();
                                  }
                                  
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Streak updated! Keep going! 🔥'),
                                        behavior: SnackBarBehavior.floating,
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                }

                                // Optional: Encourage mood check-in if not done today
                                if (completed && todayMood == null && mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text('How is your mood today?'),
                                      action: SnackBarAction(
                                        label: 'Check In',
                                        onPressed: () {
                                          showModalBottomSheet(
                                            context: context,
                                            isScrollControlled: true,
                                            backgroundColor: Colors.transparent,
                                            builder: (context) => const MoodCheckInSheet(),
                                          );
                                        },
                                      ),
                                      behavior: SnackBarBehavior.floating,
                                      duration: const Duration(seconds: 3),
                                    ),
                                  );
                                }
                              },
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => HabitDetailScreen(habitId: habit.id),
                                  ),
                                );
                              },
                            ),
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
                      child: WeeklyStreak(
                        completedDates: completedThisWeek,
                        selectedDate: _selectedDate,
                        onDateSelected: (date) {
                          setState(() => _selectedDate = date);
                        },
                      ),
                    ),
                  ),

                  // ── Bottom spacer for FAB clearance ──────────────────────
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 80),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [
                  AppColors.primary,
                  AppColors.habitIndigo,
                  AppColors.habitCoral,
                  AppColors.habitMint,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDismissibleBackground({
    required Color color,
    required IconData icon,
    required String label,
    required Alignment alignment,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.cardGap),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: AppRadius.cardBorder,
      ),
      alignment: alignment,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (alignment == Alignment.centerLeft) ...[
            Icon(icon, color: color),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ] else ...[
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            Icon(icon, color: color),
          ],
        ],
      ),
    );
  }
  Widget _buildMoodPrompt(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: AppRadius.cardBorder,
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Text('🌤️', style: TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'How are you feeling?',
                  style: AppTypography.titleSmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Take a moment to check in.',
                  style: AppTypography.bodySmall,
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const MoodCheckInSheet(),
              );
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              minimumSize: const Size(0, 32),
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Check In'),
          ),
        ],
      ),
    );
  }
}
