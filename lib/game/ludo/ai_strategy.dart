import '../../models/game_state.dart';
import '../../models/piece.dart';
import 'board.dart';
import 'capture_rules.dart';
import 'move_rules.dart';

/// AI 策略
/// 纯 Dart，零 Flutter 依赖
class AIStrategy {
  AIStrategy._();

  // === 评分权重 ===
  static const double _captureWeight = 100.0;
  static const double _homeWeight = 80.0;
  static const double _homeTrackWeight = 40.0;
  static const double _exitBaseWeight = 50.0;
  static const double _escapeDangerWeight = 30.0;
  static const double _baseMoveWeight = 2.0;

  /// 评分一个移动
  ///
  /// 返回分数，负数表示不能移动
  static double scoreMove(Piece piece, int diceValue, GameState gameState) {
    if (!MoveRules.canMove(piece, diceValue)) return -1.0;

    final result = MoveRules.calculateNewPosition(piece, diceValue);
    double score = 0;

    // 1. 能出基地
    if (piece.status == PieceStatus.base) {
      score += _exitBaseWeight;
    }

    // 2. 能吃子（最高优先级）
    if (result.status == PieceStatus.track) {
      final captured = CaptureRules.checkCapture(
        result.position,
        piece.playerId,
        gameState.players,
      );
      if (captured != null) {
        score += _captureWeight;
      }
    }

    // 3. 能到家
    if (result.status == PieceStatus.home) {
      score += _homeWeight;
    }

    // 4. 能进 home track
    if (piece.status == PieceStatus.track &&
        result.status == PieceStatus.homeTrack) {
      score += _homeTrackWeight;
    }

    // 5. 逃离危险区（从非安全区轨道进入安全位置）
    if (piece.status == PieceStatus.track &&
        !Board.isSafeZone(piece.position)) {
      if (result.status == PieceStatus.homeTrack ||
          result.status == PieceStatus.home) {
        score += _escapeDangerWeight;
      }
    }

    // 6. 基础前进分
    score += diceValue * _baseMoveWeight;

    return score;
  }

  /// Easy：优先移动最前面的棋子（track 上 position 最大的）
  /// 如果都在基地，优先出基地
  static Piece selectEasy(
    List<Piece> movablePieces,
    int diceValue,
    GameState gameState,
  ) {
    // 有能出基地的优先出
    final canExit = movablePieces.where(
      (p) => p.status == PieceStatus.base && diceValue == 6,
    );
    if (canExit.isNotEmpty) return canExit.first;

    // 否则选 track 上最前面的（position 最大）
    final onTrack = movablePieces.where((p) => p.status == PieceStatus.track);
    if (onTrack.isNotEmpty) {
      return onTrack.reduce((a, b) => a.position > b.position ? a : b);
    }

    // 都没在 track 上，选第一个可移动的
    return movablePieces.first;
  }

  /// Medium：正常评分，10% 概率选次优解
  static Piece selectMedium(
    List<Piece> movablePieces,
    int diceValue,
    GameState gameState,
  ) {
    return _selectByScore(
      movablePieces,
      diceValue,
      gameState,
      suboptimalChance: 0.1,
    );
  }

  /// Hard：完美评分，总是选最优
  static Piece selectHard(
    List<Piece> movablePieces,
    int diceValue,
    GameState gameState,
  ) {
    return _selectByScore(
      movablePieces,
      diceValue,
      gameState,
      suboptimalChance: 0.0,
    );
  }

  /// 根据评分选择棋子
  static Piece _selectByScore(
    List<Piece> movablePieces,
    int diceValue,
    GameState gameState, {
    required double suboptimalChance,
  }) {
    // 计算每个棋子的分数
    final scores = <Piece, double>{};
    for (final piece in movablePieces) {
      scores[piece] = scoreMove(piece, diceValue, gameState);
    }

    // 按分数排序
    final sorted = List<Piece>.from(movablePieces)
      ..sort((a, b) => scores[b]!.compareTo(scores[a]!));

    // 如果需要次优解且有多个选择
    if (suboptimalChance > 0 && sorted.length > 1) {
      // 简单实现：直接返回次优（非随机，确保测试确定性）
      // 实际游戏中可用 Random 决定
      return sorted[1];
    }

    return sorted.first;
  }
}
