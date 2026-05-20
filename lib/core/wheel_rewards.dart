import '../models/wheel_reward.dart';

/// 幸运转盘奖励配置
///
/// 权重总和不需要等于 1.0，内部使用加权随机算法。
class WheelRewards {
  const WheelRewards._();

  static const List<WheelReward> rewards = [
    WheelReward(label: '10', coins: 10, weight: 25),
    WheelReward(label: '20', coins: 20, weight: 20),
    WheelReward(label: '30', coins: 30, weight: 18),
    WheelReward(label: '50', coins: 50, weight: 15),
    WheelReward(label: '100', coins: 100, weight: 12),
    WheelReward(label: '200', coins: 200, weight: 7),
    WheelReward(label: '500', coins: 500, weight: 3),
  ];

  static double get totalWeight {
    var sum = 0.0;
    for (final r in rewards) {
      sum += r.weight;
    }
    return sum;
  }
}
