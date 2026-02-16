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
  DateTime? _lastInterstitialTime;

  static const String bannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  static const String interstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';

  /// Initialise the Mobile Ads SDK.
  static Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }

  /// Creates and loads a BannerAd. The caller is responsible for disposal.
  BannerAd? createBannerAd({
    required void Function(Ad) onAdLoaded,
    required void Function(Ad, LoadAdError) onAdFailedToLoad,
  }) {
    if (premiumService.isPremium) return null;

    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: onAdLoaded,
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          onAdFailedToLoad(ad, error);
        },
      ),
    )..load();
  }

  /// Loads an interstitial ad. Should be called early.
  void loadInterstitialAd() {
    if (premiumService.isPremium) return;

    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdLoaded = true;
          _setInterstitialCallbacks(ad);
          debugPrint('InterstitialAd loaded.');
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
        _isInterstitialAdLoaded = false;
        _interstitialAd = null;
        loadInterstitialAd(); // Load next one
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _isInterstitialAdLoaded = false;
        _interstitialAd = null;
        loadInterstitialAd();
      },
    );
  }

  /// Shows the interstitial ad if loaded, user is not premium, and cooldown has passed.
  void showInterstitialAd() {
    if (premiumService.isPremium) return;

    // Check 3-minute cooldown
    if (_lastInterstitialTime != null) {
      final difference = DateTime.now().difference(_lastInterstitialTime!);
      if (difference.inMinutes < 3) {
        debugPrint('Interstitial ad skipped due to cooldown (${3 - difference.inMinutes}m left)');
        return;
      }
    }

    if (_isInterstitialAdLoaded && _interstitialAd != null) {
      _interstitialAd!.show();
      _lastInterstitialTime = DateTime.now();
    } else {
      debugPrint('Interstitial ad not loaded yet or failed.');
      loadInterstitialAd(); // Try loading for next time
    }
  }

  @override
  void dispose() {
    _interstitialAd?.dispose();
    super.dispose();
  }
}
