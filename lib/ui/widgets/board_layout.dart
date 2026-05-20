import '../../models/piece.dart' as models;

/// Ludo 15×15 棋盘坐标映射
///
/// 将逻辑位置（track position / home track position / base）映射到网格坐标 (row, col)
class BoardLayout {
  BoardLayout._();

  // === 外圈轨道 52 格坐标（position 0-51） ===
  // 顺时针环绕：左上 → 右上 → 右下 → 左下 → 左上
  // 与 kPlayerConfigs 对应：0=Red, 13=Green, 26=Yellow, 39=Blue
  static const List<(int, int)> trackCoordinates = [
    // 0-12: 左上区域（Red 基地附近）
    (6, 1), (6, 2), (6, 3), (6, 4), (6, 5),
    (5, 6), (4, 6), (3, 6), (2, 6), (1, 6),
    (0, 6), (0, 7), (0, 8),
    // 13-25: 右上区域（Green 基地附近）
    (1, 8), (2, 8), (3, 8), (4, 8), (5, 8),
    (6, 9), (6, 10), (6, 11), (6, 12), (6, 13),
    (6, 14), (7, 14), (8, 14),
    // 26-38: 右下区域（Blue 基地附近）
    (8, 13), (8, 12), (8, 11), (8, 10), (8, 9),
    (9, 8), (10, 8), (11, 8), (12, 8), (13, 8),
    (14, 8), (14, 7), (14, 6),
    // 39-51: 左下区域（Yellow 基地附近）
    (13, 6), (12, 6), (11, 6), (10, 6), (9, 6),
    (8, 5), (8, 4), (8, 3), (8, 2), (8, 1),
    (8, 0), (7, 0), (6, 0),
  ];

  // === Home track 坐标（position 0-4，按玩家） ===
  static const List<List<(int, int)>> homeTrackCoordinates = [
    // Player 0 (Red): 从 (6,7) 向上
    [(5, 7), (4, 7), (3, 7), (2, 7), (1, 7)],
    // Player 1 (Green): 从 (7,8) 向右
    [(7, 9), (7, 10), (7, 11), (7, 12), (7, 13)],
    // Player 2 (Yellow): 从 (7,6) 向左
    [(7, 5), (7, 4), (7, 3), (7, 2), (7, 1)],
    // Player 3 (Blue): 从 (8,7) 向下
    [(9, 7), (10, 7), (11, 7), (12, 7), (13, 7)],
  ];

  // === 基地内棋子坐标（4 个停车位） ===
  static const List<List<(int, int)>> baseCoordinates = [
    // Player 0 (Red): 左上基地 行0-5,列0-5
    [(1, 1), (1, 4), (4, 1), (4, 4)],
    // Player 1 (Green): 右上基地 行0-5,列9-14
    [(1, 10), (1, 13), (4, 10), (4, 13)],
    // Player 2 (Yellow): 左下基地 行9-14,列0-5
    [(10, 1), (10, 4), (13, 1), (13, 4)],
    // Player 3 (Blue): 右下基地 行9-14,列9-14
    [(10, 10), (10, 13), (13, 10), (13, 13)],
  ];

  // === Home 中心坐标（每个玩家一个角落） ===
  static const List<(int, int)> homeCoordinates = [
    (6, 6), // Red
    (6, 8), // Green
    (8, 6), // Yellow
    (8, 8), // Blue
  ];

  /// 获取棋子在棋盘上的网格坐标
  /// 返回 (row, col)
  static (int, int) getGridPosition({
    required int playerId,
    required int pieceId,
    required int position,
    required models.PieceStatus status,
  }) {
    switch (status) {
      case models.PieceStatus.base:
        return baseCoordinates[playerId][pieceId];
      case models.PieceStatus.track:
        return trackCoordinates[position];
      case models.PieceStatus.homeTrack:
        return homeTrackCoordinates[playerId][position];
      case models.PieceStatus.home:
        return homeCoordinates[playerId];
    }
  }
}
