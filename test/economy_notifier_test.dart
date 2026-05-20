import 'package:flutter_test/flutter_test.dart';
import 'package:afro_ludo_flutter/ui/notifiers/economy_notifier.dart';

void main() {
  group('EconomyNotifier', () {
    late EconomyNotifier notifier;

    setUp(() {
      notifier = EconomyNotifier();
    });

    test('initial state has default coins', () {
      expect(notifier.state.afroCoins, greaterThanOrEqualTo(0));
    });

    test('addCoins increases balance', () {
      final initial = notifier.state.afroCoins;
      final result = notifier.addCoins(100);
      expect(result, true);
      expect(notifier.state.afroCoins, initial + 100);
    });

    test('addCoins with zero or negative amount returns false', () {
      expect(notifier.addCoins(0), false);
      expect(notifier.addCoins(-10), false);
    });

    test('spendCoins decreases balance', () {
      notifier.addCoins(500);
      final initial = notifier.state.afroCoins;
      final result = notifier.spendCoins(100);
      expect(result, true);
      expect(notifier.state.afroCoins, initial - 100);
    });

    test('spendCoins fails when balance is insufficient', () {
      final initial = notifier.state.afroCoins;
      final result = notifier.spendCoins(initial + 1000);
      expect(result, false);
      expect(notifier.state.afroCoins, initial);
    });

    test('dailyCheckIn returns 0 on same day', () {
      final today = DateTime(2026, 5, 19);
      final firstReward = notifier.dailyCheckIn(today);
      expect(firstReward, greaterThan(0));

      final secondReward = notifier.dailyCheckIn(today);
      expect(secondReward, 0);
    });

    test('watchAdReward adds coins', () {
      final initial = notifier.state.afroCoins;
      notifier.watchAdReward();
      expect(notifier.state.afroCoins, greaterThan(initial));
    });

    test('recordWin awards coins based on place', () {
      final initial = notifier.state.afroCoins;
      notifier.recordWin(place: 1);
      expect(notifier.state.afroCoins, greaterThan(initial));
    });
  });
}
