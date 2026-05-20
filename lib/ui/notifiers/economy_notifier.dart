import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../models/economy_state.dart';
import '../../services/storage_service.dart';

/// 经济状态管理器
///
/// 管理 AfroCoins 的获取、消费和每日上限。
/// 状态变更自动持久化到 Hive。
class EconomyNotifier extends StateNotifier<EconomyState> {
  EconomyNotifier() : super(_loadFromStorage());

  static EconomyState _loadFromStorage() {
    try {
      final lastLoginStr = StorageService.getLastLoginDate();
      final lastLoginDate = lastLoginStr != null ? DateTime.tryParse(lastLoginStr) : null;

      return EconomyState(
        afroCoins: StorageService.getAfroCoins() ?? EconomyConstants.initialCoins,
        totalEarned: StorageService.getTotalEarned() ?? EconomyConstants.initialCoins,
        dailyEarned: StorageService.getDailyEarned() ?? 0,
        lastLoginDate: lastLoginDate,
        loginStreak: StorageService.getLoginStreak() ?? 0,
      );
    } catch (_) {
      return EconomyState.initial();
    }
  }

  void _saveState() {
    try {
      StorageService.setAfroCoins(state.afroCoins);
      StorageService.setTotalEarned(state.totalEarned);
      StorageService.setDailyEarned(state.dailyEarned);
      StorageService.setLastLoginDate(state.lastLoginDate?.toIso8601String());
      StorageService.setLoginStreak(state.loginStreak);
    } catch (_) {
      // StorageService not initialized (e.g., in tests) — skip saving
    }
  }

  /// 增加金币（受每日上限限制）
  ///
  /// 返回是否成功添加（如果已达每日上限则返回 false）
  bool addCoins(int amount) {
    if (amount <= 0) return false;

    final remaining = EconomyConstants.dailyEarningLimit - state.dailyEarned;
    if (remaining <= 0) return false;

    final actualAmount = amount > remaining ? remaining : amount;
    state = state.copyWith(
      afroCoins: state.afroCoins + actualAmount,
      totalEarned: state.totalEarned + actualAmount,
      dailyEarned: state.dailyEarned + actualAmount,
    );
    _saveState();
    return true;
  }

  /// 消费金币
  ///
  /// 余额不足时返回 false
  bool spendCoins(int amount) {
    if (amount <= 0) return true;
    if (state.afroCoins < amount) return false;

    state = state.copyWith(afroCoins: state.afroCoins - amount);
    _saveState();
    return true;
  }

  /// 记录比赛结果奖励
  void recordWin({required int place}) {
    final reward = switch (place) {
      1 => EconomyConstants.firstPlaceReward,
      2 => EconomyConstants.secondPlaceReward,
      _ => 0,
    };
    addCoins(reward);
  }

  /// 看广告奖励
  void watchAdReward() {
    addCoins(EconomyConstants.adRewardAmount);
  }

  /// 每日签到
  ///
  /// 返回实际获得的奖励金额（0 表示今天已签到）
  int dailyCheckIn(DateTime today) {
    final dateOnly = DateTime(today.year, today.month, today.day);

    // 检查今天是否已签到
    if (state.lastLoginDate != null) {
      final lastDate = DateTime(
        state.lastLoginDate!.year,
        state.lastLoginDate!.month,
        state.lastLoginDate!.day,
      );
      if (lastDate.isAtSameMomentAs(dateOnly)) {
        return 0; // 今天已签到
      }

      // 检查是否连续签到
      final yesterday = dateOnly.subtract(const Duration(days: 1));
      final isConsecutive = lastDate.isAtSameMomentAs(yesterday);
      final newStreak = isConsecutive ? state.loginStreak + 1 : 1;

      // 计算奖励：基础 + 连续奖励递增（每天 +10，上限 100）
      final streakBonus = (newStreak - 1) * 10;
      final reward = EconomyConstants.dailyCheckInBase +
          (streakBonus > 50 ? 50 : streakBonus);

      addCoins(reward);
      state = state.copyWith(
        lastLoginDate: dateOnly,
        loginStreak: newStreak,
      );
      _saveState();
      return reward;
    }

    // 首次签到
    final reward = EconomyConstants.dailyCheckInBase;
    addCoins(reward);
    state = state.copyWith(
      lastLoginDate: dateOnly,
      loginStreak: 1,
    );
    _saveState();
    return reward;
  }

  /// 重置每日收益计数（新的一天调用）
  void resetDailyEarned() {
    state = state.copyWith(dailyEarned: 0);
    _saveState();
  }
}

/// EconomyNotifier Provider
final economyNotifierProvider =
    StateNotifierProvider<EconomyNotifier, EconomyState>((ref) {
  return EconomyNotifier();
});
