import '../../core/constants.dart';

/// Ludo 棋盘数据与查询
/// 纯 Dart，零 Flutter 依赖
class Board {
  Board._();

  /// 获取玩家起点位置
  static int getPlayerStart(int playerId) {
    return kPlayerConfigs[playerId].startPosition;
  }

  /// 获取玩家 home entry 位置
  static int getPlayerHomeEntry(int playerId) {
    return kPlayerConfigs[playerId].homeEntry;
  }

  /// 判断某个轨道位置是否为安全区
  static bool isSafeZone(int position) {
    return kSafeZones.contains(position);
  }

  /// 获取玩家名称
  static String getPlayerName(int playerId) {
    return kPlayerConfigs[playerId].name;
  }

  /// 计算从当前位置走若干步后的轨道位置（不处理 home entry）
  /// 仅用于简单轨道移动，进入 home track 的逻辑在 MoveRules 中处理
  static int moveOnTrack(int currentPosition, int steps) {
    int newPos = currentPosition + steps;
    if (newPos >= kTrackLength) {
      newPos -= kTrackLength;
    }
    return newPos;
  }

  /// 计算玩家从起点到 home entry 的步数
  static int stepsToHomeEntry(int playerId) {
    final start = getPlayerStart(playerId);
    final entry = getPlayerHomeEntry(playerId);
    if (entry >= start) {
      return entry - start;
    }
    // 绕圈情况
    return (kTrackLength - start) + entry;
  }
}
