import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ---------------------------------------------------------------------------
// PremiumService – premium status via SharedPreferences
// ---------------------------------------------------------------------------

class PremiumService extends ChangeNotifier {
  static const String _key = 'is_premium';

  SharedPreferences? _prefs;
  bool _isPremium = false;

  /// Whether the user has premium access.
  bool get isPremium => _isPremium;

  /// Set premium status and persist.
  Future<void> setPremium(bool value) async {
    try {
      _isPremium = value;
      final prefs = await _ensurePrefs();
      await prefs.setBool(_key, value);
      notifyListeners();
    } catch (e) {
      debugPrint('PremiumService.setPremium error: $e');
      rethrow;
    }
  }

  /// Reads the persisted premium flag from SharedPreferences.
  /// Call this once at app startup (e.g. before `runApp`).
  Future<void> checkPremiumStatus() async {
    try {
      final prefs = await _ensurePrefs();
      _isPremium = prefs.getBool(_key) ?? false;
      notifyListeners();
    } catch (e) {
      debugPrint('PremiumService.checkPremiumStatus error: $e');
      _isPremium = false;
    }
  }

  // ── Private ─────────────────────────────────────────────────────────────

  Future<SharedPreferences> _ensurePrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }
}
