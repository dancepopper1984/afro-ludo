import 'package:hive_flutter/hive_flutter.dart';

/// 本地存储服务
///
/// 基于 Hive 的键值存储，用于持久化：
/// - 设置（音效、震动、AI 难度、语言、新手引导）
/// - 经济状态（金币、签到记录）
class StorageService {
  static const String _boxName = 'afro_ludo';
  static Box? _box;

  StorageService._();

  /// 初始化 Hive（在 main.dart 中调用）
  static Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(_boxName);
  }

  static Box get _ensureBox {
    if (_box == null) {
      throw StateError('StorageService not initialized. Call StorageService.init() first.');
    }
    return _box!;
  }

  // === Settings ===

  static bool? getSoundEnabled() => _ensureBox.get('soundEnabled') as bool?;
  static Future<void> setSoundEnabled(bool value) => _ensureBox.put('soundEnabled', value);

  static bool? getHapticsEnabled() => _ensureBox.get('hapticsEnabled') as bool?;
  static Future<void> setHapticsEnabled(bool value) => _ensureBox.put('hapticsEnabled', value);

  static String? getDifficulty() => _ensureBox.get('aiDifficulty') as String?;
  static Future<void> setDifficulty(String value) => _ensureBox.put('aiDifficulty', value);

  static bool? getHasCompletedOnboarding() => _ensureBox.get('hasCompletedOnboarding') as bool?;
  static Future<void> setHasCompletedOnboarding(bool value) =>
      _ensureBox.put('hasCompletedOnboarding', value);

  static String? getLanguage() => _ensureBox.get('language') as String?;
  static Future<void> setLanguage(String value) => _ensureBox.put('language', value);

  // === Economy ===

  static int? getAfroCoins() => _ensureBox.get('afroCoins') as int?;
  static Future<void> setAfroCoins(int value) => _ensureBox.put('afroCoins', value);

  static int? getTotalEarned() => _ensureBox.get('totalEarned') as int?;
  static Future<void> setTotalEarned(int value) => _ensureBox.put('totalEarned', value);

  static int? getDailyEarned() => _ensureBox.get('dailyEarned') as int?;
  static Future<void> setDailyEarned(int value) => _ensureBox.put('dailyEarned', value);

  static String? getLastLoginDate() => _ensureBox.get('lastLoginDate') as String?;
  static Future<void> setLastLoginDate(String? value) => _ensureBox.put('lastLoginDate', value);

  static int? getLoginStreak() => _ensureBox.get('loginStreak') as int?;
  static Future<void> setLoginStreak(int value) => _ensureBox.put('loginStreak', value);

  // === Age Verification ===

  static bool? getAgeVerified() => _ensureBox.get('ageVerified') as bool?;
  static Future<void> setAgeVerified(bool value) => _ensureBox.put('ageVerified', value);

  // === Leaderboard / Stats ===

  static int? getTotalWins() => _ensureBox.get('totalWins') as int?;
  static Future<void> setTotalWins(int value) => _ensureBox.put('totalWins', value);

  static int? getTotalLosses() => _ensureBox.get('totalLosses') as int?;
  static Future<void> setTotalLosses(int value) => _ensureBox.put('totalLosses', value);

  static int? getBestStreak() => _ensureBox.get('bestStreak') as int?;
  static Future<void> setBestStreak(int value) => _ensureBox.put('bestStreak', value);

  static int? getCurrentStreak() => _ensureBox.get('currentStreak') as int?;
  static Future<void> setCurrentStreak(int value) => _ensureBox.put('currentStreak', value);

  // === Skins ===

  static String? getActiveSkin() => _ensureBox.get('activeSkin') as String?;
  static Future<void> setActiveSkin(String value) => _ensureBox.put('activeSkin', value);

  static List<String>? getUnlockedSkins() {
    final raw = _ensureBox.get('unlockedSkins');
    if (raw == null) return null;
    return (raw as List).cast<String>();
  }

  static Future<void> setUnlockedSkins(List<String> values) =>
      _ensureBox.put('unlockedSkins', values);
}
