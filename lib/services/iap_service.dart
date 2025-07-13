import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';

/// Simple wrapper around `in_app_purchase` for buying dream-credit consumables.
///
/// Product IDs configured in Google Play console must exactly match
/// the IDs below.
class IAPService {
  static const k10 = 'pack_10_dreams';   // Play-Console IDs
  static const k40 = 'pack_40_dreams';
  static const _ids = {k10, k40};

  final _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _sub;

  Future<void> init(void Function(PurchaseDetails) onPurchase) async {
    if (!await _iap.isAvailable()) throw 'Play Store unavailable';
    _sub ??= _iap.purchaseStream.listen(onPurchase);
  }

  Future<List<ProductDetails>> products() async {
    final res = await _iap.queryProductDetails(_ids);
    if (res.error != null) throw res.error!.message;
    return res.productDetails.toList();
  }

  Future<void> buy(ProductDetails p) async =>
      _iap.buyConsumable(purchaseParam: PurchaseParam(productDetails: p),
                         autoConsume: false);

  /* Android ≤ 3.2.3 : no consumePurchase() on InAppPurchase — completePurchase
     acknowledges & makes item purchasable again */
  Future<void> finish(PurchaseDetails p) async =>
      _iap.completePurchase(p);

  void dispose() => _sub?.cancel();
} 