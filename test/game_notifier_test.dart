import 'package:flutter_test/flutter_test.dart';
import 'package:afro_ludo_flutter/models/game_state.dart';
import 'package:afro_ludo_flutter/models/piece.dart';
import 'package:afro_ludo_flutter/models/player.dart';
import 'package:afro_ludo_flutter/ui/notifiers/game_notifier.dart';

void main() {
  group('GameNotifier Core Logic', () {
    late GameNotifier notifier;

    setUp(() {
      notifier = GameNotifier();
    });

    List<Player> _createPlayers({int humanId = 0}) {
      const names = ['Red', 'Green', 'Yellow', 'Blue'];
      const colors = [0xFFE53935, 0xFF43A047, 0xFFFDD835, 0xFF1E88E5];
      return [
        for (int i = 0; i < 4; i++)
          Player.withPieces(
            id: i,
            name: names[i],
            color: colors[i],
            type: i == humanId ? PlayerType.human : PlayerType.ai,
            aiDifficulty: i == humanId ? null : AIDifficulty.medium,
          ),
      ];
    }

    test('startGame initializes state correctly', () {
      final players = _createPlayers(humanId: 0);
      notifier.startGame(players);

      final state = notifier.state;
      expect(state.players.length, 4);
      expect(state.currentPlayerIndex, 0);
      expect(state.diceValue, 0);
      expect(state.phase, GamePhase.rolling);
      expect(state.consecutiveSixesCount, 0);
    });

    test('setDiceValue transitions to selecting phase', () {
      final players = _createPlayers(humanId: 0);
      notifier.startGame(players);

      notifier.setDiceValue(4);

      final state = notifier.state;
      expect(state.diceValue, 4);
      expect(state.phase, GamePhase.selecting);
    });

    test('getMovablePieces returns empty when all pieces in base and dice != 6', () {
      final players = _createPlayers(humanId: 0);
      notifier.startGame(players);
      notifier.setDiceValue(4);

      final movable = notifier.getMovablePieces();
      expect(movable, isEmpty);
    });

    test('getMovablePieces returns pieces when dice == 6 and in base', () {
      final players = _createPlayers(humanId: 0);
      notifier.startGame(players);
      notifier.setDiceValue(6);

      final movable = notifier.getMovablePieces();
      expect(movable.length, 4); // All 4 pieces can exit base
    });

    test('movePiece moves a piece from base to track when dice == 6', () {
      final players = _createPlayers(humanId: 0);
      notifier.startGame(players);
      notifier.setDiceValue(6);

      final movable = notifier.getMovablePieces();
      final piece = movable.first;
      expect(piece.status, PieceStatus.base);

      notifier.movePiece(piece);

      final state = notifier.state;
      final movedPiece = state.players[0].pieces[piece.id];
      expect(movedPiece.status, PieceStatus.track);
      expect(movedPiece.position, 0); // Red's start position
    });

    test('movePiece switches to next player when dice != 6', () {
      final players = _createPlayers(humanId: 0);
      notifier.startGame(players);

      // First, get a piece on track
      notifier.setDiceValue(6);
      final movable = notifier.getMovablePieces();
      notifier.movePiece(movable.first);

      // Now diceValue should be reset and phase = rolling
      var state = notifier.state;
      expect(state.currentPlayerIndex, 0); // Still human (rolled 6, gets another turn)
      expect(state.phase, GamePhase.rolling);

      // Human rolls a 4
      notifier.setDiceValue(4);
      final movable2 = notifier.getMovablePieces();
      expect(movable2.isNotEmpty, true);

      notifier.movePiece(movable2.first);

      // Now should switch to next player (AI Green, id=1)
      state = notifier.state;
      expect(state.currentPlayerIndex, 1);
      expect(state.diceValue, 0);
      expect(state.phase, GamePhase.rolling);
    });

    test('skipTurn advances to next player', () {
      final players = _createPlayers(humanId: 0);
      notifier.startGame(players);

      notifier.skipTurn();

      final state = notifier.state;
      expect(state.currentPlayerIndex, 1); // Moved to Green
      expect(state.phase, GamePhase.rolling);
      expect(state.diceValue, 0);
    });

    test('AI turn: executeAiMove returns null when dice != 6 (all in base)', () {
      final players = _createPlayers(humanId: 2); // Human is Yellow (id=2), AI Red goes first
      notifier.startGame(players);
      notifier.setDiceValue(3); // AI rolls 3, cannot exit base

      final result = notifier.executeAiMove();
      expect(result, isNull); // No movable pieces
    });

    test('AI turn: executeAiMove moves piece when dice == 6', () {
      final players = _createPlayers(humanId: 2);
      notifier.startGame(players);
      notifier.setDiceValue(6);

      final result = notifier.executeAiMove();
      expect(result, isNotNull);

      final state = notifier.state;
      // AI Red's first piece should now be on track
      final movedPiece = state.players[0].pieces[result!.id];
      expect(movedPiece.status, PieceStatus.track);
    });

    test('consecutive sixes limit: 3 times max', () {
      final players = _createPlayers(humanId: 0);
      notifier.startGame(players);

      // Roll 6 three times
      for (int i = 0; i < 3; i++) {
        notifier.setDiceValue(6);
        final movable = notifier.getMovablePieces();
        notifier.movePiece(movable.first);
      }

      final state = notifier.state;
      // After 3 sixes, should switch to next player
      expect(state.currentPlayerIndex, 1);
      expect(state.consecutiveSixesCount, 0);
    });

    test('game over detection: all pieces home', () {
      // Create a player with all pieces at home
      final pieces = [
        for (int i = 0; i < 4; i++)
          Piece(id: i, playerId: 0, status: PieceStatus.home, position: 5),
      ];
      final winningPlayer = Player(
        id: 0,
        name: 'Red',
        color: 0xFFE53935,
        type: PlayerType.human,
        pieces: pieces,
      );
      final otherPlayers = [
        for (int i = 1; i < 4; i++)
          Player.withPieces(id: i, name: 'P$i', color: 0xFF000000, type: PlayerType.ai),
      ];

      notifier.startGame([winningPlayer, ...otherPlayers]);
      notifier.setDiceValue(1);

      // Move any piece (though all are home, this shouldn't be called in practice)
      // Instead, verify hasWon property
      expect(winningPlayer.hasWon, true);
    });
  });

  group('Game Flow Integration', () {
    test('human -> ai -> human turn cycle', () {
      final notifier = GameNotifier();
      final players = [
        Player.withPieces(id: 0, name: 'Red', color: 0xFFE53935, type: PlayerType.human),
        Player.withPieces(id: 1, name: 'Green', color: 0xFF43A047, type: PlayerType.ai, aiDifficulty: AIDifficulty.easy),
        Player.withPieces(id: 2, name: 'Yellow', color: 0xFFFDD835, type: PlayerType.ai, aiDifficulty: AIDifficulty.easy),
        Player.withPieces(id: 3, name: 'Blue', color: 0xFF1E88E5, type: PlayerType.ai, aiDifficulty: AIDifficulty.easy),
      ];

      notifier.startGame(players);

      // === Human Turn ===
      expect(notifier.state.currentPlayerIndex, 0); // Red (human)
      expect(notifier.state.phase, GamePhase.rolling);

      notifier.setDiceValue(6);
      expect(notifier.state.phase, GamePhase.selecting);

      final humanMovable = notifier.getMovablePieces();
      expect(humanMovable.length, 4);

      notifier.movePiece(humanMovable.first);
      // Rolled 6, human gets another turn
      expect(notifier.state.currentPlayerIndex, 0);
      expect(notifier.state.phase, GamePhase.rolling);

      // Human rolls 3 this time
      notifier.setDiceValue(3);
      final humanMovable2 = notifier.getMovablePieces();
      // The piece already on track can move
      expect(humanMovable2.isNotEmpty, true);

      notifier.movePiece(humanMovable2.first);
      // Switches to AI Green
      expect(notifier.state.currentPlayerIndex, 1);
      expect(notifier.state.phase, GamePhase.rolling);

      // === AI Turn ===
      // AI rolls 6
      notifier.setDiceValue(6);
      expect(notifier.state.phase, GamePhase.selecting);

      final aiResult = notifier.executeAiMove();
      expect(aiResult, isNotNull);
      // AI rolled 6, gets another turn
      expect(notifier.state.currentPlayerIndex, 1);
      expect(notifier.state.phase, GamePhase.rolling);

      // AI rolls 2 this time
      notifier.setDiceValue(2);
      final aiResult2 = notifier.executeAiMove();
      expect(aiResult2, isNotNull);
      // Switches to next player (Yellow)
      expect(notifier.state.currentPlayerIndex, 2);
      expect(notifier.state.phase, GamePhase.rolling);
    });

    test('AI skipTurn when no valid moves', () {
      final notifier = GameNotifier();
      final players = [
        Player.withPieces(id: 0, name: 'Red', color: 0xFFE53935, type: PlayerType.human),
        Player.withPieces(id: 1, name: 'Green', color: 0xFF43A047, type: PlayerType.ai, aiDifficulty: AIDifficulty.easy),
      ];

      notifier.startGame(players);

      // Human moves
      notifier.setDiceValue(4);
      final movable = notifier.getMovablePieces();
      // All in base, dice=4, no moves
      expect(movable, isEmpty);

      notifier.skipTurn();

      // AI's turn, rolls 3
      expect(notifier.state.currentPlayerIndex, 1);
      notifier.setDiceValue(3);

      final aiMovable = notifier.getMovablePieces();
      expect(aiMovable, isEmpty); // AI also has all pieces in base

      // AI cannot move, should skip
      notifier.skipTurn();

      // Back to human
      expect(notifier.state.currentPlayerIndex, 0);
      expect(notifier.state.phase, GamePhase.rolling);
    });
  });
}
