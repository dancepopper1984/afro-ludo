import 'package:flutter_test/flutter_test.dart';
import 'package:afro_ludo_flutter/game/ludo/move_rules.dart';
import 'package:afro_ludo_flutter/models/piece.dart';

void main() {
  group('MoveRules.canMove', () {
    test('base piece can move with dice 6', () {
      final piece = Piece.initial(id: 0, playerId: 0);
      expect(MoveRules.canMove(piece, 6), true);
    });

    test('base piece cannot move with non-6', () {
      final piece = Piece.initial(id: 0, playerId: 0);
      expect(MoveRules.canMove(piece, 5), false);
      expect(MoveRules.canMove(piece, 1), false);
    });

    test('track piece can always move', () {
      final piece = Piece(id: 0, playerId: 0, status: PieceStatus.track, position: 10);
      expect(MoveRules.canMove(piece, 1), true);
      expect(MoveRules.canMove(piece, 6), true);
    });

    test('homeTrack piece can move if not exceeding 5', () {
      final piece = Piece(id: 0, playerId: 0, status: PieceStatus.homeTrack, position: 2);
      expect(MoveRules.canMove(piece, 2), true);  // 2+2=4 <= 5
      expect(MoveRules.canMove(piece, 3), true);  // 2+3=5 <= 5
    });

    test('homeTrack piece cannot move if exceeding 5', () {
      final piece = Piece(id: 0, playerId: 0, status: PieceStatus.homeTrack, position: 3);
      expect(MoveRules.canMove(piece, 3), false); // 3+3=6 > 5
    });

    test('homeTrack piece at 4 can only move with 1', () {
      final piece = Piece(id: 0, playerId: 0, status: PieceStatus.homeTrack, position: 4);
      expect(MoveRules.canMove(piece, 1), true);  // 4+1=5
      expect(MoveRules.canMove(piece, 2), false); // 4+2=6 > 5
    });

    test('home piece cannot move', () {
      final piece = Piece(id: 0, playerId: 0, status: PieceStatus.home, position: 5);
      expect(MoveRules.canMove(piece, 6), false);
    });
  });

  group('MoveRules.calculateNewPosition', () {
    test('base piece exits to start with dice 6', () {
      final piece = Piece.initial(id: 0, playerId: 0);
      final result = MoveRules.calculateNewPosition(piece, 6);
      expect(result.position, 0);  // Red starts at 0
      expect(result.status, PieceStatus.track);
    });

    test('Green base piece exits to start 13', () {
      final piece = Piece.initial(id: 0, playerId: 1);
      final result = MoveRules.calculateNewPosition(piece, 6);
      expect(result.position, 13);  // Green starts at 13
      expect(result.status, PieceStatus.track);
    });

    test('normal track move', () {
      final piece = Piece(id: 0, playerId: 0, status: PieceStatus.track, position: 10);
      final result = MoveRules.calculateNewPosition(piece, 3);
      expect(result.position, 13);
      expect(result.status, PieceStatus.track);
    });

    test('track move wraps around (Green, home entry not triggered)', () {
      // Green at 50, home entry is 12, won't trigger home entry
      final piece = Piece(id: 0, playerId: 1, status: PieceStatus.track, position: 50);
      final result = MoveRules.calculateNewPosition(piece, 3);
      expect(result.position, 1);  // 50+3=53, wrap to 1
      expect(result.status, PieceStatus.track);
    });

    group('home entry (critical bug fix)', () {
      test('Red at 50 + 3 enters home track at 1', () {
        // Critical: must check home entry BEFORE wrapping
        // 50 -> 51 (1 step to home entry) -> homeTrack 0 (2nd step) -> homeTrack 1 (3rd step)
        final piece = Piece(id: 0, playerId: 0, status: PieceStatus.track, position: 50);
        final result = MoveRules.calculateNewPosition(piece, 3);
        expect(result.position, 1);        // home track position 1
        expect(result.status, PieceStatus.homeTrack);
      });

      test('Red at 50 + 2 enters home track at 0', () {
        final piece = Piece(id: 0, playerId: 0, status: PieceStatus.track, position: 50);
        final result = MoveRules.calculateNewPosition(piece, 2);
        expect(result.position, 0);        // home track position 0
        expect(result.status, PieceStatus.homeTrack);
      });

      test('Red at 51 + 1 enters home track at 0', () {
        final piece = Piece(id: 0, playerId: 0, status: PieceStatus.track, position: 51);
        final result = MoveRules.calculateNewPosition(piece, 1);
        expect(result.position, 0);
        expect(result.status, PieceStatus.homeTrack);
      });

      test('Green at 0 + 12 stays on track at 12 (home entry, not home track)', () {
        // Exactly at home entry, not exceeding it
        final piece = Piece(id: 0, playerId: 1, status: PieceStatus.track, position: 0);
        final result = MoveRules.calculateNewPosition(piece, 12);
        expect(result.position, 12);       // still on track
        expect(result.status, PieceStatus.track);
      });

      test('Green at 0 + 13 enters home track at 0', () {
        // Exceeds home entry by 1
        final piece = Piece(id: 0, playerId: 1, status: PieceStatus.track, position: 0);
        final result = MoveRules.calculateNewPosition(piece, 13);
        expect(result.position, 0);
        expect(result.status, PieceStatus.homeTrack);
      });

      test('Green at 11 + 1 stays on track at 12 (home entry)', () {
        // Exactly at home entry, not exceeding it
        final piece = Piece(id: 0, playerId: 1, status: PieceStatus.track, position: 11);
        final result = MoveRules.calculateNewPosition(piece, 1);
        expect(result.position, 12);       // home entry on track
        expect(result.status, PieceStatus.track);
      });

      test('Green at 11 + 2 enters home track at 0', () {
        // Exceeds home entry by 1
        final piece = Piece(id: 0, playerId: 1, status: PieceStatus.track, position: 11);
        final result = MoveRules.calculateNewPosition(piece, 2);
        expect(result.position, 0);
        expect(result.status, PieceStatus.homeTrack);
      });

      test('Green at 12 + 1 enters home track at 0', () {
        // From home entry, 1 step enters home track
        final piece = Piece(id: 0, playerId: 1, status: PieceStatus.track, position: 12);
        final result = MoveRules.calculateNewPosition(piece, 1);
        expect(result.position, 0);
        expect(result.status, PieceStatus.homeTrack);
      });

      test('Green at 50 + 3 stays on track at 1 (not home)', () {
        // Green at 50, home entry is 12, hasn't completed full lap
        final piece = Piece(id: 0, playerId: 1, status: PieceStatus.track, position: 50);
        final result = MoveRules.calculateNewPosition(piece, 3);
        expect(result.position, 1);  // wrapped: 53-52=1
        expect(result.status, PieceStatus.track);
      });

      test('Yellow at 25 + 1 enters home track', () {
        // 25 is home entry, +1 exceeds it
        final piece = Piece(id: 0, playerId: 2, status: PieceStatus.track, position: 25);
        final result = MoveRules.calculateNewPosition(piece, 1);
        expect(result.position, 0);
        expect(result.status, PieceStatus.homeTrack);
      });

      test('Blue at 38 + 1 enters home track', () {
        // 38 is home entry, +1 exceeds it
        final piece = Piece(id: 0, playerId: 3, status: PieceStatus.track, position: 38);
        final result = MoveRules.calculateNewPosition(piece, 1);
        expect(result.position, 0);
        expect(result.status, PieceStatus.homeTrack);
      });
    });

    group('home track moves', () {
      test('homeTrack 0 + 2 = homeTrack 2', () {
        final piece = Piece(id: 0, playerId: 0, status: PieceStatus.homeTrack, position: 0);
        final result = MoveRules.calculateNewPosition(piece, 2);
        expect(result.position, 2);
        expect(result.status, PieceStatus.homeTrack);
      });

      test('homeTrack 3 + 2 = home (position 5)', () {
        final piece = Piece(id: 0, playerId: 0, status: PieceStatus.homeTrack, position: 3);
        final result = MoveRules.calculateNewPosition(piece, 2);
        expect(result.position, 5);
        expect(result.status, PieceStatus.home);
      });

      test('homeTrack 4 + 1 = home (position 5)', () {
        final piece = Piece(id: 0, playerId: 0, status: PieceStatus.homeTrack, position: 4);
        final result = MoveRules.calculateNewPosition(piece, 1);
        expect(result.position, 5);
        expect(result.status, PieceStatus.home);
      });

      test('homeTrack 0 + 5 = home (position 5)', () {
        final piece = Piece(id: 0, playerId: 0, status: PieceStatus.homeTrack, position: 0);
        final result = MoveRules.calculateNewPosition(piece, 5);
        expect(result.position, 5);
        expect(result.status, PieceStatus.home);
      });
    });

    test('home piece throws error', () {
      final piece = Piece(id: 0, playerId: 0, status: PieceStatus.home, position: 5);
      expect(() => MoveRules.calculateNewPosition(piece, 1), throwsStateError);
    });
  });
}
