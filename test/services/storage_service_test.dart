import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';
import 'package:afro_ludo_flutter/services/storage_service.dart';

class MockBox extends Mock implements Box {}

void main() {
  late MockBox mockBox;

  setUp(() {
    mockBox = MockBox();
    StorageService.setBox(mockBox);
  });

  group('StorageService', () {
    group('Settings', () {
      test('getSoundEnabled returns value from box', () {
        when(() => mockBox.get('soundEnabled')).thenReturn(true);
        expect(StorageService.getSoundEnabled(), isTrue);
      });

      test('setSoundEnabled writes to box', () async {
        when(() => mockBox.put('soundEnabled', false))
            .thenAnswer((_) async {});
        await StorageService.setSoundEnabled(false);
        verify(() => mockBox.put('soundEnabled', false)).called(1);
      });

      test('getHapticsEnabled returns value from box', () {
        when(() => mockBox.get('hapticsEnabled')).thenReturn(false);
        expect(StorageService.getHapticsEnabled(), isFalse);
      });

      test('setHapticsEnabled writes to box', () async {
        when(() => mockBox.put('hapticsEnabled', true))
            .thenAnswer((_) async {});
        await StorageService.setHapticsEnabled(true);
        verify(() => mockBox.put('hapticsEnabled', true)).called(1);
      });

      test('getDifficulty returns value from box', () {
        when(() => mockBox.get('aiDifficulty')).thenReturn('hard');
        expect(StorageService.getDifficulty(), equals('hard'));
      });

      test('setDifficulty writes to box', () async {
        when(() => mockBox.put('aiDifficulty', 'easy'))
            .thenAnswer((_) async {});
        await StorageService.setDifficulty('easy');
        verify(() => mockBox.put('aiDifficulty', 'easy')).called(1);
      });

      test('getHasCompletedOnboarding returns value from box', () {
        when(() => mockBox.get('hasCompletedOnboarding')).thenReturn(true);
        expect(StorageService.getHasCompletedOnboarding(), isTrue);
      });

      test('getLanguage returns value from box', () {
        when(() => mockBox.get('language')).thenReturn('fr');
        expect(StorageService.getLanguage(), equals('fr'));
      });
    });

    group('Economy', () {
      test('getAfroCoins returns value from box', () {
        when(() => mockBox.get('afroCoins')).thenReturn(500);
        expect(StorageService.getAfroCoins(), equals(500));
      });

      test('setAfroCoins writes to box', () async {
        when(() => mockBox.put('afroCoins', 1000)).thenAnswer((_) async {});
        await StorageService.setAfroCoins(1000);
        verify(() => mockBox.put('afroCoins', 1000)).called(1);
      });

      test('getTotalEarned returns value from box', () {
        when(() => mockBox.get('totalEarned')).thenReturn(2000);
        expect(StorageService.getTotalEarned(), equals(2000));
      });

      test('getDailyEarned returns value from box', () {
        when(() => mockBox.get('dailyEarned')).thenReturn(150);
        expect(StorageService.getDailyEarned(), equals(150));
      });

      test('getLastLoginDate returns value from box', () {
        when(() => mockBox.get('lastLoginDate')).thenReturn('2026-05-20');
        expect(StorageService.getLastLoginDate(), equals('2026-05-20'));
      });

      test('setLastLoginDate writes null to box', () async {
        when(() => mockBox.put('lastLoginDate', null)).thenAnswer((_) async {});
        await StorageService.setLastLoginDate(null);
        verify(() => mockBox.put('lastLoginDate', null)).called(1);
      });

      test('getLoginStreak returns value from box', () {
        when(() => mockBox.get('loginStreak')).thenReturn(5);
        expect(StorageService.getLoginStreak(), equals(5));
      });
    });

    group('Age Verification', () {
      test('getAgeVerified returns value from box', () {
        when(() => mockBox.get('ageVerified')).thenReturn(true);
        expect(StorageService.getAgeVerified(), isTrue);
      });

      test('setAgeVerified writes to box', () async {
        when(() => mockBox.put('ageVerified', true)).thenAnswer((_) async {});
        await StorageService.setAgeVerified(true);
        verify(() => mockBox.put('ageVerified', true)).called(1);
      });
    });

    group('Leaderboard / Stats', () {
      test('getTotalWins returns value from box', () {
        when(() => mockBox.get('totalWins')).thenReturn(10);
        expect(StorageService.getTotalWins(), equals(10));
      });

      test('getTotalLosses returns value from box', () {
        when(() => mockBox.get('totalLosses')).thenReturn(5);
        expect(StorageService.getTotalLosses(), equals(5));
      });

      test('getBestStreak returns value from box', () {
        when(() => mockBox.get('bestStreak')).thenReturn(7);
        expect(StorageService.getBestStreak(), equals(7));
      });

      test('getCurrentStreak returns value from box', () {
        when(() => mockBox.get('currentStreak')).thenReturn(3);
        expect(StorageService.getCurrentStreak(), equals(3));
      });
    });

    group('Skins', () {
      test('getActiveSkin returns value from box', () {
        when(() => mockBox.get('activeSkin')).thenReturn('neon');
        expect(StorageService.getActiveSkin(), equals('neon'));
      });

      test('setActiveSkin writes to box', () async {
        when(() => mockBox.put('activeSkin', 'golden'))
            .thenAnswer((_) async {});
        await StorageService.setActiveSkin('golden');
        verify(() => mockBox.put('activeSkin', 'golden')).called(1);
      });

      test('getUnlockedSkins returns casted list', () {
        when(() => mockBox.get('unlockedSkins')).thenReturn(['default', 'neon']);
        expect(StorageService.getUnlockedSkins(), equals(['default', 'neon']));
      });

      test('getUnlockedSkins returns null when not set', () {
        when(() => mockBox.get('unlockedSkins')).thenReturn(null);
        expect(StorageService.getUnlockedSkins(), isNull);
      });

      test('setUnlockedSkins writes list to box', () async {
        when(() => mockBox.put('unlockedSkins', ['default', 'golden']))
            .thenAnswer((_) async {});
        await StorageService.setUnlockedSkins(['default', 'golden']);
        verify(() => mockBox.put('unlockedSkins', ['default', 'golden']))
            .called(1);
      });
    });

    group('Error handling', () {
      test('throws StateError when box is not initialized', () {
        StorageService.setBox(null);
        expect(() => StorageService.getSoundEnabled(), throwsStateError);
      });
    });
  });
}
