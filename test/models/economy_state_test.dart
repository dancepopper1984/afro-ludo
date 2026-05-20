import 'package:flutter_test/flutter_test.dart';
import 'package:afro_ludo_flutter/models/economy_state.dart';

void main() {
  group('EconomyState', () {
    test('initial state has 300 coins', () {
      final state = EconomyState.initial();

      expect(state.afroCoins, 300);
      expect(state.totalEarned, 300);
      expect(state.dailyEarned, 0);
      expect(state.loginStreak, 0);
      expect(state.lastLoginDate, isNull);
    });

    test('copyWith changes only specified field', () {
      final state = EconomyState.initial();
      final updated = state.copyWith(afroCoins: 500);

      expect(updated.afroCoins, 500);
      expect(updated.totalEarned, state.totalEarned);
      expect(updated.dailyEarned, state.dailyEarned);
    });

    test('copyWith does not mutate original', () {
      final state = EconomyState.initial();
      final updated = state.copyWith(afroCoins: 999);

      expect(state.afroCoins, 300);
      expect(updated.afroCoins, 999);
    });

    test('copyWith can set lastLoginDate', () {
      final state = EconomyState.initial();
      final date = DateTime(2026, 5, 19);
      final updated = state.copyWith(lastLoginDate: date);

      expect(updated.lastLoginDate, date);
    });

    test('two identical states are equal', () {
      final a = EconomyState.initial();
      final b = EconomyState.initial();

      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('states with different coins are not equal', () {
      final a = EconomyState.initial();
      final b = a.copyWith(afroCoins: 500);

      expect(a, isNot(b));
    });

    test('login streak can be updated', () {
      final state = EconomyState.initial().copyWith(loginStreak: 5);
      expect(state.loginStreak, 5);
    });
  });
}
