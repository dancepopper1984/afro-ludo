import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/wheel_rewards.dart';
import '../../models/wheel_reward.dart';
import '../../services/storage_service.dart';

enum WheelStatus { idle, spinning, done }

const _sentinel = Object();

class WheelState {
  final WheelStatus status;
  final WheelReward? lastReward;
  final bool freeSpinUsedToday;
  final String? lastSpinDate;
  final int adSpinsAvailable;

  const WheelState({
    this.status = WheelStatus.idle,
    this.lastReward,
    this.freeSpinUsedToday = false,
    this.lastSpinDate,
    this.adSpinsAvailable = 0,
  });

  WheelState copyWith({
    WheelStatus? status,
    Object? lastReward = _sentinel,
    bool? freeSpinUsedToday,
    Object? lastSpinDate = _sentinel,
    int? adSpinsAvailable,
  }) =>
      WheelState(
        status: status ?? this.status,
        lastReward: lastReward == _sentinel ? this.lastReward : lastReward as WheelReward?,
        freeSpinUsedToday: freeSpinUsedToday ?? this.freeSpinUsedToday,
        lastSpinDate: lastSpinDate == _sentinel ? this.lastSpinDate : lastSpinDate as String?,
        adSpinsAvailable: adSpinsAvailable ?? this.adSpinsAvailable,
      );

  bool get canSpinFree => !freeSpinUsedToday;
  bool get canSpinAd => adSpinsAvailable > 0;
  bool get canSpin => canSpinFree || canSpinAd;
}

/// 幸运转盘状态管理
///
/// - 每日 1 次免费转动
/// - 观看广告获得额外转动机会
/// - 按权重随机发放金币奖励
class WheelNotifier extends StateNotifier<WheelState> {
  final Random _random;

  WheelNotifier({Random? random})
      : _random = random ?? Random(),
        super(const WheelState()) {
    _loadState();
  }

  void _loadState() {
    final today = _todayString();
    final lastDate = StorageService.getLastSpinDate();
    final freeUsed = lastDate == today;
    final adSpins = StorageService.getAdSpinsAvailable() ?? 0;

    state = WheelState(
      freeSpinUsedToday: freeUsed,
      lastSpinDate: lastDate,
      adSpinsAvailable: adSpins,
    );
  }

  /// 执行转动，返回奖励（null 表示无法转动）
  WheelReward? spin() {
    if (!state.canSpin) return null;
    if (state.status == WheelStatus.spinning) return null;

    state = state.copyWith(status: WheelStatus.spinning);

    final isFree = state.canSpinFree;
    final today = _todayString();

    // 扣除转动次数
    final newAdSpins = isFree
        ? state.adSpinsAvailable
        : state.adSpinsAvailable - 1;

    // 持久化
    if (isFree) {
      StorageService.setLastSpinDate(today);
    }
    StorageService.setAdSpinsAvailable(newAdSpins);

    // 随机选择奖励
    final reward = _selectReward();

    state = state.copyWith(
      status: WheelStatus.done,
      lastReward: reward,
      freeSpinUsedToday: isFree || state.freeSpinUsedToday,
      lastSpinDate: today,
      adSpinsAvailable: newAdSpins,
    );

    return reward;
  }

  /// 添加广告转动机会（看完广告后调用）
  void addAdSpin() {
    final newCount = state.adSpinsAvailable + 1;
    StorageService.setAdSpinsAvailable(newCount);
    state = state.copyWith(adSpinsAvailable: newCount);
  }

  /// 重置状态为可再次转动（用于 UI 关闭后）
  void reset() {
    state = state.copyWith(status: WheelStatus.idle, lastReward: null);
  }

  /// 按权重随机选择奖励（package-private for testing）
  WheelReward _selectReward() {
    final total = WheelRewards.totalWeight;
    var pointer = _random.nextDouble() * total;

    for (final reward in WheelRewards.rewards) {
      pointer -= reward.weight;
      if (pointer <= 0) return reward;
    }

    return WheelRewards.rewards.last;
  }

  static String _todayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}

final wheelNotifierProvider = StateNotifierProvider<WheelNotifier, WheelState>(
  (ref) => WheelNotifier(),
);
