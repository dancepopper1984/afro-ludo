import 'package:flutter_test/flutter_test.dart';
import 'package:afro_ludo_flutter/models/game_state.dart';
import 'package:afro_ludo_flutter/models/piece.dart';
import 'package:afro_ludo_flutter/models/player.dart';
import 'package:afro_ludo_flutter/ui/notifiers/game_notifier.dart';

void main() {
  group('GameNotifier.startGame', () {
    test('initializes game with 4 players', () {
      final notifier = GameNotifier();
      final players = [
        Player.withPieces(id: 0, name: 'Red', color: 0xFFE53935, type: PlayerType.human),
        Player.withPieces(id: 1, name: 'Green', color: 0xFF43A047, type: PlayerType.ai),
        Player.withPieces(id: 2, name: 'Yellow', color: 0xFFFDD835, type: PlayerType.ai),
        Player.withPieces(id: 3, name: 'Blue', color: 0xFF1E88E5, type: PlayerType.ai),
      ];

      notifier.startGame(players);

      expect(notifier.state.players.length, 4);
      expect(notifier.state.currentPlayerIndex, 0);
      expect(notifier.state.phase, GamePhase.rolling);
      expect(notifier.state.diceValue, 0);
      expect(notifier.state.consecutiveSixesCount, 0);
    });
  });

  group('GameNotifier.setDiceValue', () {
    test('sets dice value and changes phase to selecting', () {
      final notifier = _createNotifierWithGame();

      notifier.setDiceValue(4);

      expect(notifier.state.diceValue, 4);
      expect(notifier.state.phase, GamePhase.selecting);
    });
  });

  group('GameNotifier.getMovablePieces', () {
    test('returns base pieces when dice is 6', () {
      final notifier = _createNotifierWithGame();
      notifier.setDiceValue(6);

      final movable = notifier.getMovablePieces();

      expect(movable.length, 4); // all 4 pieces can exit base
    });

    test('returns empty when dice is not 6 and all pieces in base', () {
      final notifier = _createNotifierWithGame();
      notifier.setDiceValue(3);

      final movable = notifier.getMovablePieces();

      expect(movable.isEmpty, true);
    });

    test('returns track pieces that can move', () {
      final notifier = _createNotifierWithTrackPiece();
      notifier.setDiceValue(3);

      final movable = notifier.getMovablePieces();

      expect(movable.length, 1);
      expect(movable.first.status, PieceStatus.track);
    });
  });

  group('GameNotifier.movePiece', () {
    test('base piece exits to track with dice 6', () {
      final notifier = _createNotifierWithGame();
      notifier.setDiceValue(6);

      final piece = notifier.state.currentPlayer.pieces.first;
      notifier.movePiece(piece);

      final updatedPiece = notifier.state.currentPlayer.pieces.first;
      expect(updatedPiece.status, PieceStatus.track);
      expect(updatedPiece.position, 0); // Red start position
    });

    test('capture sends enemy piece back to base', () {
      final notifier = _createNotifierForCapture();
      notifier.setDiceValue(3);

      // Red piece at 10 moves to 13 where Green enemy is
      final redPiece = notifier.state.players[0].pieces.first;
      notifier.movePiece(redPiece);

      // Green piece should be back in base
      final greenPiece = notifier.state.players[1].pieces.first;
      expect(greenPiece.status, PieceStatus.base);
      expect(greenPiece.position, -1);
    });

    test('rolling 6 gives extra turn', () {
      final notifier = _createNotifierWithTrackPiece();
      notifier.setDiceValue(6);

      final piece = notifier.state.currentPlayer.pieces.first;
      notifier.movePiece(piece);

      expect(notifier.state.currentPlayerIndex, 0); // still Red's turn
      expect(notifier.state.consecutiveSixesCount, 1);
      expect(notifier.state.phase, GamePhase.rolling);
    });

    test('third consecutive 6 switches player', () {
      final notifier = _createNotifierWithTrackPiece();
      // Simulate two consecutive sixes already
      notifier.state = notifier.state.copyWith(consecutiveSixesCount: 2);
      notifier.setDiceValue(6);

      final piece = notifier.state.currentPlayer.pieces.first;
      notifier.movePiece(piece);

      expect(notifier.state.currentPlayerIndex, 1); // switched to Green
      expect(notifier.state.consecutiveSixesCount, 0);
    });

    test('non-six switches to next player', () {
      final notifier = _createNotifierWithTrackPiece();
      notifier.setDiceValue(3);

      final piece = notifier.state.currentPlayer.pieces.first;
      notifier.movePiece(piece);

      expect(notifier.state.currentPlayerIndex, 1); // Green's turn
      expect(notifier.state.consecutiveSixesCount, 0);
    });

    test('all pieces home ends game', () {
      final notifier = _createNotifierNearWin();
      notifier.setDiceValue(2);

      // Move last piece to home
      final piece = notifier.state.currentPlayer.pieces
          .firstWhere((p) => p.status == PieceStatus.homeTrack && p.position == 3);
      notifier.movePiece(piece);

      expect(notifier.state.phase, GamePhase.gameOver);
    });
  });
}

// === Helpers ===

GameNotifier _createNotifierWithGame() {
  final notifier = GameNotifier();
  notifier.startGame([
    Player.withPieces(id: 0, name: 'Red', color: 0xFFE53935, type: PlayerType.human),
    Player.withPieces(id: 1, name: 'Green', color: 0xFF43A047, type: PlayerType.ai),
    Player.withPieces(id: 2, name: 'Yellow', color: 0xFFFDD835, type: PlayerType.ai),
    Player.withPieces(id: 3, name: 'Blue', color: 0xFF1E88E5, type: PlayerType.ai),
  ]);
  return notifier;
}

GameNotifier _createNotifierWithTrackPiece() {
  final notifier = GameNotifier();
  final redPiece = Piece(id: 0, playerId: 0, status: PieceStatus.track, position: 10);
  notifier.startGame([
    Player(
      id: 0, name: 'Red', color: 0xFFE53935,
      type: PlayerType.human,
      pieces: [redPiece, ...List.generate(3, (i) => Piece.initial(id: i + 1, playerId: 0))],
    ),
    Player.withPieces(id: 1, name: 'Green', color: 0xFF43A047, type: PlayerType.ai),
    Player.withPieces(id: 2, name: 'Yellow', color: 0xFFFDD835, type: PlayerType.ai),
    Player.withPieces(id: 3, name: 'Blue', color: 0xFF1E88E5, type: PlayerType.ai),
  ]);
  return notifier;
}

GameNotifier _createNotifierForCapture() {
  final notifier = GameNotifier();
  final redPiece = Piece(id: 0, playerId: 0, status: PieceStatus.track, position: 11);
  final greenPiece = Piece(id: 0, playerId: 1, status: PieceStatus.track, position: 14);
  notifier.startGame([
    Player(
      id: 0, name: 'Red', color: 0xFFE53935,
      type: PlayerType.human,
      pieces: [redPiece, ...List.generate(3, (i) => Piece.initial(id: i + 1, playerId: 0))],
    ),
    Player(
      id: 1, name: 'Green', color: 0xFF43A047,
      type: PlayerType.ai, aiDifficulty: AIDifficulty.medium,
      pieces: [greenPiece, ...List.generate(3, (i) => Piece.initial(id: i + 1, playerId: 1))],
    ),
    Player.withPieces(id: 2, name: 'Yellow', color: 0xFFFDD835, type: PlayerType.ai),
    Player.withPieces(id: 3, name: 'Blue', color: 0xFF1E88E5, type: PlayerType.ai),
  ]);
  return notifier;
}

GameNotifier _createNotifierNearWin() {
  final notifier = GameNotifier();
  // Red has 3 pieces home, 1 on homeTrack position 3
  final pieces = [
    for (int i = 0; i < 3; i++)
      Piece(id: i, playerId: 0, status: PieceStatus.home, position: 5),
    Piece(id: 3, playerId: 0, status: PieceStatus.homeTrack, position: 3),
  ];
  notifier.startGame([
    Player(
      id: 0, name: 'Red', color: 0xFFE53935,
      type: PlayerType.human,
      pieces: pieces,
    ),
    Player.withPieces(id: 1, name: 'Green', color: 0xFF43A047, type: PlayerType.ai),
    Player.withPieces(id: 2, name: 'Yellow', color: 0xFFFDD835, type: PlayerType.ai),
    Player.withPieces(id: 3, name: 'Blue', color: 0xFF1E88E5, type: PlayerType.ai),
  ]);
  return notifier;
}
