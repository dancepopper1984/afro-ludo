import 'package:flutter_test/flutter_test.dart';
import 'package:afro_ludo_flutter/game/ludo/ai_strategy.dart';
import 'package:afro_ludo_flutter/game/ludo/move_rules.dart';
import 'package:afro_ludo_flutter/models/game_state.dart';
import 'package:afro_ludo_flutter/models/piece.dart';
import 'package:afro_ludo_flutter/models/player.dart';

/// 构造测试用的 GameState
GameState _makeGameState({
  required List<Player> players,
  int currentPlayer = 0,
}) {
  return GameState(
    players: players,
    currentPlayerIndex: currentPlayer,
    diceValue: 0,
    isRolling: false,
    phase: GamePhase.selecting,
  );
}

void main() {
  group('AIStrategy.scoreMove', () {
    test('base piece with dice 6 gets exit score', () {
      final piece = Piece.initial(id: 0, playerId: 0);
      final state = _makeGameState(
        players: [
          Player.withPieces(id: 0, name: 'Red', color: 0xFFE53935, type: PlayerType.human),
        ],
      );

      final score = AIStrategy.scoreMove(piece, 6, state);
      expect(score, greaterThan(0));
    });

    test('base piece with non-6 cannot move', () {
      final piece = Piece.initial(id: 0, playerId: 0);
      final state = _makeGameState(
        players: [
          Player.withPieces(id: 0, name: 'Red', color: 0xFFE53935, type: PlayerType.human),
        ],
      );

      final score = AIStrategy.scoreMove(piece, 5, state);
      expect(score, -1.0);
    });

    test('track piece gets base move score', () {
      final piece = Piece(id: 0, playerId: 0, status: PieceStatus.track, position: 10);
      final state = _makeGameState(
        players: [
          Player(
            id: 0, name: 'Red', color: 0xFFE53935,
            type: PlayerType.human,
            pieces: [piece, ...List.generate(3, (i) => Piece.initial(id: i + 1, playerId: 0))],
          ),
        ],
      );

      final score = AIStrategy.scoreMove(piece, 3, state);
      expect(score, greaterThan(0));
    });

    test('entering home track gets bonus', () {
      // Red at 50, dice 2 -> enters home track
      final piece = Piece(id: 0, playerId: 0, status: PieceStatus.track, position: 50);
      final state = _makeGameState(
        players: [
          Player(
            id: 0, name: 'Red', color: 0xFFE53935,
            type: PlayerType.human,
            pieces: [piece, ...List.generate(3, (i) => Piece.initial(id: i + 1, playerId: 0))],
          ),
        ],
      );

      final scoreHomeTrack = AIStrategy.scoreMove(piece, 2, state);
      final scoreNormal = AIStrategy.scoreMove(
        Piece(id: 0, playerId: 0, status: PieceStatus.track, position: 10),
        2,
        state,
      );

      expect(scoreHomeTrack, greaterThan(scoreNormal));
    });

    test('reaching home gets highest score', () {
      // homeTrack 3 + 2 = home
      final piece = Piece(id: 0, playerId: 0, status: PieceStatus.homeTrack, position: 3);
      final state = _makeGameState(
        players: [
          Player(
            id: 0, name: 'Red', color: 0xFFE53935,
            type: PlayerType.human,
            pieces: [piece, ...List.generate(3, (i) => Piece.initial(id: i + 1, playerId: 0))],
          ),
        ],
      );

      final score = AIStrategy.scoreMove(piece, 2, state);
      expect(score, greaterThan(50)); // home bonus + base move
    });

    test('capture gets highest priority score', () {
      // Red at 11, Green enemy at 14 (14 is not a safe zone)
      final redPiece = Piece(id: 0, playerId: 0, status: PieceStatus.track, position: 11);
      final enemyPiece = Piece(id: 0, playerId: 1, status: PieceStatus.track, position: 14);
      final state = _makeGameState(
        players: [
          Player(
            id: 0, name: 'Red', color: 0xFFE53935,
            type: PlayerType.human,
            pieces: [redPiece, ...List.generate(3, (i) => Piece.initial(id: i + 1, playerId: 0))],
          ),
          Player(
            id: 1, name: 'Green', color: 0xFF43A047,
            type: PlayerType.ai, aiDifficulty: AIDifficulty.medium,
            pieces: [enemyPiece, ...List.generate(3, (i) => Piece.initial(id: i + 1, playerId: 1))],
          ),
        ],
      );

      final captureScore = AIStrategy.scoreMove(redPiece, 3, state);
      final noCaptureScore = AIStrategy.scoreMove(
        Piece(id: 0, playerId: 0, status: PieceStatus.track, position: 5),
        3,
        state,
      );

      expect(captureScore, greaterThan(noCaptureScore));
    });

    test('escaping danger gets bonus', () {
      // Non-safe zone track piece entering home track
      // Red at 49 + 3 = 52 > homeEntry 51 → enters home track at 0
      final piece = Piece(id: 0, playerId: 0, status: PieceStatus.track, position: 49);
      final state = _makeGameState(
        players: [
          Player(
            id: 0, name: 'Red', color: 0xFFE53935,
            type: PlayerType.human,
            pieces: [piece, ...List.generate(3, (i) => Piece.initial(id: i + 1, playerId: 0))],
          ),
        ],
      );

      final escapeScore = AIStrategy.scoreMove(piece, 3, state);
      final safeScore = AIStrategy.scoreMove(
        Piece(id: 0, playerId: 0, status: PieceStatus.track, position: 0), // safe zone
        3,
        state,
      );

      expect(escapeScore, greaterThan(safeScore));
    });
  });

  group('AIStrategy.selectEasy', () {
    test('prioritizes exiting base', () {
      final pieces = [
        Piece.initial(id: 0, playerId: 1),
        Piece(id: 1, playerId: 1, status: PieceStatus.track, position: 20),
      ];
      final state = _makeGameState(
        players: [
          Player.withPieces(id: 0, name: 'Red', color: 0xFFE53935, type: PlayerType.human),
          Player(
            id: 1, name: 'Green', color: 0xFF43A047,
            type: PlayerType.ai, aiDifficulty: AIDifficulty.easy,
            pieces: pieces,
          ),
        ],
        currentPlayer: 1,
      );

      final movable = pieces.where((p) => MoveRules.canMove(p, 6)).toList();
      final selected = AIStrategy.selectEasy(movable, 6, state);

      expect(selected.status, PieceStatus.base);
    });

    test('selects piece furthest on track', () {
      final pieces = [
        Piece(id: 0, playerId: 1, status: PieceStatus.track, position: 10),
        Piece(id: 1, playerId: 1, status: PieceStatus.track, position: 30),
      ];
      final state = _makeGameState(
        players: [
          Player.withPieces(id: 0, name: 'Red', color: 0xFFE53935, type: PlayerType.human),
          Player(
            id: 1, name: 'Green', color: 0xFF43A047,
            type: PlayerType.ai, aiDifficulty: AIDifficulty.easy,
            pieces: pieces,
          ),
        ],
        currentPlayer: 1,
      );

      final movable = pieces.where((p) => MoveRules.canMove(p, 3)).toList();
      final selected = AIStrategy.selectEasy(movable, 3, state);

      expect(selected.position, 30);
    });
  });

  group('AIStrategy.selectHard', () {
    test('selects highest scoring move', () {
      // Piece at 10 can capture enemy at 13 with dice 3
      final pieces = [
        Piece(id: 0, playerId: 1, status: PieceStatus.track, position: 10),
        Piece(id: 1, playerId: 1, status: PieceStatus.track, position: 5),
      ];
      final enemyPiece = Piece(id: 0, playerId: 0, status: PieceStatus.track, position: 13);
      final state = _makeGameState(
        players: [
          Player(
            id: 0, name: 'Red', color: 0xFFE53935,
            type: PlayerType.human,
            pieces: [enemyPiece, ...List.generate(3, (i) => Piece.initial(id: i + 1, playerId: 0))],
          ),
          Player(
            id: 1, name: 'Green', color: 0xFF43A047,
            type: PlayerType.ai, aiDifficulty: AIDifficulty.hard,
            pieces: pieces,
          ),
        ],
        currentPlayer: 1,
      );

      final movable = pieces.where((p) => MoveRules.canMove(p, 3)).toList();
      final selected = AIStrategy.selectHard(movable, 3, state);

      expect(selected.position, 10); // can capture
    });
  });
}
