/// 棋子状态
enum PieceStatus {
  /// 在基地中，未出发
  base,

  /// 在外圈轨道上
  track,

  /// 在 home track 上
  homeTrack,

  /// 已到家
  home,
}

/// 棋子模型
///
/// position 约定：
/// - `-1` = 基地（base）
/// - `0-51` = 外圈轨道（track）
/// - `0-4` = home track（进入 home track 后单独计数）
/// - `5` = 到家（home）
class Piece {
  final int id;           // 每玩家 0-3
  final int playerId;     // 0-3
  final PieceStatus status;
  final int position;

  const Piece({
    required this.id,
    required this.playerId,
    required this.status,
    required this.position,
  });

  /// 创建初始状态（在基地中）
  factory Piece.initial({required int id, required int playerId}) {
    return Piece(
      id: id,
      playerId: playerId,
      status: PieceStatus.base,
      position: -1,
    );
  }

  Piece copyWith({
    int? id,
    int? playerId,
    PieceStatus? status,
    int? position,
  }) {
    return Piece(
      id: id ?? this.id,
      playerId: playerId ?? this.playerId,
      status: status ?? this.status,
      position: position ?? this.position,
    );
  }

  /// 是否在基地中
  bool get isInBase => status == PieceStatus.base;

  /// 是否已到家
  bool get isHome => status == PieceStatus.home;

  /// 是否在轨道上（外圈或 home track）
  bool get isOnTrack => status == PieceStatus.track || status == PieceStatus.homeTrack;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Piece &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          playerId == other.playerId &&
          status == other.status &&
          position == other.position;

  @override
  int get hashCode => Object.hash(id, playerId, status, position);

  @override
  String toString() => 'Piece(id: $id, playerId: $playerId, status: $status, position: $position)';
}
