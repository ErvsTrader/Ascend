import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'premium_service.dart';

// ---------------------------------------------------------------------------
// AdService – manages Google Mobile Ads (Banner & Interstitial)
// ---------------------------------------------------------------------------

class AdService extends ChangeNotifier {
  final PremiumService premiumService;

  AdService({required this.premiumService});

  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdLoaded = false;

  /// Initialise the Mobile Ads SDK.
  static Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }

  /// Loads an interstitial ad. Should be called early.
  void loadInterstitialAd() {
    if (premiumService.isPremium) return;

    InterstitialAd.load(
      adUnitId: InterstitialAd.testAdUnitId, // REPLACE with real ID later
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdLoaded = true;
          _setInterstitialCallbacks(ad);
        },
        onAdFailedToLoad: (error) {
          debugPrint('InterstitialAd failed to load: $error');
          _isInterstitialAdLoaded = false;
        },
      ),
    );
  }

  void _setInterstitialCallbacks(InterstitialAd ad) {
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        loadInterstitialAd(); // Load next one
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        loadInterstitialAd();
      },
    );
  }

  /// Shows the interstitial ad if loaded and user is not premium.
  void showInterstitialAd() {
    if (premiumService.isPremium) return;

    if (_isInterstitialAdLoaded && _interstitialAd != null) {
      _interstitialAd!.show();
      _isInterstitialAdLoaded = false;
      _interstitialAd = null;
    } else {
      debugPrint('Interstitial ad not loaded yet.');
      loadInterstitialAd(); // Try loading again
    }
  }

  @override
  void dispose() {
    _interstitialAd?.dispose();
    super.dispose();
  }
}
