import 'package:flutter_test/flutter_test.dart';
import 'package:afro_ludo_flutter/core/constants.dart';
import 'package:afro_ludo_flutter/ui/notifiers/economy_notifier.dart';

void main() {
  group('EconomyNotifier', () {
    test('initial state has 300 coins', () {
      final notifier = EconomyNotifier();
      expect(notifier.state.afroCoins, 300);
      expect(notifier.state.dailyEarned, 0);
    });

    test('addCoins increases balance and total earned', () {
      final notifier = EconomyNotifier();
      final result = notifier.addCoins(50);

      expect(result, true);
      expect(notifier.state.afroCoins, 350);
      expect(notifier.state.totalEarned, 350);
      expect(notifier.state.dailyEarned, 50);
    });

    test('addCoins respects daily limit', () {
      final notifier = EconomyNotifier();
      // Set daily earned near limit
      notifier.state = notifier.state.copyWith(dailyEarned: 980);

      final result = notifier.addCoins(50);

      // Only 20 can be added to reach 1000 limit
      expect(result, true);
      expect(notifier.state.afroCoins, 320);
      expect(notifier.state.dailyEarned, 1000);
    });

    test('addCoins returns false when daily limit reached', () {
      final notifier = EconomyNotifier();
      notifier.state = notifier.state.copyWith(dailyEarned: 1000);

      final result = notifier.addCoins(50);

      expect(result, false);
      expect(notifier.state.afroCoins, 300); // unchanged
    });

    test('spendCoins decreases balance', () {
      final notifier = EconomyNotifier();
      final result = notifier.spendCoins(100);

      expect(result, true);
      expect(notifier.state.afroCoins, 200);
    });

    test('spendCoins fails when insufficient balance', () {
      final notifier = EconomyNotifier();
      final result = notifier.spendCoins(500);

      expect(result, false);
      expect(notifier.state.afroCoins, 300); // unchanged
    });

    test('recordFirstPlace adds 100 coins', () {
      final notifier = EconomyNotifier();
      notifier.recordWin(place: 1);

      expect(notifier.state.afroCoins, 400);
    });

    test('recordSecondPlace adds 80 coins', () {
      final notifier = EconomyNotifier();
      notifier.recordWin(place: 2);

      expect(notifier.state.afroCoins, 380);
    });

    test('watchAdReward adds 50 coins', () {
      final notifier = EconomyNotifier();
      notifier.watchAdReward();

      expect(notifier.state.afroCoins, 350);
    });

    test('dailyCheckIn rewards base amount on day 1', () {
      final notifier = EconomyNotifier();
      final today = DateTime(2026, 5, 19);

      final reward = notifier.dailyCheckIn(today);

      expect(reward, EconomyConstants.dailyCheckInBase);
      expect(notifier.state.afroCoins, 350);
      expect(notifier.state.loginStreak, 1);
    });

    test('dailyCheckIn consecutive day increases streak', () {
      final notifier = EconomyNotifier();
      final yesterday = DateTime(2026, 5, 18);
      final today = DateTime(2026, 5, 19);

      notifier.state = notifier.state.copyWith(lastLoginDate: yesterday, loginStreak: 2);

      final reward = notifier.dailyCheckIn(today);

      // streak 3: base 50 + (3-1)*10 = 70
      expect(reward, 70);
      expect(notifier.state.loginStreak, 3);
    });

    test('dailyCheckIn missed day resets streak', () {
      final notifier = EconomyNotifier();
      final twoDaysAgo = DateTime(2026, 5, 17);
      final today = DateTime(2026, 5, 19);

      notifier.state = notifier.state.copyWith(lastLoginDate: twoDaysAgo, loginStreak: 5);

      final reward = notifier.dailyCheckIn(today);

      expect(reward, EconomyConstants.dailyCheckInBase); // base amount
      expect(notifier.state.loginStreak, 1); // reset
    });

    test('dailyCheckIn same day returns 0', () {
      final notifier = EconomyNotifier();
      final today = DateTime(2026, 5, 19);

      notifier.state = notifier.state.copyWith(lastLoginDate: today);

      final reward = notifier.dailyCheckIn(today);

      expect(reward, 0);
    });

    test('resetDailyEarned resets daily counter', () {
      final notifier = EconomyNotifier();
      notifier.state = notifier.state.copyWith(dailyEarned: 500);

      notifier.resetDailyEarned();

      expect(notifier.state.dailyEarned, 0);
    });
  });
}
