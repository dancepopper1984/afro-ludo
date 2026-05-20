import 'player.dart';

/// 设置状态
class SettingsState {
  final bool soundEnabled;
  final bool hapticsEnabled;
  final AIDifficulty aiDifficulty;
  final bool hasCompletedOnboarding;
  final String language;

  const SettingsState({
    required this.soundEnabled,
    required this.hapticsEnabled,
    required this.aiDifficulty,
    required this.hasCompletedOnboarding,
    required this.language,
  });

  factory SettingsState.initial() {
    return const SettingsState(
      soundEnabled: true,
      hapticsEnabled: true,
      aiDifficulty: AIDifficulty.medium,
      hasCompletedOnboarding: false,
      language: 'en',
    );
  }

  SettingsState copyWith({
    bool? soundEnabled,
    bool? hapticsEnabled,
    AIDifficulty? aiDifficulty,
    bool? hasCompletedOnboarding,
    String? language,
  }) {
    return SettingsState(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      aiDifficulty: aiDifficulty ?? this.aiDifficulty,
      hasCompletedOnboarding: hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      language: language ?? this.language,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettingsState &&
          runtimeType == other.runtimeType &&
          soundEnabled == other.soundEnabled &&
          hapticsEnabled == other.hapticsEnabled &&
          aiDifficulty == other.aiDifficulty &&
          hasCompletedOnboarding == other.hasCompletedOnboarding &&
          language == other.language;

  @override
  int get hashCode => Object.hash(
        soundEnabled,
        hapticsEnabled,
        aiDifficulty,
        hasCompletedOnboarding,
        language,
      );

  @override
  String toString() =>
      'SettingsState(sound: $soundEnabled, haptics: $hapticsEnabled, difficulty: $aiDifficulty, lang: $language)';
}
