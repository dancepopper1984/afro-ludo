import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';
import 'package:afro_ludo_flutter/core/achievement_registry.dart';
import 'package:afro_ludo_flutter/services/achievement_service.dart';
import 'package:afro_ludo_flutter/services/storage_service.dart';

class MockBox extends Mock implements Box {}

void main() {
  late MockBox mockBox;

  setUp(() {
    mockBox = MockBox();
    StorageService.setBox(mockBox);
    when(() => mockBox.get(any())).thenReturn(null);
    when(() => mockBox.put(any(), any())).thenAnswer((_) async {});
  });

  group('AchievementService', () {
    group('loadStats', () {
      test('returns defaults when no data', () {
        final stats = AchievementService.loadStats();
        expect(stats.totalWins, equals(0));
        expect(stats.bestStreak, equals(0));
        expect(stats.totalGames, equals(0));
      });

      test('reads values from storage', () {
        when(() => mockBox.get('totalWins')).thenReturn(5);
        when(() => mockBox.get('totalLosses')).thenReturn(3);
        when(() => mockBox.get('bestStreak')).thenReturn(2);
        when(() => mockBox.get('totalEarned')).thenReturn(500);

        final stats = AchievementService.loadStats();
        expect(stats.totalWins, equals(5));
        expect(stats.totalGames, equals(8));
        expect(stats.totalEarned, equals(500));
      });
    });

    group('checkUnlocks', () {
      test('unlocks first_win when totalWins >= 1', () {
        when(() => mockBox.get('totalWins')).thenReturn(1);

        final unlocked = AchievementService.checkUnlocks();
        expect(unlocked.any((a) => a.id == 'first_win'), isTrue);
      });

      test('does not unlock first_win when totalWins is 0', () {
        when(() => mockBox.get('totalWins')).thenReturn(0);

        final unlocked = AchievementService.checkUnlocks();
        expect(unlocked.any((a) => a.id == 'first_win'), isFalse);
      });

      test('unlocks streak_3 when bestStreak >= 3', () {
        when(() => mockBox.get('bestStreak')).thenReturn(3);

        final unlocked = AchievementService.checkUnlocks();
        expect(unlocked.any((a) => a.id == 'streak_3'), isTrue);
      });

      test('unlocks veteran_50 when totalGames >= 50', () {
        when(() => mockBox.get('totalWins')).thenReturn(30);
        when(() => mockBox.get('totalLosses')).thenReturn(20);

        final unlocked = AchievementService.checkUnlocks();
        expect(unlocked.any((a) => a.id == 'veteran_50'), isTrue);
      });

      test('does not re-unlock already unlocked achievements', () {
        when(() => mockBox.get('totalWins')).thenReturn(1);
        when(() => mockBox.get('unlockedAchievements'))
            .thenReturn('first_win');

        final unlocked = AchievementService.checkUnlocks();
        expect(unlocked.any((a) => a.id == 'first_win'), isFalse);
      });
    });

    group('checkAndUnlock', () {
      test('persists newly unlocked achievements', () async {
        when(() => mockBox.get('totalWins')).thenReturn(1);

        final unlocked = await AchievementService.checkAndUnlock();
        expect(unlocked.any((a) => a.id == 'first_win'), isTrue);
        verify(() => mockBox.put('unlockedAchievements', any())).called(1);
      });
    });

    group('calculateRewardCoins', () {
      test('sums coin rewards', () {
        final rewards = AchievementService.calculateRewardCoins([
          AchievementRegistry.firstWin,
          AchievementRegistry.streak3,
        ]);
        expect(rewards, equals(150));
      });
    });

    group('getUnlockedIds', () {
      test('returns empty list when no data', () {
        expect(AchievementService.getUnlockedIds(), isEmpty);
      });

      test('parses comma-separated ids', () {
        when(() => mockBox.get('unlockedAchievements'))
            .thenReturn('first_win,streak_3');
        expect(AchievementService.getUnlockedIds(),
            equals(['first_win', 'streak_3']));
      });
    });
  });
}
