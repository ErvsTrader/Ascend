import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../core/design_system.dart';
import '../models/habit.dart';

// ---------------------------------------------------------------------------
// HabitCard – single habit row matching Visily Home.png
// ---------------------------------------------------------------------------

class HabitCard extends StatefulWidget {
  final Habit habit;
  final DateTime? targetDate;
  final VoidCallback? onToggle;
  final VoidCallback? onTap;

  const HabitCard({
    super.key,
    required this.habit,
    this.targetDate,
    this.onToggle,
    this.onTap,
  });

  @override
  State<HabitCard> createState() => _HabitCardState();
}

class _HabitCardState extends State<HabitCard> {
  bool _isTapping = false;

  @override
  Widget build(BuildContext context) {
    final displayDate = widget.targetDate ?? DateTime.now();
    final completed = widget.habit.isCompletedOn(displayDate);
    final streak = widget.habit.getCurrentStreak();
    final timeStr = _formatTime(widget.habit.reminderTime);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.cardGap),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.cardBorder,
            boxShadow: AppShadows.cardSm,
          ),
          child: Row(
            children: [
              // ── Streak icon ──────────────────────────────────────────
              _StreakBadge(streak: streak, color: Color(widget.habit.colorValue)),

              const SizedBox(width: AppSpacing.md),

              // ── Habit info ───────────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.habit.name, style: AppTypography.titleMedium),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        Text(
                          widget.habit.category.toUpperCase(),
                          style: AppTypography.labelLarge,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Icon(
                          Icons.access_time_rounded,
                          size: 12,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(timeStr, style: AppTypography.bodySmall),
                      ],
                    ),
                  ],
                ),
              ),

              // ── Circular checkbox ────────────────────────────────────
              GestureDetector(
                onTapDown: (_) => setState(() => _isTapping = true),
                onTapUp: (_) => setState(() => _isTapping = false),
                onTapCancel: () => setState(() => _isTapping = false),
                onTap: () {
                  if (!completed) {
                    HapticFeedback.mediumImpact();
                  } else {
                    HapticFeedback.lightImpact();
                  }
                  if (widget.onToggle != null) widget.onToggle!();
                },
                child: AnimatedScale(
                  scale: _isTapping ? 1.2 : 1.0,
                  duration: const Duration(milliseconds: 100),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: AppComponents.checkboxSize,
                    height: AppComponents.checkboxSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: completed ? AppColors.primary : Colors.transparent,
                      border: Border.all(
                        color: completed ? AppColors.primary : AppColors.unchecked,
                        width: 2,
                      ),
                    ),
                    child: completed
                        ? const Icon(
                            Icons.check_rounded,
                            size: 16,
                            color: AppColors.textOnPrimary,
                          )
                        : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat.jm().format(dt);
  }
}

// ---------------------------------------------------------------------------
// _StreakBadge – fire icon with streak count in a tinted circle
// ---------------------------------------------------------------------------

class _StreakBadge extends StatelessWidget {
  final int streak;
  final Color color;

  const _StreakBadge({required this.streak, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppComponents.iconContainerMd,
      height: AppComponents.iconContainerMd,
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        shape: BoxShape.circle,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.local_fire_department_outlined,
            size: 18,
            color: color,
          ),
          Text(
            '$streak',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}
