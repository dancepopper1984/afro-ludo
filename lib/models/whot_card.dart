/// Whot 卡牌形状
enum WhotShape {
  circle,
  cross,
  square,
  star,
  triangle,
  whot,
}

/// Whot 特殊效果
enum WhotEffect {
  /// 1 - 当前玩家继续出
  holdOn,

  /// 2 - 下家抽 2 张，跳过
  pickTwo,

  /// 5 - 下家抽 3 张，跳过
  pickThree,

  /// 8 - 跳过下家
  skip,

  /// 14 - 所有对手抽 1 张
  generalMarket,

  /// 20 (Whot) - 喊出目标形状
  whot,
}

/// Whot 卡牌
///
/// 标准尼日利亚 Whot 牌组中的单张牌。
class WhotCard {
  final WhotShape shape;
  final int number;

  const WhotCard({
    required this.shape,
    required this.number,
  });

  /// 是否是 Whot 万能牌
  bool get isWhot => shape == WhotShape.whot;

  /// 特殊效果（如果有）
  WhotEffect? get effect {
    if (isWhot) return WhotEffect.whot;
    return switch (number) {
      1 => WhotEffect.holdOn,
      2 => WhotEffect.pickTwo,
      5 => WhotEffect.pickThree,
      8 => WhotEffect.skip,
      14 => WhotEffect.generalMarket,
      _ => null,
    };
  }

  /// 检查是否可以出在当前顶部牌上
  bool canPlayOn(WhotCard top, {WhotShape? demandedShape}) {
    // Whot 万能
    if (isWhot) return true;

    // 如果顶部是 Whot 且喊出了形状，必须匹配该形状
    if (top.isWhot && demandedShape != null) {
      return shape == demandedShape || isWhot;
    }

    // 形状或数字匹配
    return shape == top.shape || number == top.number;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WhotCard &&
          runtimeType == other.runtimeType &&
          shape == other.shape &&
          number == other.number;

  @override
  int get hashCode => shape.hashCode ^ number.hashCode;

  @override
  String toString() => '${shape.name} $number';
}
