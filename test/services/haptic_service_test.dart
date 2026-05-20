import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:afro_ludo_flutter/services/haptic_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final haptic = HapticService();
  final List<MethodCall> log = [];

  setUp(() {
    haptic.hapticsEnabled = true;
    log.clear();

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
      log.add(call);
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  group('HapticService', () {
    test('hapticsEnabled defaults to true', () {
      expect(HapticService().hapticsEnabled, isTrue);
    });

    test('light() triggers platform call when enabled', () {
      haptic.light();
      expect(log.length, equals(1));
      expect(log.first.method, equals('HapticFeedback.vibrate'));
    });

    test('medium() triggers platform call when enabled', () {
      haptic.medium();
      expect(log.length, equals(1));
      expect(log.first.method, equals('HapticFeedback.vibrate'));
    });

    test('heavy() triggers platform call when enabled', () {
      haptic.heavy();
      expect(log.length, equals(1));
      expect(log.first.method, equals('HapticFeedback.vibrate'));
    });

    test('selection() triggers platform call when enabled', () {
      haptic.selection();
      expect(log.length, equals(1));
      expect(log.first.method, equals('HapticFeedback.vibrate'));
    });

    test('success() triggers platform call when enabled', () {
      haptic.success();
      expect(log.length, equals(1));
      expect(log.first.method, equals('HapticFeedback.vibrate'));
    });

    test('no platform calls when hapticsEnabled is false', () {
      haptic.hapticsEnabled = false;
      haptic.light();
      haptic.medium();
      haptic.heavy();
      haptic.selection();
      haptic.success();
      expect(log, isEmpty);
    });
  });
}
