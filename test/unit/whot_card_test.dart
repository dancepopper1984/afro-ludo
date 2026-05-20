import 'package:flutter_test/flutter_test.dart';
import '../../lib/models/whot_card.dart';

void main() {
  group('WhotCard', () {
    group('effect', () {
      test('1 is holdOn', () {
        expect(WhotCard(shape: WhotShape.circle, number: 1).effect, WhotEffect.holdOn);
      });
      test('2 is pickTwo', () {
        expect(WhotCard(shape: WhotShape.circle, number: 2).effect, WhotEffect.pickTwo);
      });
      test('5 is pickThree', () {
        expect(WhotCard(shape: WhotShape.circle, number: 5).effect, WhotEffect.pickThree);
      });
      test('8 is skip', () {
        expect(WhotCard(shape: WhotShape.circle, number: 8).effect, WhotEffect.skip);
      });
      test('14 is generalMarket', () {
        expect(WhotCard(shape: WhotShape.circle, number: 14).effect, WhotEffect.generalMarket);
      });
      test('20 (whot) is whot', () {
        expect(WhotCard(shape: WhotShape.whot, number: 20).effect, WhotEffect.whot);
      });
      test('3 has no effect', () {
        expect(WhotCard(shape: WhotShape.circle, number: 3).effect, null);
      });
    });

    group('canPlayOn', () {
      final star3 = WhotCard(shape: WhotShape.star, number: 3);
      final star7 = WhotCard(shape: WhotShape.star, number: 7);
      final cross3 = WhotCard(shape: WhotShape.cross, number: 3);
      final triangle8 = WhotCard(shape: WhotShape.triangle, number: 8);
      final whot = WhotCard(shape: WhotShape.whot, number: 20);

      test('matches same shape', () {
        expect(star3.canPlayOn(star7), true);
      });

      test('matches same number', () {
        expect(star3.canPlayOn(cross3), true);
      });

      test('no match fails', () {
        expect(star3.canPlayOn(triangle8), false);
      });

      test('whot plays on anything', () {
        expect(whot.canPlayOn(star3), true);
        expect(whot.canPlayOn(cross3), true);
      });

      test('whot with demanded shape matches called shape', () {
        expect(star3.canPlayOn(whot, demandedShape: WhotShape.star), true);
        expect(star3.canPlayOn(whot, demandedShape: WhotShape.cross), false);
      });

      test('whot always plays on whot with demanded shape', () {
        expect(whot.canPlayOn(whot, demandedShape: WhotShape.star), true);
      });
    });

    group('equality', () {
      test('same card equals', () {
        final a = WhotCard(shape: WhotShape.circle, number: 5);
        final b = WhotCard(shape: WhotShape.circle, number: 5);
        expect(a, equals(b));
      });

      test('different cards not equal', () {
        final a = WhotCard(shape: WhotShape.circle, number: 5);
        final b = WhotCard(shape: WhotShape.circle, number: 6);
        expect(a, isNot(equals(b)));
      });
    });
  });
}
