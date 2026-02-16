import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'premium_service.dart';

// ---------------------------------------------------------------------------
// PurchaseService – handles Google Play Billing (IAP) flow
// ---------------------------------------------------------------------------

class PurchaseService extends ChangeNotifier {
  final PremiumService premiumService;
  final InAppPurchase _iap = InAppPurchase.instance;

  static const String premiumProductId = 'remove_ads_premium';

  StreamSubscription<List<PurchaseDetails>>? _subscription;
  ProductDetails? _premiumProduct;
  bool _isAvailable = false;
  bool _isLoading = false;

  PurchaseService({required this.premiumService}) {
    _initialize();
  }

  bool get isAvailable => _isAvailable;
  bool get isLoading => _isLoading;
  ProductDetails? get premiumProduct => _premiumProduct;

  void _initialize() {
    final Stream<List<PurchaseDetails>> purchaseUpdated = _iap.purchaseStream;
    _subscription = purchaseUpdated.listen(
      (purchaseDetailsList) {
        _listenToPurchaseUpdated(purchaseDetailsList);
      },
      onDone: () => _subscription?.cancel(),
      onError: (error) => debugPrint('PurchaseService error: $error'),
    );
    initStore();
  }

  /// Initialise connection to host store and load products.
  Future<void> initStore() async {
    _isAvailable = await _iap.isAvailable();
    if (_isAvailable) {
      await loadProducts();
      // Also check past purchases to auto-restore
      await restorePurchases();
    }
  }

  /// Fetch product details from the store.
  Future<void> loadProducts() async {
    const Set<String> _kIds = {premiumProductId};
    final ProductDetailsResponse response = await _iap.queryProductDetails(_kIds);

    if (response.notFoundIDs.isNotEmpty) {
      debugPrint('Products not found: ${response.notFoundIDs}');
    }

    if (response.productDetails.isNotEmpty) {
      _premiumProduct = response.productDetails.firstWhere(
        (pd) => pd.id == premiumProductId,
      );
      notifyListeners();
    }
  }

  /// Trigger the purchase flow for the premium product.
  Future<void> buyProduct() async {
    if (_premiumProduct == null) {
      debugPrint('Premium product not loaded.');
      return;
    }

    _isLoading = true;
    notifyListeners();

    final PurchaseParam purchaseParam = PurchaseParam(productDetails: _premiumProduct!);
    // Using nonConsumable for a one-time "Remove Ads" purchase
    await _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  /// Query past purchases and restore premium status if found.
  Future<void> restorePurchases() async {
    await _iap.restorePurchases();
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    for (var purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        _isLoading = true;
        notifyListeners();
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          debugPrint('Purchase error: ${purchaseDetails.error}');
          _isLoading = false;
          notifyListeners();
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          
          // Verify purchase (Optional: add server-side validation here)
          final bool valid = _verifyPurchase(purchaseDetails);
          if (valid) {
            premiumService.setPremium(true);
          }
        }

        if (purchaseDetails.pendingCompletePurchase) {
          _iap.completePurchase(purchaseDetails);
        }
        
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  bool _verifyPurchase(PurchaseDetails purchaseDetails) {
    // For "remove_ads_premium", we check if the ID matches.
    // In a production app, you'd verify the receipt with Google Play's API.
    return purchaseDetails.productID == premiumProductId;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
