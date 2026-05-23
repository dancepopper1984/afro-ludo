import 'package:flutter/material.dart';
import '../../models/game_state.dart';
import '../../models/piece.dart';
import '../../models/player.dart';
import 'board_layout.dart';

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
            duration: const Duration(milliseconds: 350),
            curve: Curves.bounceOut,
            left: left,
            top: top,
            width: cellSize,
            height: cellSize,
            child: _PieceWidget(
              piece: piece,
              playerColor: Color(player.color),
              cellSize: cellSize,
              isMovable: isMovable && isCurrentPlayer,
              isHighlighted: isMovable &&
                  isCurrentPlayer &&
                  phase == GamePhase.selecting,
              onTap: onPieceTap,
            ),
          ),
        );
      }
    }

    return Stack(children: pieces);
  }
}

class _PieceWidget extends StatefulWidget {
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
  State<_PieceWidget> createState() => _PieceWidgetState();
}

class _PieceWidgetState extends State<_PieceWidget>
    with SingleTickerProviderStateMixin {
  AnimationController? _pulseController;
  Animation<double>? _pulseAnimation;

  @override
  void initState() {
    super.initState();
    if (widget.isHighlighted) {
      _startPulse();
    }
  }

  @override
  void didUpdateWidget(covariant _PieceWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isHighlighted && !oldWidget.isHighlighted) {
      _startPulse();
    } else if (!widget.isHighlighted && oldWidget.isHighlighted) {
      _stopPulse();
    }
  }

  void _startPulse() {
    _pulseController?.dispose();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _pulseController!, curve: Curves.easeInOut),
    );
  }

  void _stopPulse() {
    _pulseController?.dispose();
    _pulseController = null;
    _pulseAnimation = null;
  }

  @override
  void dispose() {
    _pulseController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canTap = widget.isMovable && widget.onTap != null;
    final baseSize = widget.cellSize * 0.72;
    final highlightSize = widget.cellSize * 0.88;

    Widget pieceWidget = GestureDetector(
      onTap: canTap ? () => widget.onTap!(widget.piece) : null,
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: widget.isHighlighted ? highlightSize : baseSize,
          height: widget.isHighlighted ? highlightSize : baseSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.playerColor,
            border: Border.all(
              color: const Color(0xFFFFD700),
              width: widget.isHighlighted ? 2.5 : 1.5,
            ),
            boxShadow: widget.isHighlighted
                ? [
                    BoxShadow(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.7),
                      blurRadius: 12,
                      spreadRadius: 3,
                    ),
                    BoxShadow(
                      color: widget.playerColor.withValues(alpha: 0.4),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 3,
                      offset: const Offset(1, 2),
                    ),
                  ],
          ),
          child: Center(
            child: Text(
              '${widget.piece.id + 1}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                shadows: [
                  Shadow(
                    color: Colors.black54,
                    blurRadius: 2,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (widget.isHighlighted && _pulseAnimation != null) {
      return AnimatedBuilder(
        animation: _pulseAnimation!,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation!.value,
            child: child,
          );
        },
        child: pieceWidget,
      );
    }

    return pieceWidget;
  }
}
