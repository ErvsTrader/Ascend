import 'package:flutter/foundation.dart';
import 'premium_service.dart';

// ---------------------------------------------------------------------------
// PurchaseService (Web Stub) – no-op implementation for web platform
// ---------------------------------------------------------------------------

class PurchaseService extends ChangeNotifier {
  final PremiumService premiumService;

  PurchaseService({required this.premiumService});

  bool get isAvailable => false;
  bool get isLoading => false;
  dynamic get premiumProduct => null;

  Future<void> initStore() async {
    debugPrint('PurchaseService.initStore() - Web platform (no-op)');
  }

  Future<void> loadProducts() async {
    debugPrint('PurchaseService.loadProducts() - Web platform (no-op)');
  }

  Future<void> buyProduct() async {
    debugPrint('PurchaseService.buyProduct() - Web platform (no-op)');
  }

  Future<void> restorePurchases() async {
    debugPrint('PurchaseService.restorePurchases() - Web platform (no-op)');
  }

  @override
  void dispose() {
    super.dispose();
  }
}
