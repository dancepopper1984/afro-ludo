/// 皮肤类型
enum SkinType {
  board, // 棋盘主题
  dice, // 骰子皮肤
  badge, // 玩家徽章
  theme, // 全局主题包
}

/// 皮肤数据模型
///
/// 定义一件可购买/装备的视觉商品。
class Skin {
  final String id;
  final String name;
  final String description;
  final int price;
  final SkinType type;
  final String iconName;

  const Skin({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.type,
    required this.iconName,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Skin && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Skin(id: $id, name: $name)';
}
