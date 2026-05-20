// Afro Ludo 游戏常量
// 纯 Dart，零 Flutter 依赖

/// 外圈轨道长度（标准 Ludo）
const int kTrackLength = 52;

/// 每个玩家的 home track 长度
const int kHomeTrackLength = 5;

/// 每个玩家的棋子数量
const int kPiecesPerPlayer = 4;

/// 玩家数量
const int kPlayerCount = 4;

/// 掷出 6 才能出基地
const int kExitBaseDiceValue = 6;

/// 连续掷出 6 的最大次数（第 3 次 6 不奖励再掷）
const int kMaxConsecutiveSixes = 3;

/// 安全区位置（星标格子，共 8 个）
const List<int> kSafeZones = [0, 8, 13, 21, 26, 34, 39, 47];

/// 玩家配置
class PlayerConfig {
  final int id;
  final String name;
  final int startPosition;  // 基地出口在轨道上的位置
  final int homeEntry;      // 进入 home track 的轨道位置

  const PlayerConfig({
    required this.id,
    required this.name,
    required this.startPosition,
    required this.homeEntry,
  });
}

/// 4 玩家配置（Red, Green, Yellow, Blue）
///
/// 玩家 0 (Red):    起点 = 0,   home entry = 51
/// 玩家 1 (Green):  起点 = 13,  home entry = 12
/// 玩家 2 (Yellow): 起点 = 26,  home entry = 25
/// 玩家 3 (Blue):   起点 = 39,  home entry = 38
const List<PlayerConfig> kPlayerConfigs = [
  PlayerConfig(id: 0, name: 'Red', startPosition: 0, homeEntry: 51),
  PlayerConfig(id: 1, name: 'Green', startPosition: 13, homeEntry: 12),
  PlayerConfig(id: 2, name: 'Yellow', startPosition: 26, homeEntry: 25),
  PlayerConfig(id: 3, name: 'Blue', startPosition: 39, homeEntry: 38),
];

/// 经济系统常量
class EconomyConstants {
  EconomyConstants._();

  static const int initialCoins = 300;
  static const int dailyEarningLimit = 1000;
  static const int firstPlaceReward = 100;
  static const int secondPlaceReward = 80;
  static const int adRewardAmount = 50;
  static const int firstWinBonus = 50;
  static const int dailyCheckInBase = 50;
}

/// 棋盘视觉配置（15×15 网格）
class BoardVisualConfig {
  BoardVisualConfig._();

  static const int gridSize = 15;
  static const int cellCount = gridSize * gridSize;
}
