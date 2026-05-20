import '../../models/piece.dart';
import 'board.dart';

/// 移动结果
class MoveResult {
  final int position;
  final PieceStatus status;

  const MoveResult({
    required this.position,
    required this.status,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MoveResult &&
          runtimeType == other.runtimeType &&
          position == other.position &&
          status == other.status;

  @override
  int get hashCode => Object.hash(position, status);

  @override
  String toString() => 'MoveResult(position: $position, status: $status)';
}

/// 移动规则
class MoveRules {
  MoveRules._();

  /// 判断棋子是否能移动
  static bool canMove(Piece piece, int diceValue) {
    if (piece.status == PieceStatus.base) {
      return diceValue == 6;
    }

    if (piece.status == PieceStatus.homeTrack) {
      return piece.position + diceValue <= 5;
    }

    if (piece.status == PieceStatus.home) {
      return false;
    }

    // track 状态：总是可以移动（调用者负责检查是否有可移动棋子）
    return true;
  }

  /// 计算移动后的新位置和新状态
  static MoveResult calculateNewPosition(Piece piece, int diceValue) {
    // 从基地出棋
    if (piece.status == PieceStatus.base && diceValue == 6) {
      final startPos = Board.getPlayerStart(piece.playerId);
      return MoveResult(position: startPos, status: PieceStatus.track);
    }

    // 在轨道上移动
    if (piece.status == PieceStatus.track) {
      final rawNewPos = piece.position + diceValue;
      final homeEntry = Board.getPlayerHomeEntry(piece.playerId);

      // 先判断是否进入 home track（绕圈前判断）
      // 关键：rawNewPos 必须严格大于 homeEntry，且 homeTrackPos = rawNewPos - homeEntry - 1
      // 因为进入 home track 本身需要消耗 1 步
      if (piece.position <= homeEntry && rawNewPos > homeEntry) {
        final homeTrackPos = rawNewPos - homeEntry - 1;
        if (homeTrackPos >= 0 && homeTrackPos <= 4) {
          return MoveResult(
            position: homeTrackPos,
            status: PieceStatus.homeTrack,
          );
        }
        // 超出 home track，但 canMove 应该已过滤此情况
      }

      // 正常轨道移动（绕圈）
      int newPos = rawNewPos;
      if (newPos >= 52) {
        newPos -= 52;
      }
      return MoveResult(position: newPos, status: PieceStatus.track);
    }

    // 在 home track 上移动
    if (piece.status == PieceStatus.homeTrack) {
      final newPos = piece.position + diceValue;
      if (newPos == 5) {
        return MoveResult(position: 5, status: PieceStatus.home);
      }
      return MoveResult(
        position: newPos,
        status: PieceStatus.homeTrack,
      );
    }

    // 已到家的棋子不应调用此方法
    throw StateError(
      'Cannot move piece that is already home: ${piece.toString()}',
    );
  }
}
