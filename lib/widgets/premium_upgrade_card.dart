import 'package:flutter/material.dart';
import '../core/design_system.dart';

class PremiumUpgradeCard extends StatelessWidget {
  final bool isPremium;
  final VoidCallback onUpgrade;
  final VoidCallback? onRestore;
  final bool isLoading;

  const PremiumUpgradeCard({
    super.key,
    required this.isPremium,
    required this.onUpgrade,
    this.onRestore,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isPremium) {
      // ... same green box
      return Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: const Color(0xFFECFDF5), // Light green
          borderRadius: AppRadius.cardLargeBorder,
          border: Border.all(color: const Color(0xFF10B981).withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFF10B981),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_rounded, color: Colors.white, size: 20),
                ),
                const SizedBox(width: AppSpacing.md),
                Text(
                  'Premium Active',
                  style: AppTypography.titleLarge.copyWith(color: const Color(0xFF065F46)),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Thank you for supporting Ascend! Enjoy unlimited habits and all premium features.',
              style: AppTypography.bodySmall.copyWith(color: const Color(0xFF065F46)),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF818CF8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.cardLargeBorder,
        boxShadow: AppShadows.cardMd,
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '🚀 Upgrade to Premium',
                style: AppTypography.headlineMedium.copyWith(color: Colors.white),
              ),
              const SizedBox(height: AppSpacing.lg),
              _buildFeature('Unlimited habits (Free: 5 max)'),
              _buildFeature('Remove all ads'),
              _buildFeature('Advanced stats & insights'),
              _buildFeature('Mood notes & correlations'),
              _buildFeature('Monthly view & history'),
              _buildFeature('Export data to PDF'),
              const SizedBox(height: AppSpacing.xl),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '\$4.99 One-Time',
                    style: AppTypography.titleMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton(
                    onPressed: isLoading ? null : onUpgrade,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                          )
                        : const Text('Upgrade Now'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Align(
                alignment: Alignment.center,
                child: TextButton(
                  onPressed: isLoading ? null : onRestore,
                  child: Text(
                    'Restore Purchase',
                    style: AppTypography.labelSmall.copyWith(color: Colors.white.withOpacity(0.8)),
                  ),
                ),
              ),
            ],
          ),
          if (isLoading)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.1),
                  borderRadius: AppRadius.cardLargeBorder,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFeature(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: AppTypography.bodySmall.copyWith(color: Colors.white.withOpacity(0.9)),
            ),
          ),
        ],
      ),
    );
  }
}
