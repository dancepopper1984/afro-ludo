import 'package:flutter_test/flutter_test.dart';
import '../../lib/ui/notifiers/economy_notifier.dart';
import '../../lib/models/economy_state.dart';
import '../../lib/core/constants.dart';

void main() {
  group('EconomyNotifier', () {
    test('addCoins increases balance', () {
      final notifier = EconomyNotifier();
      final initial = notifier.state.afroCoins;
      final result = notifier.addCoins(100);
      expect(result, true);
      expect(notifier.state.afroCoins, initial + 100);
    });

    test('addCoins respects daily limit', () {
      final notifier = EconomyNotifier();
      // Add up to daily limit
      final limit = EconomyConstants.dailyEarningLimit;
      notifier.addCoins(limit);
      final result = notifier.addCoins(100);
      expect(result, false);
    });

    test('addCoins caps at remaining daily limit', () {
      final notifier = EconomyNotifier();
      final remaining = EconomyConstants.dailyEarningLimit - notifier.state.dailyEarned;
      notifier.addCoins(remaining - 50);
      // Now add more than remaining
      final result = notifier.addCoins(100);
      expect(result, true);
      // Should only have added 50 (the remaining amount)
      expect(notifier.state.dailyEarned, EconomyConstants.dailyEarningLimit);
    });

    test('addCoins with zero or negative returns false', () {
      final notifier = EconomyNotifier();
      expect(notifier.addCoins(0), false);
      expect(notifier.addCoins(-10), false);
    });

    test('spendCoins decreases balance', () {
      final notifier = EconomyNotifier();
      final initial = notifier.state.afroCoins;
      final result = notifier.spendCoins(50);
      expect(result, true);
      expect(notifier.state.afroCoins, initial - 50);
    });

    test('spendCoins fails when insufficient', () {
      final notifier = EconomyNotifier();
      final result = notifier.spendCoins(notifier.state.afroCoins + 1);
      expect(result, false);
      expect(notifier.state.afroCoins, EconomyConstants.initialCoins);
    });

    test('spendCoins with zero returns true', () {
      final notifier = EconomyNotifier();
      expect(notifier.spendCoins(0), true);
    });

    test('recordWin adds first place reward', () {
      final notifier = EconomyNotifier();
      final initial = notifier.state.afroCoins;
      notifier.recordWin(place: 1);
      expect(notifier.state.afroCoins, initial + EconomyConstants.firstPlaceReward);
    });

    test('recordWin adds second place reward', () {
      final notifier = EconomyNotifier();
      final initial = notifier.state.afroCoins;
      notifier.recordWin(place: 2);
      expect(notifier.state.afroCoins, initial + EconomyConstants.secondPlaceReward);
    });

    test('recordWin adds nothing for third place', () {
      final notifier = EconomyNotifier();
      final initial = notifier.state.afroCoins;
      notifier.recordWin(place: 3);
      expect(notifier.state.afroCoins, initial);
    });

    test('watchAdReward adds coins', () {
      final notifier = EconomyNotifier();
      final initial = notifier.state.afroCoins;
      notifier.watchAdReward();
      expect(notifier.state.afroCoins, initial + EconomyConstants.adRewardAmount);
    });

    group('dailyCheckIn', () {
      test('first check-in awards base amount and starts streak', () {
        final notifier = EconomyNotifier();
        final today = DateTime(2026, 5, 20);
        final reward = notifier.dailyCheckIn(today);
        expect(reward, EconomyConstants.dailyCheckInBase);
        expect(notifier.state.loginStreak, 1);
        expect(notifier.state.lastLoginDate, DateTime(2026, 5, 20));
      });

      test('consecutive check-in increases streak', () {
        final notifier = EconomyNotifier();
        notifier.dailyCheckIn(DateTime(2026, 5, 20));
        final reward = notifier.dailyCheckIn(DateTime(2026, 5, 21));
        expect(reward, greaterThan(EconomyConstants.dailyCheckInBase));
        expect(notifier.state.loginStreak, 2);
      });

      test('same day check-in returns 0', () {
        final notifier = EconomyNotifier();
        notifier.dailyCheckIn(DateTime(2026, 5, 20));
        final reward = notifier.dailyCheckIn(DateTime(2026, 5, 20));
        expect(reward, 0);
      });
    });
  });
}
