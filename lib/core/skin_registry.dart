import '../models/skin.dart';

/// 皮肤注册表
///
/// 集中定义所有可购买/装备的皮肤。新增皮肤只需在此注册。
class SkinRegistry {
  const SkinRegistry._();

  /// 默认皮肤（免费，自动解锁）
  static const Skin classic = Skin(
    id: 'classic',
    name: 'Classic',
    description: 'The timeless Afro Ludo look.',
    price: 0,
    type: SkinType.theme,
    iconName: 'palette',
  );

  static const Skin goldenDice = Skin(
    id: 'golden_dice',
    name: 'Golden Dice',
    description: 'Roll in style with a golden dice skin.',
    price: 500,
    type: SkinType.dice,
    iconName: 'casino',
  );

  static const Skin neonBoard = Skin(
    id: 'neon',
    name: 'Neon Board',
    description: 'A vibrant neon-colored board theme.',
    price: 1000,
    type: SkinType.board,
    iconName: 'grid_on',
  );

  static const Skin proBadge = Skin(
    id: 'pro_badge',
    name: 'Pro Player Badge',
    description: 'Show off your pro status in matches.',
    price: 2000,
    type: SkinType.badge,
    iconName: 'emoji_events',
  );

  static const Skin afroTheme = Skin(
    id: 'afro',
    name: 'Afro Theme Pack',
    description: 'Complete African-inspired visual overhaul.',
    price: 5000,
    type: SkinType.theme,
    iconName: 'palette',
  );

  /// 所有可用皮肤列表
  static const List<Skin> all = [
    classic,
    goldenDice,
    neonBoard,
    proBadge,
    afroTheme,
  ];

  /// 按 ID 查找皮肤
  static Skin? byId(String id) {
    for (final skin in all) {
      if (skin.id == id) return skin;
    }
    return null;
  }

  /// 可购买的皮肤（排除免费默认皮肤）
  static List<Skin> get purchasable =>
      all.where((s) => s.price > 0).toList();
}
