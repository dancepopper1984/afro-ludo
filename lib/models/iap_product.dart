/// IAP 商品数据模型
///
/// 对应 Google Play Console 中配置的内购商品。
/// TODO: 上架前在 Play Console 创建对应商品并替换 [storeId]。
class IapProduct {
  final String storeId;
  final String name;
  final String description;
  final String priceDisplay;
  final int coinReward;

  const IapProduct({
    required this.storeId,
    required this.name,
    required this.description,
    required this.priceDisplay,
    required this.coinReward,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IapProduct &&
          runtimeType == other.runtimeType &&
          storeId == other.storeId;

  @override
  int get hashCode => storeId.hashCode;
}
