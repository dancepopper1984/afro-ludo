import 'piece.dart';

/// 玩家类型
enum PlayerType {
  human,
  ai,
}

/// AI 难度
enum AIDifficulty {
  easy,
  medium,
  hard,
}

/// 玩家模型
class Player {
  final int id;              // 0-3
  final String name;
  final int color;           // ARGB 整数，避免 flutter 依赖
  final PlayerType type;
  final List<Piece> pieces;
  final AIDifficulty? aiDifficulty;

  const Player({
    required this.id,
    required this.name,
    required this.color,
    required this.type,
    required this.pieces,
    this.aiDifficulty,
  });

  /// 创建带初始棋子的玩家
  factory Player.withPieces({
    required int id,
    required String name,
    required int color,
    required PlayerType type,
    AIDifficulty? aiDifficulty,
  }) {
    return Player(
      id: id,
      name: name,
      color: color,
      type: type,
      pieces: List.unmodifiable([
        for (int i = 0; i < 4; i++)
          Piece.initial(id: i, playerId: id),
      ]),
      aiDifficulty: aiDifficulty,
    );
  }

  /// 已到家的棋子数
  int get homePiecesCount => pieces.where((p) => p.isHome).length;

  /// 是否所有棋子都已到家
  bool get hasWon => homePiecesCount == pieces.length;

  Player copyWith({
    int? id,
    String? name,
    int? color,
    PlayerType? type,
    List<Piece>? pieces,
    AIDifficulty? aiDifficulty,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      type: type ?? this.type,
      pieces: pieces ?? this.pieces,
      aiDifficulty: aiDifficulty ?? this.aiDifficulty,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Player &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          color == other.color &&
          type == other.type &&
          _listEquals(pieces, other.pieces) &&
          aiDifficulty == other.aiDifficulty;

  @override
  int get hashCode => Object.hash(id, name, color, type, pieces.length, aiDifficulty);

  @override
  String toString() =>
      'Player(id: $id, name: $name, type: $type, homePieces: $homePiecesCount)';

  static bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
