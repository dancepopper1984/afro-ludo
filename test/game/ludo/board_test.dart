import 'package:flutter_test/flutter_test.dart';
import 'package:afro_ludo_flutter/game/ludo/board.dart';
import 'package:afro_ludo_flutter/core/constants.dart';

void main() {
  group('Board', () {
    group('getPlayerStart', () {
      test('player 0 (Red) starts at 0', () {
        expect(Board.getPlayerStart(0), 0);
      });

      test('player 1 (Green) starts at 13', () {
        expect(Board.getPlayerStart(1), 13);
      });

      test('player 2 (Yellow) starts at 26', () {
        expect(Board.getPlayerStart(2), 26);
      });

      test('player 3 (Blue) starts at 39', () {
        expect(Board.getPlayerStart(3), 39);
      });
    });

    group('getPlayerHomeEntry', () {
      test('player 0 (Red) home entry is 51', () {
        expect(Board.getPlayerHomeEntry(0), 51);
      });

      test('player 1 (Green) home entry is 12', () {
        expect(Board.getPlayerHomeEntry(1), 12);
      });

      test('player 2 (Yellow) home entry is 25', () {
        expect(Board.getPlayerHomeEntry(2), 25);
      });

      test('player 3 (Blue) home entry is 38', () {
        expect(Board.getPlayerHomeEntry(3), 38);
      });
    });

    group('isSafeZone', () {
      test('position 0 is safe zone', () {
        expect(Board.isSafeZone(0), true);
      });

      test('position 8 is safe zone', () {
        expect(Board.isSafeZone(8), true);
      });

      test('position 10 is not safe zone', () {
        expect(Board.isSafeZone(10), false);
      });

      test('all safe zones are recognized', () {
        for (final zone in kSafeZones) {
          expect(Board.isSafeZone(zone), true, reason: 'Position $zone should be safe');
        }
      });
    });

    group('moveOnTrack', () {
      test('normal move without wrap', () {
        expect(Board.moveOnTrack(10, 3), 13);
      });

      test('move wraps around track', () {
        expect(Board.moveOnTrack(50, 3), 1);
      });

      test('move from 51 wraps to 0', () {
        expect(Board.moveOnTrack(51, 1), 0);
      });

      test('move with large steps wraps multiple times', () {
        expect(Board.moveOnTrack(10, 52), 10);
      });
    });

    group('stepsToHomeEntry', () {
      test('Red needs 51 steps to home entry', () {
        expect(Board.stepsToHomeEntry(0), 51);
      });

      test('Green needs 51 steps to home entry', () {
        expect(Board.stepsToHomeEntry(1), 51);
      });

      test('Yellow needs 51 steps to home entry', () {
        expect(Board.stepsToHomeEntry(2), 51);
      });

      test('Blue needs 51 steps to home entry', () {
        expect(Board.stepsToHomeEntry(3), 51);
      });
    });
  });
}
