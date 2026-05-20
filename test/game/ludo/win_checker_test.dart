import 'package:flutter_test/flutter_test.dart';
import 'package:afro_ludo_flutter/game/ludo/win_checker.dart';
import 'package:afro_ludo_flutter/models/piece.dart';
import 'package:afro_ludo_flutter/models/player.dart';

void main() {
  group('WinChecker.hasWon', () {
    test('player with all pieces home has won', () {
      final pieces = [
        for (int i = 0; i < 4; i++)
          Piece(id: i, playerId: 0, status: PieceStatus.home, position: 5),
      ];
      final player = Player(
        id: 0, name: 'Red', color: 0xFFE53935,
        type: PlayerType.human,
        pieces: pieces,
      );

      expect(WinChecker.hasWon(player), true);
    });

    test('player with 3 home pieces has not won', () {
      final pieces = [
        Piece(id: 0, playerId: 0, status: PieceStatus.home, position: 5),
        Piece(id: 1, playerId: 0, status: PieceStatus.home, position: 5),
        Piece(id: 2, playerId: 0, status: PieceStatus.home, position: 5),
        Piece(id: 3, playerId: 0, status: PieceStatus.track, position: 10),
      ];
      final player = Player(
        id: 0, name: 'Red', color: 0xFFE53935,
        type: PlayerType.human,
        pieces: pieces,
      );

      expect(WinChecker.hasWon(player), false);
    });

    test('player with no home pieces has not won', () {
      final player = Player.withPieces(
        id: 0, name: 'Red', color: 0xFFE53935, type: PlayerType.human,
      );

      expect(WinChecker.hasWon(player), false);
    });
  });

  group('WinChecker.getRanking', () {
    test('ranks by home pieces count descending', () {
      final players = [
        Player(
          id: 0, name: 'Red', color: 0xFFE53935,
          type: PlayerType.human,
          pieces: [
            Piece(id: 0, playerId: 0, status: PieceStatus.home, position: 5),
            Piece(id: 1, playerId: 0, status: PieceStatus.home, position: 5),
            Piece(id: 2, playerId: 0, status: PieceStatus.track, position: 10),
            Piece(id: 3, playerId: 0, status: PieceStatus.base, position: -1),
          ],
        ),
        Player(
          id: 1, name: 'Green', color: 0xFF43A047,
          type: PlayerType.ai, aiDifficulty: AIDifficulty.medium,
          pieces: [
            Piece(id: 0, playerId: 1, status: PieceStatus.home, position: 5),
            Piece(id: 1, playerId: 1, status: PieceStatus.home, position: 5),
            Piece(id: 2, playerId: 1, status: PieceStatus.home, position: 5),
            Piece(id: 3, playerId: 1, status: PieceStatus.track, position: 20),
          ],
        ),
        Player(
          id: 2, name: 'Yellow', color: 0xFFFDD835,
          type: PlayerType.ai, aiDifficulty: AIDifficulty.easy,
          pieces: [
            Piece(id: 0, playerId: 2, status: PieceStatus.home, position: 5),
            Piece(id: 1, playerId: 2, status: PieceStatus.track, position: 5),
            Piece(id: 2, playerId: 2, status: PieceStatus.base, position: -1),
            Piece(id: 3, playerId: 2, status: PieceStatus.base, position: -1),
          ],
        ),
      ];

      final ranking = WinChecker.getRanking(players);

      expect(ranking[0].id, 1); // Green: 3 home
      expect(ranking[1].id, 0); // Red: 2 home
      expect(ranking[2].id, 2); // Yellow: 1 home
    });
  });

  group('WinChecker.findWinner', () {
    test('finds winner when one player has won', () {
      final pieces = [
        for (int i = 0; i < 4; i++)
          Piece(id: i, playerId: 1, status: PieceStatus.home, position: 5),
      ];
      final players = [
        Player.withPieces(id: 0, name: 'Red', color: 0xFFE53935, type: PlayerType.human),
        Player(
          id: 1, name: 'Green', color: 0xFF43A047,
          type: PlayerType.ai, aiDifficulty: AIDifficulty.medium,
          pieces: pieces,
        ),
      ];

      final winner = WinChecker.findWinner(players);
      expect(winner, isNotNull);
      expect(winner!.id, 1);
    });

    test('returns null when no winner', () {
      final players = [
        Player.withPieces(id: 0, name: 'Red', color: 0xFFE53935, type: PlayerType.human),
        Player.withPieces(id: 1, name: 'Green', color: 0xFF43A047, type: PlayerType.ai),
      ];

      final winner = WinChecker.findWinner(players);
      expect(winner, isNull);
    });
  });
}
