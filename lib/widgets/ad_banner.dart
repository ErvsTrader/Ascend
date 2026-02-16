import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/design_system.dart';
import '../services/premium_service.dart';

// ---------------------------------------------------------------------------
// AdBanner – placeholder for Google AdMob banner
// ---------------------------------------------------------------------------
//
// This widget renders a placeholder banner that mimics the 50 dp AdMob
// banner. When the google_mobile_ads SDK is configured with real ad-unit
// IDs, replace the Container with an actual AdWidget.
//
// The banner is hidden entirely when the user has premium status.
// ---------------------------------------------------------------------------

class AdBanner extends StatelessWidget {
  const AdBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final isPremium = context.watch<PremiumService>().isPremium;
    if (isPremium) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      height: 50,
      color: AppColors.surface,
      alignment: Alignment.center,
      child: Text(
        'Ad Banner',
        style: AppTypography.bodySmall.copyWith(
          color: AppColors.textTertiary,
        ),
      ),
    );
  }
}
