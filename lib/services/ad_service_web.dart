import 'package:flutter/foundation.dart';

import 'premium_service.dart';

// ---------------------------------------------------------------------------
// AdService (Web Stub) – no-op implementation for web platform
// ---------------------------------------------------------------------------

class AdService extends ChangeNotifier {
  final PremiumService premiumService;

  AdService({required this.premiumService});

  static Future<void> initialize() async {
    // No-op on web
    debugPrint('AdService.initialize() - Web platform (no-op)');
  }

  dynamic createBannerAd({
    required void Function(dynamic) onAdLoaded,
    required void Function(dynamic, dynamic) onAdFailedToLoad,
  }) {
    // Return null on web - no ads
    return null;
  }

  void loadInterstitialAd() {
    // No-op on web
  }

  void showInterstitialAd() {
    // No-op on web
  }

  @override
  void dispose() {
    super.dispose();
  }
}
