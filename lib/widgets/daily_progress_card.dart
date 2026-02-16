import 'package:flutter/material.dart';

import '../core/design_system.dart';

// ---------------------------------------------------------------------------
// DailyProgressCard – matches the light-blue progress card on Home.png
// ---------------------------------------------------------------------------

class DailyProgressCard extends StatelessWidget {
  final int completedCount;
  final int totalCount;

  const DailyProgressCard({
    super.key,
    required this.completedCount,
    required this.totalCount,
  });

  double get _progress => totalCount == 0 ? 0.0 : completedCount / totalCount;
  int get _percentage => (_progress * 100).round();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: AppRadius.cardLargeBorder,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Title row + percentage ──────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily Progress',
                      style: AppTypography.headlineSmall.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      "You've finished $completedCount of $totalCount habits.",
                      style: AppTypography.bodyMedium,
                    ),
                  ],
                ),
              ),
              Text(
                '$_percentage%',
                style: AppTypography.displayLarge,
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // ── Progress bar ────────────────────────────────────────────
          ClipRRect(
            borderRadius: BorderRadius.circular(AppComponents.progressBarHeight / 2),
            child: LinearProgressIndicator(
              value: _progress,
              minHeight: AppComponents.progressBarHeight,
              backgroundColor: AppColors.progressTrack,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
