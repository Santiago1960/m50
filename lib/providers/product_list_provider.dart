import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

final productListProvider =
    StateNotifierProvider<ProductListNotifier, List<ProductDetails>>(
  (ref) => ProductListNotifier(),
);

class ProductListNotifier extends StateNotifier<List<ProductDetails>> {
  ProductListNotifier() : super([]) {
    _loadProducts();
  }

  final _productIds = {'remove_ads', 'unlock_dof'};

  Future<void> _loadProducts() async {
    final available = await InAppPurchase.instance.isAvailable();
    if (!available) return;

    final response =
        await InAppPurchase.instance.queryProductDetails(_productIds);
    if (response.error != null) {
      print('Error al obtener productos: ${response.error}');
      return;
    }
    state = response.productDetails;
  }
}