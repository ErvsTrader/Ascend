import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

import '../core/design_system.dart';
import '../services/services.dart';

// ---------------------------------------------------------------------------
// AdBanner – displays a real Google AdMob banner
// ---------------------------------------------------------------------------

class AdBanner extends StatefulWidget {
  const AdBanner({super.key});

  @override
  State<AdBanner> createState() => _AdBannerState();
}

class _AdBannerState extends State<AdBanner> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadAd();
  }

  void _loadAd() {
    final adService = context.read<AdService>();
    final premiumService = context.read<PremiumService>();

    if (premiumService.isPremium) {
      _bannerAd?.dispose();
      _bannerAd = null;
      _isLoaded = false;
      return;
    }

    if (_bannerAd == null) {
      _bannerAd = adService.createBannerAd(
        onAdLoaded: (ad) {
          if (mounted) setState(() => _isLoaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          if (mounted) setState(() => _isLoaded = false);
        },
      );
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPremium = context.watch<PremiumService>().isPremium;
    if (isPremium) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      height: 50,
      color: AppColors.surface,
      alignment: Alignment.center,
      child: _isLoaded && _bannerAd != null
          ? AdWidget(ad: _bannerAd!)
          : Text(
              'Ad Banner',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
    );
  }
}
