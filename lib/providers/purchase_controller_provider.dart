import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import 'purchase_state_provider.dart';

final purchaseControllerProvider = Provider((ref) {
  return PurchaseController(ref);
});

class PurchaseController {
  final Ref ref;
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  final Set<String> _productIds = {'remove_ads', 'unlock_dof'};
  late final StreamSubscription<List<PurchaseDetails>> _subscription;

  List<ProductDetails> products = [];

  PurchaseController(this.ref) {
    _initialize();
  }

  Future<void> _initialize() async {
    final available = await _inAppPurchase.isAvailable();
    if (!available) return;

    final response = await _inAppPurchase.queryProductDetails(_productIds);
    if (response.notFoundIDs.isNotEmpty) {
      print('❌ Productos no encontrados: ${response.notFoundIDs}');
    }
    products = response.productDetails;

    _subscription = _inAppPurchase.purchaseStream.listen(
      _onPurchaseUpdated,
      onDone: () => _subscription.cancel(),
      onError: (error) => print('Error en compra: $error'),
    );

    /// Verificamos si ya tiene compras
    await verifyPastPurchases();
  }

  void dispose() {
    _subscription.cancel();
  }

  Future<void> buy(ProductDetails product) async {
    final param = PurchaseParam(productDetails: product);
    _inAppPurchase.buyNonConsumable(purchaseParam: param);
  }

  void _onPurchaseUpdated(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        _verifyAndUnlock(purchase);
      }

      if (purchase.pendingCompletePurchase) {
        _inAppPurchase.completePurchase(purchase);
      }
    }
  }

  void _verifyAndUnlock(PurchaseDetails purchase) {
    final notifier = ref.read(purchaseStateProvider.notifier);

    switch (purchase.productID) {
      case 'remove_ads':
        notifier.unlockAds();
        break;
      case 'unlock_dof':
        notifier.unlockDOF();
        break;
    }
  }

  Future<void> verifyPastPurchases() async {
    await _inAppPurchase.restorePurchases();
    // Las compras restauradas llegarán automáticamente a través del purchaseStream,
    // y se manejarán en _onPurchaseUpdated()
  }
}