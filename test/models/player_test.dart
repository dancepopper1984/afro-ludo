import 'package:flutter_test/flutter_test.dart';
import 'package:afro_ludo_flutter/models/player.dart';
import 'package:afro_ludo_flutter/models/piece.dart';

void main() {
  group('Player', () {
    test('player with pieces creates 4 pieces in base', () {
      final player = Player.withPieces(
        id: 0,
        name: 'Red',
        color: 0xFFE53935,
        type: PlayerType.human,
      );

      expect(player.id, 0);
      expect(player.name, 'Red');
      expect(player.pieces.length, 4);
      expect(player.pieces.every((p) => p.isInBase), true);
      expect(player.homePiecesCount, 0);
      expect(player.hasWon, false);
    });

    test('ai player has difficulty', () {
      final player = Player.withPieces(
        id: 1,
        name: 'Green',
        color: 0xFF43A047,
        type: PlayerType.ai,
        aiDifficulty: AIDifficulty.hard,
      );

      expect(player.type, PlayerType.ai);
      expect(player.aiDifficulty, AIDifficulty.hard);
    });

    test('homePiecesCount counts only home pieces', () {
      final pieces = [
        Piece(id: 0, playerId: 0, status: PieceStatus.home, position: 5),
        Piece(id: 1, playerId: 0, status: PieceStatus.home, position: 5),
        Piece(id: 2, playerId: 0, status: PieceStatus.track, position: 10),
        Piece(id: 3, playerId: 0, status: PieceStatus.base, position: -1),
      ];
      final player = Player(
        id: 0,
        name: 'Red',
        color: 0xFFE53935,
        type: PlayerType.human,
        pieces: pieces,
      );

      expect(player.homePiecesCount, 2);
      expect(player.hasWon, false);
    });

    test('hasWon when all pieces are home', () {
      final pieces = [
        for (int i = 0; i < 4; i++)
          Piece(id: i, playerId: 0, status: PieceStatus.home, position: 5),
      ];
      final player = Player(
        id: 0,
        name: 'Red',
        color: 0xFFE53935,
        type: PlayerType.human,
        pieces: pieces,
      );

      expect(player.hasWon, true);
      expect(player.homePiecesCount, 4);
    });

    test('copyWith changes only specified field', () {
      final player = Player.withPieces(
        id: 0,
        name: 'Red',
        color: 0xFFE53935,
        type: PlayerType.human,
      );
      final updated = player.copyWith(name: 'Blue');

      expect(updated.id, player.id);
      expect(updated.name, 'Blue');
      expect(updated.color, player.color);
    });

    test('two identical players are equal', () {
      final a = Player.withPieces(
        id: 0,
        name: 'Red',
        color: 0xFFE53935,
        type: PlayerType.human,
      );
      final b = Player.withPieces(
        id: 0,
        name: 'Red',
        color: 0xFFE53935,
        type: PlayerType.human,
      );

      expect(a, b);
    });

    test('players with different pieces are not equal', () {
      final a = Player.withPieces(
        id: 0,
        name: 'Red',
        color: 0xFFE53935,
        type: PlayerType.human,
      );
      final pieces = [
        Piece(id: 0, playerId: 0, status: PieceStatus.track, position: 10),
        ...a.pieces.sublist(1),
      ];
      final b = a.copyWith(pieces: pieces);

      expect(a, isNot(b));
    });
  });
}
