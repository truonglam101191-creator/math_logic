import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:logic_mathematics/cores/configs/configs.dart';
import 'package:logic_mathematics/cores/models/purchasable_product_model.dart';

class LocalInAppPurchase {
  static late final InAppPurchase inAppPurchase;
  static late final Function(PurchaseStatus)? resultEvent;
  static final List<PurchasableProduct> listProduct = [];
  static final List<PurchasableProduct> listSubs = [];

  static late Function(PurchaseDetails productDetails)? onInAppSuccess;
  static late Function(PurchaseDetails productDetails)? onSubSuccess;
  static late Function(PurchaseDetails productDetails)? onFail;

  final idinApps = <String>{
    '${Configs.inappPurchaseId}_inapp_0',
    '${Configs.inappPurchaseId}_inapp_1',
    '${Configs.inappPurchaseId}_inapp_2',
    '${Configs.inappPurchaseId}_inapp_3',
    '${Configs.inappPurchaseId}_inapp_4',
    '${Configs.inappPurchaseId}_inapp_5',
    '${Configs.inappPurchaseId}_inapp_6',
    '${Configs.inappPurchaseId}_inapp_7',
    '${Configs.inappPurchaseId}_inapp_8',
    '${Configs.inappPurchaseId}_inapp_9',
    '${Configs.inappPurchaseId}_inapp_10',
  };

  final idSub = <String>{};

  LocalInAppPurchase() {
    init();
  }

  Future<void> init() async {
    inAppPurchase = InAppPurchase.instance;
    final available = await inAppPurchase.isAvailable();
    if (!available) {
      onInAppSuccess = null;
      onSubSuccess = null;
      onFail = null;
      return;
    }

    final addAllID = <String>{};
    addAllID.addAll(idinApps);
    addAllID.addAll(idSub);

    final response = await inAppPurchase.queryProductDetails(addAllID);

    for (var element in response.notFoundIDs) {
      print('Purchase $element not found');
    }

    response.productDetails.forEach((element) {
      if (idinApps.contains(element.id)) {
        listProduct.add(PurchasableProduct(element));
      } else if (idSub.contains(element.id)) {
        listSubs.add(PurchasableProduct(element));
      }
    });

    listProduct.sort(
      ((a, b) => int.parse(
        a.id.replaceAll(RegExp(r'[^0-9]'), ''),
      ).compareTo(int.parse(b.id.replaceAll(RegExp(r'[^0-9]'), '')))),
    );

    inAppPurchase.purchaseStream.listen((event) {
      for (var element in event) {
        if (element.status == PurchaseStatus.error) {
          onFail?.call(element);
        } else if (element.status == PurchaseStatus.purchased) {
          if (idinApps.contains(element.productID)) {
            onInAppSuccess?.call(element);
          } else if (idSub.contains(element.productID)) {
            onSubSuccess?.call(element);
          }
        }
      }
    });
  }

  Future<void> buy(PurchasableProduct product) async {
    final purchaseParam = PurchaseParam(productDetails: product.productDetails);
    if (idinApps.contains(product.id)) {
      inAppPurchase.buyConsumable(purchaseParam: purchaseParam);
    } else if (idSub.contains(product.id)) {
      inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
    }
  }
}
