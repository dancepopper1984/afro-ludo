/// 成就数据模型
class Achievement {
  final String id;
  final String name;
  final String description;
  final String iconName;
  final int? coinReward;

  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.iconName,
    this.coinReward,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Achievement && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
