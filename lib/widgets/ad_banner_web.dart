import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/design_system.dart';
import '../services/services.dart';

// ---------------------------------------------------------------------------
// AdBanner (Web Stub) – no-op implementation for web platform
// ---------------------------------------------------------------------------

class AdBanner extends StatelessWidget {
  const AdBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final isPremium = context.watch<PremiumService>().isPremium;
    if (isPremium) return const SizedBox.shrink();

    // On web, just show a placeholder
    return Container(
      width: double.infinity,
      height: 50,
      color: AppColors.surface,
      alignment: Alignment.center,
      child: Text(
        'Ad Banner (Web)',
        style: AppTypography.bodySmall.copyWith(
          color: AppColors.textTertiary,
        ),
      ),
    );
  }
}
