import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:logic_mathematics/features/subscription/domain/entities/subscription_status.dart';
import 'package:logic_mathematics/features/subscription/domain/repositories/subscription_repository.dart';

class CheckSubscriptionUseCase {
  final SubscriptionRepository repository;
  CheckSubscriptionUseCase(this.repository);

  Future<SubscriptionStatus> call() async {
    return repository.checkSubscriptionStatus();
  }
}

class PurchaseSubscriptionUseCase {
  final SubscriptionRepository repository;
  PurchaseSubscriptionUseCase(this.repository);

  Future<void> call(ProductDetails product) async {
    return repository.purchaseSubscription(product);
  }
}

class RestoreSubscriptionUseCase {
  final SubscriptionRepository repository;
  RestoreSubscriptionUseCase(this.repository);

  Future<void> call() async {
    return repository.restorePurchases();
  }
}
