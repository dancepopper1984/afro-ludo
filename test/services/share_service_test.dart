import 'package:flutter_test/flutter_test.dart';
import 'package:afro_ludo_flutter/services/share_service.dart';

void main() {
  group('ShareService.buildGameResultText', () {
    test('includes game name', () {
      final text = ShareService.buildGameResultText(
        gameName: 'Ludo',
        position: 1,
      );
      expect(text, contains('Ludo'));
      expect(text, contains('Afro Ludo'));
    });

    test('first place text', () {
      final text = ShareService.buildGameResultText(
        gameName: 'Ludo',
        position: 1,
        totalPlayers: 4,
      );
      expect(text, contains('WON 1st place'));
      expect(text, contains('4 players'));
    });

    test('non-first place text', () {
      final text = ShareService.buildGameResultText(
        gameName: 'Ludo',
        position: 3,
        totalPlayers: 4,
      );
      expect(text, contains('#3'));
      expect(text, isNot(contains('WON')));
    });

    test('includes extra info when provided', () {
      final text = ShareService.buildGameResultText(
        gameName: 'Ludo',
        position: 1,
        extra: '5 wins in a row!',
      );
      expect(text, contains('5 wins in a row!'));
    });

    test('omits extra when null', () {
      final text = ShareService.buildGameResultText(
        gameName: 'Ludo',
        position: 2,
      );
      expect(text.split('\n').length, equals(4));
    });

    test('ends with download call to action', () {
      final text = ShareService.buildGameResultText(
        gameName: 'Ludo',
        position: 1,
      );
      expect(text, contains('Download Afro Ludo'));
    });
  });
}
