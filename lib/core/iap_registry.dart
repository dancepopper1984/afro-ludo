import '../models/iap_product.dart';

/// IAP 商品注册表
///
/// 上架前必须在 Google Play Console 创建同名商品，
/// 然后替换 [storeId] 为实际 ID。
class IapRegistry {
  const IapRegistry._();

  static const IapProduct coins500 = IapProduct(
    storeId: 'afro_coins_500',
    name: '500 AfroCoins',
    description: 'A small boost to get started.',
    priceDisplay: '¥5.00',
    coinReward: 500,
  );

  static const IapProduct coins1200 = IapProduct(
    storeId: 'afro_coins_1200',
    name: '1,200 AfroCoins',
    description: 'Great value for regular players.',
    priceDisplay: '¥10.00',
    coinReward: 1200,
  );

  static const IapProduct coins3000 = IapProduct(
    storeId: 'afro_coins_3000',
    name: '3,000 AfroCoins',
    description: 'The best deal for big spenders.',
    priceDisplay: '¥20.00',
    coinReward: 3000,
  );

  static const List<IapProduct> all = [coins500, coins1200, coins3000];

  static IapProduct? byStoreId(String id) {
    for (final p in all) {
      if (p.storeId == id) return p;
    }
    return null;
  }
}
