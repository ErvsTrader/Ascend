import 'package:flutter/material.dart';
import '../../core/design_system.dart';

class PremiumUpgradePrompt extends StatelessWidget {
  const PremiumUpgradePrompt({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppRadius.lg),
          topRight: Radius.circular(AppRadius.lg),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.stars_rounded,
            size: 64,
            color: AppColors.primary,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Upgrade to Premium',
            style: AppTypography.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'You\'ve reached the limit of 5 habits on the free tier. Upgrade now to unlock unlimited habits and remove all ads.',
            style: AppTypography.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xxl),
          _BenefitRow(icon: Icons.infinity, text: 'Unlimited habits'),
          const SizedBox(height: AppSpacing.md),
          _BenefitRow(icon: Icons.ad_units_off_rounded, text: 'No advertisements'),
          const SizedBox(height: AppSpacing.md),
          _BenefitRow(icon: Icons.analytics_outlined, text: 'Advanced analytics'),
          const SizedBox(height: AppSpacing.xxxl),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement purchase logic
              Navigator.pop(context);
            },
            child: const Text('Upgrade Now'),
          ),
          const SizedBox(height: AppSpacing.md),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Maybe later',
              style: AppTypography.buttonMedium.copyWith(color: AppColors.textTertiary),
            ),
          ),
        ],
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _BenefitRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 20, color: AppColors.success),
        const SizedBox(width: AppSpacing.sm),
        Text(text, style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w500)),
      ],
    );
  }
}
