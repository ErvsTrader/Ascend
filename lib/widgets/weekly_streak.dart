import 'package:flutter/material.dart';

import '../core/design_system.dart';

// ---------------------------------------------------------------------------
// WeeklyStreak – 7-day streak row matching Home.png bottom section
// ---------------------------------------------------------------------------

class WeeklyStreak extends StatelessWidget {
  /// Which dates in this week have been completed (at least one habit).
  final Set<DateTime> completedDates;

  const WeeklyStreak({super.key, required this.completedDates});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    // Start of the current week (Monday).
    final monday = now.subtract(Duration(days: now.weekday - 1));

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
          // ── Header ─────────────────────────────────────────────────
          Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: AppComponents.iconSm,
                color: AppColors.primary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text('Weekly Streak', style: AppTypography.headlineSmall),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // ── Day-of-week labels ─────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              _DayLabel('M'),
              _DayLabel('T'),
              _DayLabel('W'),
              _DayLabel('T'),
              _DayLabel('F'),
              _DayLabel('S'),
              _DayLabel('S'),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          // ── Day circles ────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (i) {
              final day = monday.add(Duration(days: i));
              final dateOnly = DateTime(day.year, day.month, day.day);
              final today = DateTime(now.year, now.month, now.day);

              final isCompleted = completedDates
                  .any((d) => DateTime(d.year, d.month, d.day) == dateOnly);
              final isToday = dateOnly == today;
              final isPast = dateOnly.isBefore(today);
              final isFuture = dateOnly.isAfter(today);

              return _DayCircle(
                dayNumber: day.day,
                isCompleted: isCompleted,
                isToday: isToday,
                isFuture: isFuture,
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _DayLabel – "M", "T", "W", etc.
// ---------------------------------------------------------------------------

class _DayLabel extends StatelessWidget {
  final String label;
  const _DayLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppComponents.streakDaySize,
      child: Center(
        child: Text(label, style: AppTypography.labelMedium),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _DayCircle – single day in the weekly streak row
// ---------------------------------------------------------------------------

class _DayCircle extends StatelessWidget {
  final int dayNumber;
  final bool isCompleted;
  final bool isToday;
  final bool isFuture;

  const _DayCircle({
    required this.dayNumber,
    required this.isCompleted,
    required this.isToday,
    required this.isFuture,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;

    if (isCompleted) {
      bgColor = AppColors.primary;
      textColor = AppColors.textOnPrimary;
    } else if (isToday) {
      bgColor = AppColors.primarySurface;
      textColor = AppColors.primary;
    } else {
      bgColor = Colors.transparent;
      textColor = isFuture ? AppColors.textTertiary : AppColors.textSecondary;
    }

    return Container(
      width: AppComponents.streakDaySize,
      height: AppComponents.streakDaySize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: bgColor,
      ),
      alignment: Alignment.center,
      child: Text(
        '$dayNumber',
        style: TextStyle(
          fontSize: 13,
          fontWeight: isCompleted || isToday ? FontWeight.w600 : FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }
}
