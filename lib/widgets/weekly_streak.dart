import 'package:flutter/material.dart';

import '../core/design_system.dart';

// ---------------------------------------------------------------------------
// WeeklyStreak – 7-day streak row matching Home.png bottom section
// ---------------------------------------------------------------------------

class WeeklyStreak extends StatelessWidget {
  /// Which dates in this week have been completed (at least one habit).
  final Set<DateTime> completedDates;

  /// The currently selected date to view habits for.
  final DateTime selectedDate;

  /// Callback when a date is tapped.
  final ValueChanged<DateTime> onDateSelected;

  const WeeklyStreak({
    super.key,
    required this.completedDates,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final todayOnly = DateTime(now.year, now.month, now.day);
    final selectedOnly = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 20,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text('Weekly Summary', style: AppTypography.titleMedium),
                ],
              ),
              if (selectedOnly != todayOnly)
                TextButton(
                  onPressed: () => onDateSelected(now),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                    minimumSize: const Size(0, 32),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Back to Today'),
                ),
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

              final isCompleted = completedDates
                  .any((d) => DateTime(d.year, d.month, d.day) == dateOnly);
              final isToday = dateOnly == todayOnly;
              final isSelected = dateOnly == selectedOnly;
              final isFuture = dateOnly.isAfter(todayOnly);

              return _DayCircle(
                dayNumber: day.day,
                isCompleted: isCompleted,
                isToday: isToday,
                isSelected: isSelected,
                isFuture: isFuture,
                onTap: () => onDateSelected(day),
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
        child: Text(
          label,
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.textTertiary,
            fontWeight: FontWeight.w600,
          ),
        ),
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
  final bool isSelected;
  final bool isFuture;
  final VoidCallback onTap;

  const _DayCircle({
    required this.dayNumber,
    required this.isCompleted,
    required this.isToday,
    required this.isSelected,
    required this.isFuture,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    BoxBorder? border;

    if (isCompleted) {
      bgColor = isSelected ? AppColors.primary : AppColors.primary.withOpacity(0.6);
      textColor = AppColors.textOnPrimary;
    } else if (isToday) {
      bgColor = isSelected ? AppColors.primarySurface : AppColors.primarySurface.withOpacity(0.5);
      textColor = AppColors.primary;
      border = Border.all(color: AppColors.primary.withOpacity(0.3), width: 1.5);
    } else if (isSelected) {
      bgColor = AppColors.border.withOpacity(0.4);
      textColor = AppColors.textPrimary;
    } else {
      bgColor = Colors.transparent;
      textColor = isFuture ? AppColors.textTertiary : AppColors.textSecondary;
    }

    return GestureDetector(
      onTap: isFuture ? null : onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: AppComponents.streakDaySize,
            height: AppComponents.streakDaySize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: bgColor,
              border: border,
              boxShadow: isSelected && !isCompleted
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.1),
                        blurRadius: 8,
                        spreadRadius: 1,
                      )
                    ]
                  : null,
            ),
            alignment: Alignment.center,
            child: Text(
              '$dayNumber',
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected || isCompleted || isToday ? FontWeight.w700 : FontWeight.w500,
                color: textColor,
              ),
            ),
          ),
          const SizedBox(height: 4),
          // Indicate selection with a dot if not the circle itself
          AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: isSelected ? 1 : 0,
            child: Container(
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
