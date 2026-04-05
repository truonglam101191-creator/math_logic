import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:logic_mathematics/features/subscription/data/datasources/network_time_remote_datasource.dart';
import 'package:logic_mathematics/features/subscription/data/datasources/subscription_local_datasource.dart';
import 'package:logic_mathematics/features/subscription/domain/entities/subscription_status.dart';
import 'package:logic_mathematics/features/subscription/domain/repositories/subscription_repository.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  final SubscriptionLocalDataSource _localDS;
  final NetworkTimeRemoteDataSource _networkTimeDS;
  final InAppPurchase _iap = InAppPurchase.instance;

  StreamSubscription<List<PurchaseDetails>>? _subscription;
  Function(SubscriptionStatus)? _onStatusChanged;
  Function(String)? _onError;

  SubscriptionRepositoryImpl(this._localDS, this._networkTimeDS);

  @override
  void initPurchaseListener({
    required Function(SubscriptionStatus) onStatusChanged,
    required Function(String) onError,
  }) {
    _onStatusChanged = onStatusChanged;
    _onError = onError;
    final Stream<List<PurchaseDetails>> purchaseUpdated = _iap.purchaseStream;
    _subscription = purchaseUpdated.listen(
      _onPurchaseUpdate,
      onDone: () => _subscription?.cancel(),
      onError: (error) {
        _onError?.call('IAP Stream Error: $error');
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) async {
    for (var purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        // Có thể báo pending lên UI nếu cần
        continue;
      }

      if (purchaseDetails.status == PurchaseStatus.error) {
        _onError?.call(purchaseDetails.error?.message ?? 'Unknown Error');
      } else if (purchaseDetails.status == PurchaseStatus.purchased ||
                 purchaseDetails.status == PurchaseStatus.restored) {
        try {
          // Khi mua hoặc restore thành công, lưu lại cache
          // Giả định gói mua là theo tháng (30 ngày) = LifeTime (App tuỳ chỉnh)
          // Ở đây tôi lấy ví dụ gói loại bỏ quảng cáo thành subscription 1 năm hoặc lifetime tuỳ ID.
          // Bạn thay cấu hình thời hạn tương ứng với Product ID bạn định dùng.
          DateTime expireDate = DateTime.now().add(const Duration(days: 30)); 
          
          await _localDS.saveSubscription(
            isActive: true,
            productId: purchaseDetails.productID,
            purchaseToken: purchaseDetails.verificationData.serverVerificationData, // Token
            expireDate: expireDate,
          );

          if (purchaseDetails.pendingCompletePurchase) {
            await _iap.completePurchase(purchaseDetails);
          }

          final status = await checkSubscriptionStatus();
          _onStatusChanged?.call(status);
        } catch (e) {
          _onError?.call('Gặp lỗi khi xử lý thanh toán: $e');
        }
      }
    }
  }

  @override
  Future<SubscriptionStatus> checkSubscriptionStatus() async {
    final bool isActiveLocal = _localDS.isActive;
    if (!isActiveLocal) {
      return SubscriptionStatus.unsubscribed();
    }

    final DateTime? expireDate = _localDS.expireDate;
    // Nếu là gói Lifetime (không có ngày hết hạn)
    if (expireDate == null) {
      return SubscriptionStatus(
        isActive: true,
        productId: _localDS.productId,
      );
    }

    try {
      final DateTime networkTime = await _networkTimeDS.getCurrentNetworkTime();
      if (networkTime.isAfter(expireDate)) {
        // Hết hạn
        await _localDS.clearSubscription();
        return SubscriptionStatus.unsubscribed();
      } else {
        // Còn hạn
        return SubscriptionStatus(
          isActive: true,
          expireDate: expireDate,
          productId: _localDS.productId,
        );
      }
    } catch (e) {
      // Offline fallback
      // So sánh bằng giờ device hiện tại nhưng cắm cờ `isOfflineFallback`
      if (DateTime.now().toUtc().isAfter(expireDate)) {
        await _localDS.clearSubscription();
        return SubscriptionStatus.unsubscribed();
      }
      return SubscriptionStatus(
        isActive: true,
        expireDate: expireDate,
        productId: _localDS.productId,
        isOfflineFallback: true,
      );
    }
  }

  @override
  Future<void> purchaseSubscription(ProductDetails product) async {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
    try {
      // Phân tách tuỳ theo định dạng: consumable / nonConsumable.
      // Remove Ads thường là nonConsumable hoặc auto-renew (Google quy định khác ios ti).
      await _iap.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      _onError?.call('Lỗi khi mua: $e');
    }
  }

  @override
  Future<void> restorePurchases() async {
    try {
      await _iap.restorePurchases();
    } catch (e) {
      _onError?.call('Lỗi khôi phục: $e');
    }
  }
}
