import 'package:flutter_test/flutter_test.dart';
import 'package:afro_ludo_flutter/models/piece.dart';

void main() {
  group('Piece', () {
    test('initial piece is in base with position -1', () {
      final piece = Piece.initial(id: 0, playerId: 0);

      expect(piece.id, 0);
      expect(piece.playerId, 0);
      expect(piece.status, PieceStatus.base);
      expect(piece.position, -1);
      expect(piece.isInBase, true);
      expect(piece.isHome, false);
      expect(piece.isOnTrack, false);
    });

    test('piece on track has correct status', () {
      final piece = Piece(
        id: 0,
        playerId: 0,
        status: PieceStatus.track,
        position: 10,
      );

      expect(piece.isInBase, false);
      expect(piece.isOnTrack, true);
      expect(piece.isHome, false);
    });

    test('piece on homeTrack has correct status', () {
      final piece = Piece(
        id: 0,
        playerId: 0,
        status: PieceStatus.homeTrack,
        position: 3,
      );

      expect(piece.isOnTrack, true);
      expect(piece.isHome, false);
    });

    test('piece at home has correct status', () {
      final piece = Piece(
        id: 0,
        playerId: 0,
        status: PieceStatus.home,
        position: 5,
      );

      expect(piece.isHome, true);
      expect(piece.isOnTrack, false);
      expect(piece.isInBase, false);
    });

    test('copyWith changes only specified field', () {
      final piece = Piece.initial(id: 0, playerId: 0);
      final moved = piece.copyWith(status: PieceStatus.track, position: 10);

      expect(moved.id, piece.id);
      expect(moved.playerId, piece.playerId);
      expect(moved.status, PieceStatus.track);
      expect(moved.position, 10);
    });

    test('two identical pieces are equal', () {
      final a = Piece.initial(id: 0, playerId: 0);
      final b = Piece.initial(id: 0, playerId: 0);

      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('pieces with different positions are not equal', () {
      final a = Piece(id: 0, playerId: 0, status: PieceStatus.track, position: 10);
      final b = Piece(id: 0, playerId: 0, status: PieceStatus.track, position: 11);

      expect(a, isNot(b));
    });

    test('position boundary: base is -1', () {
      final piece = Piece(id: 0, playerId: 0, status: PieceStatus.base, position: -1);
      expect(piece.position, -1);
    });

    test('position boundary: track max is 51', () {
      final piece = Piece(id: 0, playerId: 0, status: PieceStatus.track, position: 51);
      expect(piece.position, 51);
    });

    test('position boundary: home is 5', () {
      final piece = Piece(id: 0, playerId: 0, status: PieceStatus.home, position: 5);
      expect(piece.position, 5);
      expect(piece.isHome, true);
    });
  });
}
