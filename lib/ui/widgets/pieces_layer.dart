import 'package:flutter/material.dart';
import '../../models/game_state.dart';
import '../../models/piece.dart';
import '../../models/player.dart';
import 'board_layout.dart';

/// 棋子渲染层
///
/// 在 LudoBoard 上方显示所有玩家的棋子。
/// 根据 GameState 中每个 piece 的 status/position 计算棋盘坐标。
class PiecesLayer extends StatelessWidget {
  final double boardSize;
  final List<Player> players;
  final int currentPlayerIndex;
  final GamePhase phase;
  final void Function(Piece piece)? onPieceTap;
  final List<Piece> movablePieces;

  const PiecesLayer({
    super.key,
    required this.boardSize,
    required this.players,
    required this.currentPlayerIndex,
    required this.phase,
    this.onPieceTap,
    this.movablePieces = const [],
  });

  double get cellSize => boardSize / 15;

  @override
  Widget build(BuildContext context) {
    final pieces = <Widget>[];

    for (final player in players) {
      for (final piece in player.pieces) {
        final (row, col) = BoardLayout.getGridPosition(
          playerId: player.id,
          pieceId: piece.id,
          position: piece.position,
          status: piece.status,
        );

        final left = col * cellSize;
        final top = row * cellSize;
        final isMovable = movablePieces.any(
          (p) => p.playerId == piece.playerId && p.id == piece.id,
        );
        final isCurrentPlayer = player.id == currentPlayerIndex;

        pieces.add(
          AnimatedPositioned(
            key: ValueKey('piece_${player.id}_${piece.id}'),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            left: left,
            top: top,
            width: cellSize,
            height: cellSize,
            child: _PieceWidget(
              piece: piece,
              playerColor: Color(player.color),
              cellSize: cellSize,
              isMovable: isMovable && isCurrentPlayer,
              isHighlighted: isMovable && isCurrentPlayer && phase == GamePhase.selecting,
              onTap: onPieceTap,
            ),
          ),
        );
      }
    }

    return Stack(children: pieces);
  }
}

/// 单个棋子 Widget
class _PieceWidget extends StatelessWidget {
  final Piece piece;
  final Color playerColor;
  final double cellSize;
  final bool isMovable;
  final bool isHighlighted;
  final void Function(Piece piece)? onTap;

  const _PieceWidget({
    required this.piece,
    required this.playerColor,
    required this.cellSize,
    required this.isMovable,
    required this.isHighlighted,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final canTap = isMovable && onTap != null;

    return GestureDetector(
      onTap: canTap ? () => onTap!(piece) : null,
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: isHighlighted ? cellSize * 0.9 : cellSize * 0.75,
          height: isHighlighted ? cellSize * 0.9 : cellSize * 0.75,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: playerColor,
            border: isHighlighted
                ? Border.all(color: Colors.white, width: 3)
                : Border.all(color: Colors.black.withValues(alpha: 0.3), width: 1),
            boxShadow: isHighlighted
                ? [
                    BoxShadow(
                      color: playerColor.withValues(alpha: 0.6),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 2,
                      offset: const Offset(1, 1),
                    ),
                  ],
          ),
          child: Center(
            child: Text(
              '${piece.id + 1}',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 2,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
