import '../../models/piece.dart';
import '../../models/player.dart';
import 'board.dart';

/// 吃子规则
class CaptureRules {
  CaptureRules._();

  /// 检查某格是否有可被吃的敌方棋子
  ///
  /// 返回被吃的棋子，如果没有则返回 null
  static Piece? checkCapture(
    int cellIndex,
    int attackerPlayerId,
    List<Player> players,
  ) {
    // 安全区不能吃
    if (Board.isSafeZone(cellIndex)) {
      return null;
    }

    // 检查该格是否有敌方棋子
    for (final player in players) {
      if (player.id == attackerPlayerId) continue;

      for (final piece in player.pieces) {
        if (piece.status == PieceStatus.track &&
            piece.position == cellIndex) {
          return piece;
        }
      }
    }

    return null;
  }

  /// 将被吃的棋子送回基地
  static Piece returnToBase(Piece piece) {
    return piece.copyWith(
      status: PieceStatus.base,
      position: -1,
    );
  }
}
