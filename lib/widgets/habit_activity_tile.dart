import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/design_system.dart';

class HabitActivityTile extends StatelessWidget {
  final DateTime date;
  final bool isCompleted;
  final String? moodLabel;
  final String? moodEmoji;
  final IconData? moodIcon;

  const HabitActivityTile({
    super.key,
    required this.date,
    required this.isCompleted,
    this.moodLabel,
    this.moodEmoji,
    this.moodIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.cardBorder,
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isCompleted ? AppColors.primarySurface : AppColors.background,
              shape: BoxShape.circle,
            ),
            child: isCompleted && moodEmoji != null
                ? Text(moodEmoji!, style: const TextStyle(fontSize: 20))
                : Icon(
                    isCompleted ? (moodIcon ?? Icons.check_rounded) : Icons.radio_button_unchecked_rounded,
                    size: 24,
                    color: isCompleted ? AppColors.primary : AppColors.textTertiary,
                  ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('EEEE, MMM d').format(date),
                  style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.access_time_rounded, size: 12, color: AppColors.textTertiary),
                    const SizedBox(width: 4),
                    Text(
                      isCompleted ? DateFormat('hh:mm a').format(date) : '--:--',
                      style: AppTypography.bodySmall,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    const Text('•', style: TextStyle(color: AppColors.textTertiary)),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      moodLabel ?? (isCompleted ? 'No mood recorded' : 'Skipped'),
                      style: AppTypography.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isCompleted ? AppColors.primary.withOpacity(0.1) : AppColors.textTertiary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isCompleted ? 'Completed' : 'Skipped',
              style: AppTypography.labelSmall.copyWith(
                color: isCompleted ? AppColors.primary : AppColors.textTertiary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
