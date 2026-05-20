import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';
import 'package:afro_ludo_flutter/services/ad_frequency_controller.dart';
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

  group('AdFrequencyController', () {
    test('canShow returns true when no prior shows', () {
      final controller = AdFrequencyController.banner();
      expect(controller.canShow(), isTrue);
    });

    test('canShow returns false when daily limit reached', () {
      final controller = AdFrequencyController.banner();
      final today = _todayString();

      when(() => mockBox.get('banner_lastDate')).thenReturn(today);
      when(() => mockBox.get('banner_todayCount')).thenReturn(50);

      expect(controller.canShow(), isFalse);
    });

    test('canShow returns false when min interval not elapsed', () {
      final controller = AdFrequencyController.banner();
      final now = DateTime.now();
      final today = _todayString();

      when(() => mockBox.get('banner_lastDate')).thenReturn(today);
      when(() => mockBox.get('banner_todayCount')).thenReturn(1);
      when(() => mockBox.get('banner_lastShow'))
          .thenReturn(now.millisecondsSinceEpoch);

      expect(controller.canShow(), isFalse);
    });

    test('canShow returns true when min interval elapsed', () {
      final controller = AdFrequencyController.banner();
      final today = _todayString();
      final old = DateTime.now().subtract(const Duration(minutes: 2));

      when(() => mockBox.get('banner_lastDate')).thenReturn(today);
      when(() => mockBox.get('banner_todayCount')).thenReturn(1);
      when(() => mockBox.get('banner_lastShow'))
          .thenReturn(old.millisecondsSinceEpoch);

      expect(controller.canShow(), isTrue);
    });

    test('recordShow increments todayCount', () {
      final controller = AdFrequencyController.banner();
      final today = _todayString();

      when(() => mockBox.get('banner_lastDate')).thenReturn(today);
      when(() => mockBox.get('banner_todayCount')).thenReturn(3);

      controller.recordShow();

      verify(() => mockBox.put('banner_todayCount', 4)).called(1);
      verify(() => mockBox.put('banner_lastDate', today)).called(1);
      verify(() => mockBox.put('banner_lastShow', any())).called(1);
    });

    test('recordShow resets count on new day', () {
      final controller = AdFrequencyController.banner();

      when(() => mockBox.get('banner_lastDate')).thenReturn('2026-05-19');
      when(() => mockBox.get('banner_todayCount')).thenReturn(10);

      controller.recordShow();

      verify(() => mockBox.put('banner_todayCount', 1)).called(1);
    });

    test('todayCount returns 0 when no data', () {
      final controller = AdFrequencyController.banner();
      expect(controller.todayCount, equals(0));
    });

    test('todayCount returns stored value for today', () {
      final controller = AdFrequencyController.banner();
      final today = _todayString();

      when(() => mockBox.get('banner_lastDate')).thenReturn(today);
      when(() => mockBox.get('banner_todayCount')).thenReturn(5);

      expect(controller.todayCount, equals(5));
    });

    test('timeUntilNextShow returns null when no prior show', () {
      final controller = AdFrequencyController.banner();
      expect(controller.timeUntilNextShow, isNull);
    });

    test('timeUntilNextShow returns remaining time', () {
      final controller = AdFrequencyController.banner();
      final recent = DateTime.now().subtract(const Duration(seconds: 10));

      when(() => mockBox.get('banner_lastShow'))
          .thenReturn(recent.millisecondsSinceEpoch);

      final remaining = controller.timeUntilNextShow;
      expect(remaining, isNotNull);
      expect(remaining!.inSeconds, greaterThan(15));
      expect(remaining.inSeconds, lessThanOrEqualTo(20));
    });

    test('interstitial factory has stricter defaults', () {
      final controller = AdFrequencyController.interstitial();
      expect(controller.dailyLimit, equals(20));
    });
  });
}

String _todayString() {
  final now = DateTime.now();
  return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
}
