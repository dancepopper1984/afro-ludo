import 'package:flutter_test/flutter_test.dart';
import 'package:afro_ludo_flutter/models/player.dart';
import 'package:afro_ludo_flutter/ui/notifiers/settings_notifier.dart';

void main() {
  group('SettingsNotifier', () {
    test('initial state is correct', () {
      final notifier = SettingsNotifier();
      expect(notifier.state.soundEnabled, true);
      expect(notifier.state.hapticsEnabled, true);
      expect(notifier.state.aiDifficulty, AIDifficulty.medium);
      expect(notifier.state.hasCompletedOnboarding, false);
      expect(notifier.state.language, 'en');
    });

    test('toggleSound flips sound setting', () {
      final notifier = SettingsNotifier();
      notifier.toggleSound();
      expect(notifier.state.soundEnabled, false);
      notifier.toggleSound();
      expect(notifier.state.soundEnabled, true);
    });

    test('toggleHaptics flips haptics setting', () {
      final notifier = SettingsNotifier();
      notifier.toggleHaptics();
      expect(notifier.state.hapticsEnabled, false);
    });

    test('setDifficulty changes AI difficulty', () {
      final notifier = SettingsNotifier();
      notifier.setDifficulty(AIDifficulty.hard);
      expect(notifier.state.aiDifficulty, AIDifficulty.hard);
    });

    test('completeOnboarding sets flag to true', () {
      final notifier = SettingsNotifier();
      notifier.completeOnboarding();
      expect(notifier.state.hasCompletedOnboarding, true);
    });

    test('setLanguage changes language code', () {
      final notifier = SettingsNotifier();
      notifier.setLanguage('fr');
      expect(notifier.state.language, 'fr');
    });
  });
}
