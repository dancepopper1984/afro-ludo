import 'player.dart';

/// 游戏阶段
enum GamePhase {
  /// 菜单/设置
  menu,

  /// 选择颜色和难度
  setup,

  /// 掷骰子中
  rolling,

  /// 选择要移动的棋子
  selecting,

  /// 棋子移动中
  moving,

  /// 检查是否吃子
  checkCapture,

  /// 吃子动画播放中
  captureAnimation,

  /// 检查胜负
  checkWin,

  /// 切换玩家
  nextPlayer,

  /// 游戏结束
  gameOver,
}

/// 游戏状态
class GameState {
  final List<Player> players;
  final int currentPlayerIndex;
  final int diceValue;
  final bool isRolling;
  final GamePhase phase;

  /// 连续掷出 6 的次数（用于限制最多 3 次连掷）
  final int consecutiveSixesCount;

  const GameState({
    required this.players,
    required this.currentPlayerIndex,
    required this.diceValue,
    required this.isRolling,
    required this.phase,
    this.consecutiveSixesCount = 0,
  });

  /// 初始空状态（用于 Riverpod 初始化）
  factory GameState.initial() {
    return const GameState(
      players: [],
      currentPlayerIndex: 0,
      diceValue: 0,
      isRolling: false,
      phase: GamePhase.menu,
    );
  }

  /// 当前玩家
  Player get currentPlayer => players.isEmpty
      ? const Player(id: 0, name: 'None', color: 0xFF000000, type: PlayerType.human, pieces: [])
      : players[currentPlayerIndex];

  /// 游戏是否已结束
  bool get isGameOver => phase == GamePhase.gameOver;

  GameState copyWith({
    List<Player>? players,
    int? currentPlayerIndex,
    int? diceValue,
    bool? isRolling,
    GamePhase? phase,
    int? consecutiveSixesCount,
  }) {
    return GameState(
      players: players ?? this.players,
      currentPlayerIndex: currentPlayerIndex ?? this.currentPlayerIndex,
      diceValue: diceValue ?? this.diceValue,
      isRolling: isRolling ?? this.isRolling,
      phase: phase ?? this.phase,
      consecutiveSixesCount: consecutiveSixesCount ?? this.consecutiveSixesCount,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameState &&
          runtimeType == other.runtimeType &&
          _listEquals(players, other.players) &&
          currentPlayerIndex == other.currentPlayerIndex &&
          diceValue == other.diceValue &&
          isRolling == other.isRolling &&
          phase == other.phase &&
          consecutiveSixesCount == other.consecutiveSixesCount;

  @override
  int get hashCode => Object.hash(
        players.length,
        currentPlayerIndex,
        diceValue,
        isRolling,
        phase,
        consecutiveSixesCount,
      );

  @override
  String toString() =>
      'GameState(players: ${players.length}, current: $currentPlayerIndex, '
      'dice: $diceValue, phase: $phase)';

  static bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
