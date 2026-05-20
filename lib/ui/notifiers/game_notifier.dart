import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../game/ludo/ai_strategy.dart';
import '../../game/ludo/capture_rules.dart';
import '../../game/ludo/move_rules.dart';
import '../../game/ludo/win_checker.dart';
import '../../models/game_state.dart';
import '../../models/piece.dart';
import '../../models/player.dart';

/// 游戏状态管理器
///
/// 管理完整的 Ludo 游戏流程：
/// 1. 开始游戏 → 初始化玩家
/// 2. 掷骰子 → 设置 diceValue
/// 3. 选择棋子 → 移动、吃子检查、胜负判定
/// 4. 回合切换 → 处理连掷 6 的逻辑
///
/// 使用 Riverpod StateNotifier，UI 层通过 watch/listen 响应状态变化。
class GameNotifier extends StateNotifier<GameState> {
  GameNotifier() : super(GameState.initial());

  /// 开始新游戏
  void startGame(List<Player> players) {
    state = GameState(
      players: players,
      currentPlayerIndex: 0,
      diceValue: 0,
      isRolling: false,
      phase: GamePhase.rolling,
    );
  }

  /// 设置骰子值（UI 动画结束后调用）
  void setDiceValue(int value) {
    state = state.copyWith(
      diceValue: value,
      phase: GamePhase.selecting,
    );
  }

  /// 获取当前玩家可移动的棋子
  List<Piece> getMovablePieces() {
    final player = state.currentPlayer;
    return player.pieces
        .where((p) => MoveRules.canMove(p, state.diceValue))
        .toList();
  }

  /// 移动指定棋子
  ///
  /// 自动处理：位置更新 → 吃子检查 → 胜负判定 → 回合切换
  void movePiece(Piece piece) {
    final diceValue = state.diceValue;
    final result = MoveRules.calculateNewPosition(piece, diceValue);

    // 更新移动后的棋子
    final movedPiece = piece.copyWith(
      position: result.position,
      status: result.status,
    );
    var players = _updatePieceInPlayers(state.players, movedPiece);

    // 检查吃子（仅 track 状态可能吃子）
    if (result.status == PieceStatus.track) {
      final captured = CaptureRules.checkCapture(
        result.position,
        piece.playerId,
        players,
      );
      if (captured != null) {
        final returned = CaptureRules.returnToBase(captured);
        players = _updatePieceInPlayers(players, returned);
      }
    }

    // 检查当前玩家是否获胜
    final currentPlayer = players[state.currentPlayerIndex];
    if (WinChecker.hasWon(currentPlayer)) {
      state = state.copyWith(players: players, phase: GamePhase.gameOver);
      return;
    }

    // 判断下一回合
    if (diceValue == 6 && state.consecutiveSixesCount < 2) {
      // 掷出 6，继续当前玩家回合（最多连续 3 次）
      state = state.copyWith(
        players: players,
        consecutiveSixesCount: state.consecutiveSixesCount + 1,
        diceValue: 0,
        phase: GamePhase.rolling,
      );
    } else {
      // 切换到下一位玩家
      final nextIndex = (state.currentPlayerIndex + 1) % players.length;
      state = state.copyWith(
        players: players,
        currentPlayerIndex: nextIndex,
        consecutiveSixesCount: 0,
        diceValue: 0,
        phase: GamePhase.rolling,
      );
    }
  }

  /// 跳过当前玩家回合（无可移动棋子时）
  void skipTurn() {
    final nextIndex = (state.currentPlayerIndex + 1) % state.players.length;
    state = state.copyWith(
      currentPlayerIndex: nextIndex,
      consecutiveSixesCount: 0,
      diceValue: 0,
      phase: GamePhase.rolling,
    );
  }

  /// AI 自动选择并移动棋子
  ///
  /// 返回选中的棋子（供 UI 做动画）
  Piece? executeAiMove() {
    final player = state.currentPlayer;
    if (player.type != PlayerType.ai) return null;

    final movable = getMovablePieces();
    if (movable.isEmpty) return null;

    final difficulty = player.aiDifficulty ?? AIDifficulty.medium;
    final selected = switch (difficulty) {
      AIDifficulty.easy => AIStrategy.selectEasy(movable, state.diceValue, state),
      AIDifficulty.medium => AIStrategy.selectMedium(movable, state.diceValue, state),
      AIDifficulty.hard => AIStrategy.selectHard(movable, state.diceValue, state),
    };

    movePiece(selected);
    return selected;
  }

  /// 更新玩家列表中的指定棋子
  List<Player> _updatePieceInPlayers(List<Player> players, Piece piece) {
    final newPlayers = List<Player>.from(players);
    final playerIndex = newPlayers.indexWhere((p) => p.id == piece.playerId);
    if (playerIndex == -1) return players;

    final player = newPlayers[playerIndex];
    final newPieces = List<Piece>.from(player.pieces);
    final pieceIndex = newPieces.indexWhere((p) => p.id == piece.id);
    if (pieceIndex != -1) {
      newPieces[pieceIndex] = piece;
    }
    newPlayers[playerIndex] = player.copyWith(pieces: newPieces);
    return newPlayers;
  }
}

/// GameNotifier Provider
final gameNotifierProvider = StateNotifierProvider<GameNotifier, GameState>((ref) {
  return GameNotifier();
});
