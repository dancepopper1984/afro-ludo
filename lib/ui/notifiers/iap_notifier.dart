import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart' show PurchaseDetails, PurchaseStatus;
import '../../core/iap_registry.dart';
import '../../models/iap_product.dart';
import '../../services/iap_service.dart';
import 'economy_notifier.dart';

/// IAP 界面状态
enum IapUiStatus {
  idle,
  loading,
  ready,
  purchasing,
  success,
  error,
}

/// IAP 状态
class IapState {
  final IapUiStatus status;
  final List<IapProduct> products;
  final String? error;
  final int? lastPurchasedCoins;

  const IapState({
    this.status = IapUiStatus.idle,
    this.products = const [],
    this.error,
    this.lastPurchasedCoins,
  });

  IapState copyWith({
    IapUiStatus? status,
    List<IapProduct>? products,
    Object? error = _sentinel,
    Object? lastPurchasedCoins = _sentinel,
  }) =>
      IapState(
        status: status ?? this.status,
        products: products ?? this.products,
        error: error == _sentinel ? this.error : error as String?,
        lastPurchasedCoins: lastPurchasedCoins == _sentinel
            ? this.lastPurchasedCoins
            : lastPurchasedCoins as int?,
      );

  bool get isReady => status == IapUiStatus.ready;
  bool get isPurchasing => status == IapUiStatus.purchasing;
}

const _sentinel = Object();

/// IAP 状态管理器
///
/// 负责：
/// - 初始化 IAP 连接并查询商品
/// - 管理购买流程和状态
/// - 购买成功后通过 [onPurchaseCompleted] 回调发放金币
class IapNotifier extends StateNotifier<IapState> {
  final IapService _iapService;
  final void Function(int coins)? onPurchaseCompleted;
  StreamSubscription<PurchaseDetails>? _purchaseSub;

  IapNotifier({
    IapService? iapService,
    this.onPurchaseCompleted,
  })  : _iapService = iapService ?? IapService(),
        super(const IapState()) {
    _listenToPurchases();
  }

  void _listenToPurchases() {
    _purchaseSub = _iapService.purchaseStream.listen(
      _handlePurchaseUpdate,
      onError: (Object e) {
        state = state.copyWith(
          status: IapUiStatus.error,
          error: 'Purchase stream error: $e',
        );
      },
    );
  }

  /// 初始化 IAP 并查询商品
  Future<void> init() async {
    state = state.copyWith(status: IapUiStatus.loading);

    final available = await _iapService.init();
    if (!available) {
      state = state.copyWith(
        status: IapUiStatus.error,
        error: 'In-app purchases not available',
      );
      return;
    }

    final products = await _iapService.queryProducts();
    if (products.isEmpty) {
      state = state.copyWith(
        status: IapUiStatus.error,
        error: 'No products available',
      );
      return;
    }

    state = state.copyWith(
      status: IapUiStatus.ready,
      products: products,
    );
  }

  /// 发起购买
  Future<bool> purchase(String storeId) async {
    if (!state.isReady || state.isPurchasing) return false;

    state = state.copyWith(status: IapUiStatus.purchasing);

    try {
      final result = await _iapService.purchase(storeId);
      if (!result) {
        state = state.copyWith(status: IapUiStatus.ready);
      }
      return result;
    } catch (e) {
      state = state.copyWith(
        status: IapUiStatus.error,
        error: 'Purchase failed: $e',
      );
      return false;
    }
  }

  void _handlePurchaseUpdate(PurchaseDetails details) async {
    final s = details.status;
    if (s == PurchaseStatus.purchased || s == PurchaseStatus.restored) {
      await _iapService.completePurchase(details);
      final product = IapRegistry.byStoreId(details.productID);
      final coins = product?.coinReward;
      if (coins != null && onPurchaseCompleted != null) {
        onPurchaseCompleted!(coins);
      }
      state = state.copyWith(
        status: IapUiStatus.success,
        lastPurchasedCoins: coins,
      );
    } else if (s == PurchaseStatus.pending) {
      state = state.copyWith(status: IapUiStatus.purchasing);
    } else if (s == PurchaseStatus.error) {
      state = state.copyWith(
        status: IapUiStatus.error,
        error: details.error?.message ?? 'Purchase error',
      );
    } else if (s == PurchaseStatus.canceled) {
      state = state.copyWith(status: IapUiStatus.ready);
    }
  }

  /// 重置状态（购买成功/失败后，允许再次购买）
  void reset() {
    if (state.status == IapUiStatus.success || state.status == IapUiStatus.error) {
      state = state.copyWith(
        status: IapUiStatus.ready,
        error: null,
        lastPurchasedCoins: null,
      );
    }
  }

  @override
  void dispose() {
    _purchaseSub?.cancel();
    _iapService.dispose();
    super.dispose();
  }
}

final iapNotifierProvider = StateNotifierProvider<IapNotifier, IapState>(
  (ref) => IapNotifier(
    onPurchaseCompleted: (coins) {
      ref.read(economyNotifierProvider.notifier).addCoins(coins);
    },
  ),
);
