import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:logic_mathematics/features/subscription/domain/entities/subscription_status.dart';

abstract class SubscriptionRepository {
  /// Khởi tạo và lắng nghe các thay đổi giao dịch từ InAppPurchase (Store)
  void initPurchaseListener({
    required Function(SubscriptionStatus) onStatusChanged,
    required Function(String) onError,
  });

  /// Kiểm tra trạng thái gói cước hiện tại (Local Storage + Network Time)
  Future<SubscriptionStatus> checkSubscriptionStatus();

  /// Kích hoạt mua gói (ví dụ gói tháng/năm)
  Future<void> purchaseSubscription(ProductDetails product);

  /// Khôi phục các gói đã mua (Restore Purchases)
  Future<void> restorePurchases();

  /// Giải phóng listener
  void dispose();
}
