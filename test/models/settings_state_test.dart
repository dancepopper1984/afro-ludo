import 'package:flutter_test/flutter_test.dart';
import 'package:afro_ludo_flutter/models/settings_state.dart';
import 'package:afro_ludo_flutter/models/player.dart';

void main() {
  group('SettingsState', () {
    test('initial state has correct defaults', () {
      final state = SettingsState.initial();

      expect(state.soundEnabled, true);
      expect(state.hapticsEnabled, true);
      expect(state.aiDifficulty, AIDifficulty.medium);
      expect(state.hasCompletedOnboarding, false);
      expect(state.language, 'en');
    });

    test('copyWith changes only specified field', () {
      final state = SettingsState.initial();
      final updated = state.copyWith(soundEnabled: false);

      expect(updated.soundEnabled, false);
      expect(updated.hapticsEnabled, state.hapticsEnabled);
      expect(updated.aiDifficulty, state.aiDifficulty);
    });

    test('copyWith does not mutate original', () {
      final state = SettingsState.initial();
      final updated = state.copyWith(language: 'ha');

      expect(state.language, 'en');
      expect(updated.language, 'ha');
    });

    test('can change ai difficulty', () {
      final state = SettingsState.initial();
      final hard = state.copyWith(aiDifficulty: AIDifficulty.hard);
      final easy = state.copyWith(aiDifficulty: AIDifficulty.easy);

      expect(hard.aiDifficulty, AIDifficulty.hard);
      expect(easy.aiDifficulty, AIDifficulty.easy);
    });

    test('onboarding completion flag', () {
      final state = SettingsState.initial();
      final completed = state.copyWith(hasCompletedOnboarding: true);

      expect(completed.hasCompletedOnboarding, true);
    });

    test('two identical states are equal', () {
      final a = SettingsState.initial();
      final b = SettingsState.initial();

      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('states with different settings are not equal', () {
      final a = SettingsState.initial();
      final b = a.copyWith(soundEnabled: false);

      expect(a, isNot(b));
    });
  });
}
