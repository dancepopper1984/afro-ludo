import 'package:flutter_test/flutter_test.dart';
import 'package:afro_ludo_flutter/models/piece.dart';
import 'package:afro_ludo_flutter/ui/widgets/board_layout.dart';

void main() {
  group('BoardLayout', () {
    test('trackCoordinates has 52 entries', () {
      expect(BoardLayout.trackCoordinates.length, 52);
    });

    test('homeTrackCoordinates has 4 players x 5 positions', () {
      expect(BoardLayout.homeTrackCoordinates.length, 4);
      for (final track in BoardLayout.homeTrackCoordinates) {
        expect(track.length, 5);
      }
    });

    test('baseCoordinates has 4 players x 4 pieces', () {
      expect(BoardLayout.baseCoordinates.length, 4);
      for (final base in BoardLayout.baseCoordinates) {
        expect(base.length, 4);
      }
    });

    test('homeCoordinates has 4 entries', () {
      expect(BoardLayout.homeCoordinates.length, 4);
    });

    test('getGridPosition returns valid base coordinate', () {
      final pos = BoardLayout.getGridPosition(
        playerId: 0,
        pieceId: 0,
        position: 0,
        status: PieceStatus.base,
      );
      expect(pos, (1, 1));
    });

    test('getGridPosition returns valid track coordinate', () {
      final pos = BoardLayout.getGridPosition(
        playerId: 0,
        pieceId: 0,
        position: 0,
        status: PieceStatus.track,
      );
      expect(pos, (6, 1));
    });

    test('getGridPosition returns valid homeTrack coordinate', () {
      final pos = BoardLayout.getGridPosition(
        playerId: 0,
        pieceId: 0,
        position: 0,
        status: PieceStatus.homeTrack,
      );
      expect(pos, (5, 7));
    });

    test('getGridPosition returns valid home coordinate', () {
      final pos = BoardLayout.getGridPosition(
        playerId: 0,
        pieceId: 0,
        position: 0,
        status: PieceStatus.home,
      );
      expect(pos, (6, 6));
    });
  });
}
