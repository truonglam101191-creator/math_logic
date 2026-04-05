import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:logic_mathematics/features/subscription/presentation/providers/subscription_provider.dart';
import 'package:logic_mathematics/l10n/arb/app_localizations.dart';

class RemoveAdsPage extends ConsumerStatefulWidget {
  const RemoveAdsPage({super.key});

  @override
  ConsumerState<RemoveAdsPage> createState() => _RemoveAdsPageState();
}

class _RemoveAdsPageState extends ConsumerState<RemoveAdsPage> {
  final String _productId =
      'premium_remove_ads'; // Đổi ID này theo config trên Google/Apple
  List<ProductDetails> _products = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final bool available = await InAppPurchase.instance.isAvailable();
    if (!available) {
      setState(() => _loading = false);
      return;
    }

    final ProductDetailsResponse response = await InAppPurchase.instance
        .queryProductDetails({_productId});

    if (response.notFoundIDs.isEmpty) {
      setState(() {
        _products = response.productDetails;
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final subscriptionStatus = ref.watch(subscriptionProvider);

    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.removeAdsTitle)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (subscriptionStatus.isActive) ...[
                const Icon(Icons.star, size: 80, color: Colors.amber),
                const SizedBox(height: 16),
                Text(
                  l10n.premiumActiveMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (subscriptionStatus.expireDate != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      '${l10n.premiumExpirePrefix}${subscriptionStatus.expireDate!.toLocal().toString().split(".")[0]}',
                    ),
                  ),
              ] else if (_loading) ...[
                const CircularProgressIndicator(),
              ] else if (_products.isNotEmpty) ...[
                const Icon(
                  Icons.do_not_disturb_alt,
                  size: 80,
                  color: Colors.redAccent,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.upgradePremiumMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    ref
                        .read(subscriptionProvider.notifier)
                        .purchase(_products.first);
                  },
                  child: Text(
                    '${l10n.subscribeNowPrefix}(${_products.first.price})',
                  ),
                ),
              ] else ...[
                Text(l10n.noSubscriptionPackages),
              ],
              const SizedBox(height: 64),
              // Nút Restore (Cho trường hợp xoá app tải lại)
              TextButton(
                onPressed: () {
                  ref.read(subscriptionProvider.notifier).restore();
                },
                child: Text(l10n.restorePurchases),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
