import '../../models/player.dart';

/// 胜负判定
class WinChecker {
  WinChecker._();

  /// 玩家是否已获胜（所有棋子都到家）
  static bool hasWon(Player player) {
    return player.pieces.every((piece) => piece.isHome);
  }

  /// 获取玩家排名（按到家棋子数降序）
  static List<Player> getRanking(List<Player> players) {
    final ranked = List<Player>.from(players);
    ranked.sort((a, b) => b.homePiecesCount.compareTo(a.homePiecesCount));
    return ranked;
  }

  /// 检查是否有玩家已获胜
  static Player? findWinner(List<Player> players) {
    for (final player in players) {
      if (hasWon(player)) {
        return player;
      }
    }
    return null;
  }
}
