import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:logic_mathematics/features/subscription/domain/entities/subscription_status.dart';
import 'package:logic_mathematics/features/subscription/domain/repositories/subscription_repository.dart';
import 'package:logic_mathematics/features/subscription/domain/usecases/subscription_usecases.dart';
import 'package:logic_mathematics/main.dart'; // Để lấy serviceLocator

final subscriptionProvider = StateNotifierProvider<SubscriptionNotifier, SubscriptionStatus>((ref) {
  final repo = serviceLocator<SubscriptionRepository>();
  return SubscriptionNotifier(
    checkSubscriptionUseCase: CheckSubscriptionUseCase(repo),
    purchaseSubscriptionUseCase: PurchaseSubscriptionUseCase(repo),
    restoreSubscriptionUseCase: RestoreSubscriptionUseCase(repo),
    repository: repo,
  )..init();
});

class SubscriptionNotifier extends StateNotifier<SubscriptionStatus> {
  final CheckSubscriptionUseCase checkSubscriptionUseCase;
  final PurchaseSubscriptionUseCase purchaseSubscriptionUseCase;
  final RestoreSubscriptionUseCase restoreSubscriptionUseCase;
  final SubscriptionRepository repository;

  SubscriptionNotifier({
    required this.checkSubscriptionUseCase,
    required this.purchaseSubscriptionUseCase,
    required this.restoreSubscriptionUseCase,
    required this.repository,
  }) : super(SubscriptionStatus.unsubscribed());

  void init() {
    // Lắng nghe giao dịch từ Store
    repository.initPurchaseListener(
      onStatusChanged: (status) {
        state = status;
      },
      onError: (error) {
        print("Lỗi Subscription: $error");
      },
    );
    // Kiểm tra trạng thái local ngay khi khởi tạo
    checkStatus();
  }

  Future<void> checkStatus() async {
    final status = await checkSubscriptionUseCase();
    state = status;
  }

  Future<void> purchase(ProductDetails product) async {
    await purchaseSubscriptionUseCase(product);
  }

  Future<void> restore() async {
    await restoreSubscriptionUseCase();
  }

  @override
  void dispose() {
    repository.dispose();
    super.dispose();
  }
}
