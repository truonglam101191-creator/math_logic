import 'package:shared_preferences/shared_preferences.dart';

class SubscriptionLocalDataSource {
  final SharedPreferences _prefs;

  SubscriptionLocalDataSource(this._prefs);

  static const _keyIsActive = 'sub_is_active';
  static const _keyExpireDate = 'sub_expire_date';
  static const _keyProductId = 'sub_product_id';
  static const _keyPurchaseToken = 'sub_purchase_token';

  Future<void> saveSubscription({
    required bool isActive,
    required String productId,
    required String purchaseToken,
    required DateTime? expireDate,
  }) async {
    await _prefs.setBool(_keyIsActive, isActive);
    await _prefs.setString(_keyProductId, productId);
    await _prefs.setString(_keyPurchaseToken, purchaseToken);
    if (expireDate != null) {
      await _prefs.setString(_keyExpireDate, expireDate.toIso8601String());
    } else {
      await _prefs.remove(_keyExpireDate);
    }
  }

  Future<void> clearSubscription() async {
    await _prefs.remove(_keyIsActive);
    await _prefs.remove(_keyProductId);
    await _prefs.remove(_keyPurchaseToken);
    await _prefs.remove(_keyExpireDate);
  }

  bool get isActive => _prefs.getBool(_keyIsActive) ?? false;
  String? get productId => _prefs.getString(_keyProductId);
  String? get purchaseToken => _prefs.getString(_keyPurchaseToken);
  
  DateTime? get expireDate {
    final dateStr = _prefs.getString(_keyExpireDate);
    if (dateStr == null) return null;
    return DateTime.tryParse(dateStr);
  }
}
