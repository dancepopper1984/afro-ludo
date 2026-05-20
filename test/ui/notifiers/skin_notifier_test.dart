import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';
import 'package:afro_ludo_flutter/core/skin_registry.dart';
import 'package:afro_ludo_flutter/services/storage_service.dart';
import 'package:afro_ludo_flutter/ui/notifiers/skin_notifier.dart';

class MockBox extends Mock implements Box {}

void main() {
  late MockBox mockBox;

  setUp(() {
    mockBox = MockBox();
    StorageService.setBox(mockBox);
    when(() => mockBox.get(any())).thenReturn(null);
    when(() => mockBox.put(any(), any())).thenAnswer((_) async {});
  });

  group('SkinNotifier', () {
    test('initial state has classic skin unlocked', () {
      final notifier = SkinNotifier();
      expect(notifier.state.activeSkin.id, equals('classic'));
      expect(notifier.state.isUnlocked('classic'), isTrue);
    });

    test('loads active skin from storage', () {
      when(() => mockBox.get('activeSkin')).thenReturn('neon');
      when(() => mockBox.get('unlockedSkins')).thenReturn(['classic', 'neon']);

      final notifier = SkinNotifier();
      expect(notifier.state.activeSkin.id, equals('neon'));
      expect(notifier.state.isUnlocked('neon'), isTrue);
    });

    test('equipSkin changes active skin', () {
      when(() => mockBox.get('unlockedSkins')).thenReturn(['classic', 'neon']);

      final notifier = SkinNotifier();
      expect(notifier.state.isUnlocked('neon'), isTrue);

      final result = notifier.equipSkin('neon');
      expect(result, isTrue);
      expect(notifier.state.activeSkin.id, equals('neon'));
      verify(() => mockBox.put('activeSkin', 'neon')).called(1);
    });

    test('equipSkin fails for locked skin', () {
      final notifier = SkinNotifier();
      final result = notifier.equipSkin('neon');
      expect(result, isFalse);
      expect(notifier.state.activeSkin.id, equals('classic'));
    });

    test('buySkin unlocks and equips skin', () {
      final notifier = SkinNotifier();
      var balance = 2000;

      final result = notifier.buySkin('neon', balance: balance, deduct: (price) {
        balance -= price;
        return balance;
      });

      expect(result, isTrue);
      expect(notifier.state.isUnlocked('neon'), isTrue);
      expect(notifier.state.isEquipped('neon'), isTrue);
      expect(balance, equals(1000));
      verify(() => mockBox.put('unlockedSkins', any())).called(1);
      verify(() => mockBox.put('activeSkin', 'neon')).called(1);
    });

    test('buySkin fails when insufficient balance', () {
      final notifier = SkinNotifier();
      var balance = 500;

      final result = notifier.buySkin('neon', balance: balance, deduct: (price) {
        balance -= price;
        return balance;
      });

      expect(result, isFalse);
      expect(notifier.state.isUnlocked('neon'), isFalse);
    });

    test('buySkin fails for already unlocked skin', () {
      when(() => mockBox.get('unlockedSkins')).thenReturn(['classic', 'neon']);

      final notifier = SkinNotifier();
      final result = notifier.buySkin('neon', balance: 9999, deduct: (p) => 9999 - p);
      expect(result, isFalse);
    });

    test('buySkin fails for unknown skin', () {
      final notifier = SkinNotifier();
      final result = notifier.buySkin('unknown', balance: 9999, deduct: (p) => 9999 - p);
      expect(result, isFalse);
    });
  });
}
