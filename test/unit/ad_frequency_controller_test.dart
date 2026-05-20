import 'package:flutter_test/flutter_test.dart';
import '../../lib/services/ad_frequency_controller.dart';

void main() {
  group('AdFrequencyController', () {
    test('banner factory uses correct defaults', () {
      final banner = AdFrequencyController.banner();
      expect(banner.dailyLimit, 50);
    });

    test('interstitial factory uses correct defaults', () {
      final interstitial = AdFrequencyController.interstitial();
      expect(interstitial.dailyLimit, 20);
    });

    test('constructor accepts custom values', () {
      final controller = AdFrequencyController(
        storageKeyPrefix: 'test',
        minInterval: const Duration(seconds: 5),
        dailyLimit: 10,
      );
      expect(controller.dailyLimit, 10);
    });
  });
}
