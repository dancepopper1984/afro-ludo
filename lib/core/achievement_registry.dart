import '../models/achievement.dart';

/// 成就条件函数签名
///
/// 接收当前统计，返回是否满足解锁条件。
typedef AchievementCondition = bool Function(AchievementStats stats);

/// 成就统计快照
///
/// 从 [StorageService] 读取的当前玩家统计。
class AchievementStats {
  final int totalWins;
  final int totalLosses;
  final int bestStreak;
  final int currentStreak;
  final int totalEarned;

  const AchievementStats({
    this.totalWins = 0,
    this.totalLosses = 0,
    this.bestStreak = 0,
    this.currentStreak = 0,
    this.totalEarned = 0,
  });

  int get totalGames => totalWins + totalLosses;
}

/// 成就注册表
///
/// 集中定义所有成就及其解锁条件。
class AchievementRegistry {
  const AchievementRegistry._();

  static const Achievement firstWin = Achievement(
    id: 'first_win',
    name: 'First Victory',
    description: 'Win your first game of Ludo.',
    iconName: 'emoji_events',
    coinReward: 50,
  );

  static const Achievement streak3 = Achievement(
    id: 'streak_3',
    name: 'On Fire',
    description: 'Win 3 games in a row.',
    iconName: 'local_fire_department',
    coinReward: 100,
  );

  static const Achievement streak5 = Achievement(
    id: 'streak_5',
    name: 'Unstoppable',
    description: 'Win 5 games in a row.',
    iconName: 'whatshot',
    coinReward: 250,
  );

  static const Achievement winner10 = Achievement(
    id: 'winner_10',
    name: 'Champion',
    description: 'Win 10 games total.',
    iconName: 'military_tech',
    coinReward: 100,
  );

  static const Achievement veteran50 = Achievement(
    id: 'veteran_50',
    name: 'Veteran',
    description: 'Play 50 games total.',
    iconName: 'verified',
    coinReward: 200,
  );

  static const Achievement rich1000 = Achievement(
    id: 'rich_1000',
    name: 'Wealthy',
    description: 'Earn 1,000 AfroCoins total.',
    iconName: 'account_balance',
    coinReward: 0,
  );

  /// 所有成就列表
  static const List<Achievement> all = [
    firstWin,
    streak3,
    streak5,
    winner10,
    veteran50,
    rich1000,
  ];

  /// 成就条件映射
  static final Map<String, AchievementCondition> conditions = {
    firstWin.id: (s) => s.totalWins >= 1,
    streak3.id: (s) => s.bestStreak >= 3,
    streak5.id: (s) => s.bestStreak >= 5,
    winner10.id: (s) => s.totalWins >= 10,
    veteran50.id: (s) => s.totalGames >= 50,
    rich1000.id: (s) => s.totalEarned >= 1000,
  };

  static Achievement? byId(String id) {
    for (final a in all) {
      if (a.id == id) return a;
    }
    return null;
  }
}
