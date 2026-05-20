import 'package:flutter_test/flutter_test.dart';
import 'package:afro_ludo_flutter/game/ludo/capture_rules.dart';
import 'package:afro_ludo_flutter/models/piece.dart';
import 'package:afro_ludo_flutter/models/player.dart';

void main() {
  group('CaptureRules.checkCapture', () {
    test('safe zone prevents capture', () {
      final players = [
        Player.withPieces(id: 0, name: 'Red', color: 0xFFE53935, type: PlayerType.human),
        Player.withPieces(id: 1, name: 'Green', color: 0xFF43A047, type: PlayerType.ai),
      ];
      // Position 0 is a safe zone
      final result = CaptureRules.checkCapture(0, 0, players);
      expect(result, isNull);
    });

    test('can capture enemy piece on track', () {
      final enemyPiece = Piece(id: 0, playerId: 1, status: PieceStatus.track, position: 15);
      final players = [
        Player(
          id: 0, name: 'Red', color: 0xFFE53935,
          type: PlayerType.human,
          pieces: [Piece.initial(id: 0, playerId: 0)],
        ),
        Player(
          id: 1, name: 'Green', color: 0xFF43A047,
          type: PlayerType.ai, aiDifficulty: AIDifficulty.medium,
          pieces: [enemyPiece],
        ),
      ];

      final result = CaptureRules.checkCapture(15, 0, players);
      expect(result, isNotNull);
      expect(result!.id, 0);
      expect(result.playerId, 1);
    });

    test('cannot capture own piece', () {
      final ownPiece = Piece(id: 0, playerId: 0, status: PieceStatus.track, position: 15);
      final players = [
        Player(
          id: 0, name: 'Red', color: 0xFFE53935,
          type: PlayerType.human,
          pieces: [ownPiece],
        ),
      ];

      final result = CaptureRules.checkCapture(15, 0, players);
      expect(result, isNull);
    });

    test('cannot capture piece in base', () {
      final enemyPiece = Piece.initial(id: 0, playerId: 1);
      final players = [
        Player(
          id: 0, name: 'Red', color: 0xFFE53935,
          type: PlayerType.human,
          pieces: [Piece.initial(id: 0, playerId: 0)],
        ),
        Player(
          id: 1, name: 'Green', color: 0xFF43A047,
          type: PlayerType.ai, aiDifficulty: AIDifficulty.medium,
          pieces: [enemyPiece],
        ),
      ];

      // Base piece position is -1, but we check position 15
      final result = CaptureRules.checkCapture(15, 0, players);
      expect(result, isNull);
    });

    test('cannot capture piece on homeTrack', () {
      final enemyPiece = Piece(id: 0, playerId: 1, status: PieceStatus.homeTrack, position: 2);
      final players = [
        Player(
          id: 0, name: 'Red', color: 0xFFE53935,
          type: PlayerType.human,
          pieces: [Piece.initial(id: 0, playerId: 0)],
        ),
        Player(
          id: 1, name: 'Green', color: 0xFF43A047,
          type: PlayerType.ai, aiDifficulty: AIDifficulty.medium,
          pieces: [enemyPiece],
        ),
      ];

      final result = CaptureRules.checkCapture(2, 0, players);
      expect(result, isNull);
    });
  });

  group('CaptureRules.returnToBase', () {
    test('returns piece to base', () {
      final piece = Piece(id: 0, playerId: 1, status: PieceStatus.track, position: 15);
      final returned = CaptureRules.returnToBase(piece);

      expect(returned.status, PieceStatus.base);
      expect(returned.position, -1);
      expect(returned.id, piece.id);
      expect(returned.playerId, piece.playerId);
    });
  });
}
