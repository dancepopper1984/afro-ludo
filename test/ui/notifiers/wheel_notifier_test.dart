import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';
import 'package:afro_ludo_flutter/core/wheel_rewards.dart';
import 'package:afro_ludo_flutter/services/storage_service.dart';
import 'package:afro_ludo_flutter/ui/notifiers/wheel_notifier.dart';

class MockBox extends Mock implements Box {}

class FakeRandom extends Fake implements Random {
  final double Function() nextDoubleFn;
  FakeRandom(this.nextDoubleFn);

  @override
  double nextDouble() => nextDoubleFn();
}

void main() {
  late MockBox mockBox;

  setUp(() {
    mockBox = MockBox();
    StorageService.setBox(mockBox);
    when(() => mockBox.get(any())).thenReturn(null);
    when(() => mockBox.put(any(), any())).thenAnswer((_) async {});
  });

  group('WheelNotifier', () {
    test('initial state allows free spin when no prior spin', () {
      final notifier = WheelNotifier();
      expect(notifier.state.canSpinFree, isTrue);
      expect(notifier.state.canSpin, isTrue);
    });

    test('free spin consumed after spinning', () {
      final notifier = WheelNotifier();
      final reward = notifier.spin();
      expect(reward, isNotNull);
      expect(notifier.state.canSpinFree, isFalse);
      expect(notifier.state.status, equals(WheelStatus.done));
    });

    test('cannot spin twice without ad spins', () {
      final notifier = WheelNotifier();
      notifier.spin();
      notifier.reset();
      final reward = notifier.spin();
      expect(reward, isNull);
    });

    test('can spin with ad spins after free used', () {
      final notifier = WheelNotifier();
      notifier.spin(); // use free
      notifier.reset();
      notifier.addAdSpin();
      expect(notifier.state.canSpinAd, isTrue);

      final reward = notifier.spin();
      expect(reward, isNotNull);
      expect(notifier.state.adSpinsAvailable, equals(0));
    });

    test('addAdSpin increases available count', () {
      final notifier = WheelNotifier();
      expect(notifier.state.adSpinsAvailable, equals(0));
      notifier.addAdSpin();
      expect(notifier.state.adSpinsAvailable, equals(1));
      notifier.addAdSpin();
      expect(notifier.state.adSpinsAvailable, equals(2));
    });

    test('spin writes lastSpinDate to storage', () {
      final notifier = WheelNotifier();
      notifier.spin();
      verify(() => mockBox.put('lastSpinDate', any())).called(1);
    });

    test('cannot spin while already spinning', () {
      final notifier = WheelNotifier();
      // Force spinning state without completing
      notifier.state = notifier.state.copyWith(status: WheelStatus.spinning);
      final reward = notifier.spin();
      expect(reward, isNull);
    });

    test('reset clears last reward and sets idle', () {
      final notifier = WheelNotifier();
      notifier.spin();
      expect(notifier.state.status, equals(WheelStatus.done));
      expect(notifier.state.lastReward, isNotNull);

      notifier.reset();
      expect(notifier.state.status, equals(WheelStatus.idle));
      expect(notifier.state.lastReward, isNull);
    });

    test('selectReward returns first item when random is 0', () {
      final notifier = WheelNotifier(random: FakeRandom(() => 0));
      final reward = notifier.spin();
      expect(reward?.label, equals('10'));
    });

    test('selectReward returns last item when random is near 1', () {
      final notifier = WheelNotifier(
        random: FakeRandom(() => 0.9999),
      );
      final reward = notifier.spin();
      expect(reward?.label, equals('500'));
    });

    test('selectReward returns correct item at weight boundary', () {
      // 25 weight for '10', next is '20' at 20 weight.
      // Random value * totalWeight just above 25 => '20'
      final totalWeight = WheelRewards.totalWeight;
      final threshold = 25.0 / totalWeight; // boundary for '10'
      final notifier = WheelNotifier(
        random: FakeRandom(() => threshold + 0.0001),
      );
      final reward = notifier.spin();
      expect(reward?.label, equals('20'));
    });
  });
}
