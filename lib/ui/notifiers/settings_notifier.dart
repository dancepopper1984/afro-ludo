import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/player.dart';
import '../../models/settings_state.dart';
import '../../services/audio_service.dart';
import '../../services/haptic_service.dart';
import '../../services/storage_service.dart';

/// 设置状态管理器
///
/// 状态变更自动持久化到 Hive。
class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(_loadFromStorage());

  static SettingsState _loadFromStorage() {
    try {
      return SettingsState(
        soundEnabled: StorageService.getSoundEnabled() ?? true,
        hapticsEnabled: StorageService.getHapticsEnabled() ?? true,
        aiDifficulty: _parseDifficulty(StorageService.getDifficulty()),
        hasCompletedOnboarding: StorageService.getHasCompletedOnboarding() ?? false,
        language: StorageService.getLanguage() ?? 'en',
      );
    } catch (_) {
      return SettingsState.initial();
    }
  }

  static AIDifficulty _parseDifficulty(String? value) {
    return switch (value) {
      'easy' => AIDifficulty.easy,
      'hard' => AIDifficulty.hard,
      _ => AIDifficulty.medium,
    };
  }

  void _save(void Function() write) {
    try {
      write();
    } catch (_) {
      // StorageService not initialized (e.g., in tests) — skip saving
    }
  }

  void toggleSound() {
    state = state.copyWith(soundEnabled: !state.soundEnabled);
    AudioService().soundEnabled = state.soundEnabled;
    _save(() => StorageService.setSoundEnabled(state.soundEnabled));
  }

  void toggleHaptics() {
    state = state.copyWith(hapticsEnabled: !state.hapticsEnabled);
    HapticService().hapticsEnabled = state.hapticsEnabled;
    _save(() => StorageService.setHapticsEnabled(state.hapticsEnabled));
  }

  void setDifficulty(AIDifficulty difficulty) {
    state = state.copyWith(aiDifficulty: difficulty);
    _save(() => StorageService.setDifficulty(difficulty.name));
  }

  void completeOnboarding() {
    state = state.copyWith(hasCompletedOnboarding: true);
    _save(() => StorageService.setHasCompletedOnboarding(true));
  }

  void setLanguage(String language) {
    state = state.copyWith(language: language);
    _save(() => StorageService.setLanguage(language));
  }
}

/// SettingsNotifier Provider
final settingsNotifierProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});
