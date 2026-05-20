import '../core/achievement_registry.dart';
import '../models/achievement.dart';
import 'storage_service.dart';

/// 成就服务
///
/// 负责检查成就解锁条件、持久化解锁状态。
class AchievementService {
  AchievementService._();

  /// 从本地存储加载已解锁成就
  static List<String> getUnlockedIds() {
    final raw = StorageService.getString('unlockedAchievements');
    if (raw == null || raw.isEmpty) return [];
    return raw.split(',');
  }

  /// 保存已解锁成就
  static Future<void> setUnlockedIds(List<String> ids) async {
    await StorageService.setString('unlockedAchievements', ids.join(','));
  }

  /// 检查是否已解锁指定成就
  static bool isUnlocked(String achievementId) {
    return getUnlockedIds().contains(achievementId);
  }

  /// 解锁成就
  static Future<void> unlock(String achievementId) async {
    final unlocked = getUnlockedIds();
    if (unlocked.contains(achievementId)) return;
    unlocked.add(achievementId);
    await setUnlockedIds(unlocked);
  }

  /// 读取当前统计快照
  static AchievementStats loadStats() {
    return AchievementStats(
      totalWins: StorageService.getInt('totalWins') ?? 0,
      totalLosses: StorageService.getInt('totalLosses') ?? 0,
      bestStreak: StorageService.getInt('bestStreak') ?? 0,
      currentStreak: StorageService.getInt('currentStreak') ?? 0,
      totalEarned: StorageService.getInt('totalEarned') ?? 0,
    );
  }

  /// 检查所有成就，返回新解锁的成就列表
  static List<Achievement> checkUnlocks() {
    final stats = loadStats();
    final unlockedIds = getUnlockedIds();
    final newlyUnlocked = <Achievement>[];

    for (final entry in AchievementRegistry.conditions.entries) {
      if (unlockedIds.contains(entry.key)) continue;
      final condition = entry.value;
      if (condition(stats)) {
        final achievement = AchievementRegistry.byId(entry.key);
        if (achievement != null) {
          newlyUnlocked.add(achievement);
        }
      }
    }

    return newlyUnlocked;
  }

  /// 检查并自动解锁，返回新解锁的成就
  static Future<List<Achievement>> checkAndUnlock() async {
    final newlyUnlocked = checkUnlocks();
    for (final a in newlyUnlocked) {
      await unlock(a.id);
    }
    return newlyUnlocked;
  }

  /// 计算已解锁成就的奖励金币总和
  static int calculateRewardCoins(List<Achievement> achievements) {
    var total = 0;
    for (final a in achievements) {
      total += a.coinReward ?? 0;
    }
    return total;
  }
}
