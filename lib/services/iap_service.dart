import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../core/iap_registry.dart';
import '../models/iap_product.dart';

/// IAP 服务内部状态
enum IapServiceStatus {
  idle,
  loading,
  available,
  pending,
  purchased,
  error,
}

/// IAP 服务
///
/// 封装 Google Play Billing，管理商品查询和购买流程。
///
/// TODO: 上架前在 Google Play Console 创建商品并测试真实购买。
class IapService {
  static final IapService _instance = IapService._internal();
  factory IapService() => _instance;
  IapService._internal();

  StreamSubscription<List<PurchaseDetails>>? _subscription;
  final List<IapProduct> _availableProducts = [];
  bool _isAvailable = false;

  // === 测试注入点 ===

  @visibleForTesting
  List<IapProduct> get availableProducts => List.unmodifiable(_availableProducts);

  @visibleForTesting
  bool get isAvailable => _isAvailable;

  @visibleForTesting
  set isAvailable(bool value) => _isAvailable = value;

  @visibleForTesting
  void setAvailableProducts(List<IapProduct> products) {
    _availableProducts
      ..clear()
      ..addAll(products);
  }

  // === 初始化 ===

  /// 初始化 IAP 连接
  ///
  /// 返回是否支持 IAP（Android 上通常为 true）。
  Future<bool> init() async {
    if (!await InAppPurchase.instance.isAvailable()) {
      _isAvailable = false;
      return false;
    }

    _isAvailable = true;
    _subscription?.cancel();
    _subscription = InAppPurchase.instance.purchaseStream.listen(
      _onPurchaseUpdate,
      onDone: () => _subscription = null,
    );

    return true;
  }

  /// 查询商品详情
  Future<List<IapProduct>> queryProducts() async {
    if (!_isAvailable) return [];

    final ids = IapRegistry.all.map((p) => p.storeId).toSet();
    final response = await InAppPurchase.instance.queryProductDetails(ids);

    _availableProducts.clear();
    for (final detail in response.productDetails) {
      final product = IapRegistry.byStoreId(detail.id);
      if (product != null) {
        _availableProducts.add(IapProduct(
          storeId: product.storeId,
          name: detail.title,
          description: detail.description,
          priceDisplay: detail.price,
          coinReward: product.coinReward,
        ));
      }
    }

    return List.unmodifiable(_availableProducts);
  }

  /// 发起购买
  ///
  /// [storeId] 对应 Google Play Console 中的商品 ID。
  /// 购买结果通过 [purchaseStream] 异步回调。
  Future<bool> purchase(String storeId) async {
    if (!_isAvailable) return false;

    final product = _availableProducts.firstWhere(
      (p) => p.storeId == storeId,
      orElse: () => throw ArgumentError('Product $storeId not found'),
    );

    // 需要先查询商品详情获取 ProductDetails
    final ids = {storeId};
    final response = await InAppPurchase.instance.queryProductDetails(ids);
    if (response.notFoundIDs.isNotEmpty) return false;

    final purchaseParam = PurchaseParam(
      productDetails: response.productDetails.first,
    );

    return InAppPurchase.instance.buyConsumable(purchaseParam: purchaseParam);
  }

  /// 消费已完成的购买（consumable 商品必须调用）
  Future<void> completePurchase(PurchaseDetails details) async {
    if (details.pendingCompletePurchase) {
      await InAppPurchase.instance.completePurchase(details);
    }
  }

  /// 释放资源
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }

  // === 内部回调 ===

  final _purchaseController = StreamController<PurchaseDetails>.broadcast();
  Stream<PurchaseDetails> get purchaseStream => _purchaseController.stream;

  void _onPurchaseUpdate(List<PurchaseDetails> detailsList) {
    for (final details in detailsList) {
      _purchaseController.add(details);
    }
  }
}
