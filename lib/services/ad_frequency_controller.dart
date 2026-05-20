import '../services/storage_service.dart';

/// 广告频次控制器
///
/// 控制广告的展示频率，防止过度展示导致用户流失。
/// 支持：最小间隔时间、每日上限、持久化到本地存储。
///
/// 使用方式：
/// ```dart
/// final controller = AdFrequencyController.banner();
/// if (controller.canShow()) {
///   // 展示广告
///   controller.recordShow();
/// }
/// ```
class AdFrequencyController {
  final String _storageKeyPrefix;
  final Duration minInterval;
  final int dailyLimit;

  AdFrequencyController({
    required String storageKeyPrefix,
    this.minInterval = const Duration(minutes: 1),
    this.dailyLimit = 20,
  }) : _storageKeyPrefix = storageKeyPrefix;

  /// Banner 广告默认配置
  factory AdFrequencyController.banner() => AdFrequencyController(
        storageKeyPrefix: 'banner',
        minInterval: const Duration(seconds: 30),
        dailyLimit: 50,
      );

  /// 插页广告默认配置
  factory AdFrequencyController.interstitial() => AdFrequencyController(
        storageKeyPrefix: 'interstitial',
        minInterval: const Duration(minutes: 3),
        dailyLimit: 20,
      );

  String get _lastShowKey => '${_storageKeyPrefix}_lastShow';
  String get _todayCountKey => '${_storageKeyPrefix}_todayCount';
  String get _lastDateKey => '${_storageKeyPrefix}_lastDate';

  /// 检查当前是否可以展示广告
  bool canShow() {
    final today = _todayString();
    final lastDate = StorageService.getString(_lastDateKey);

    int todayCount;
    if (lastDate == today) {
      todayCount = StorageService.getInt(_todayCountKey) ?? 0;
    } else {
      todayCount = 0;
    }

    // 检查每日上限
    if (todayCount >= dailyLimit) return false;

    // 检查最小间隔
    final lastShowMillis = StorageService.getInt(_lastShowKey);
    if (lastShowMillis != null) {
      final lastShow = DateTime.fromMillisecondsSinceEpoch(lastShowMillis);
      final elapsed = DateTime.now().difference(lastShow);
      if (elapsed < minInterval) return false;
    }

    return true;
  }

  /// 记录一次广告展示
  void recordShow() {
    final now = DateTime.now();
    final today = _todayString();
    final lastDate = StorageService.getString(_lastDateKey);

    int todayCount;
    if (lastDate == today) {
      todayCount = (StorageService.getInt(_todayCountKey) ?? 0) + 1;
    } else {
      todayCount = 1;
    }

    StorageService.setInt(_lastShowKey, now.millisecondsSinceEpoch);
    StorageService.setInt(_todayCountKey, todayCount);
    StorageService.setString(_lastDateKey, today);
  }

  /// 今日已展示次数
  int get todayCount {
    final today = _todayString();
    final lastDate = StorageService.getString(_lastDateKey);
    if (lastDate != today) return 0;
    return StorageService.getInt(_todayCountKey) ?? 0;
  }

  /// 距离下次可展示的剩余时间（null 表示现在就可以展示）
  Duration? get timeUntilNextShow {
    final lastShowMillis = StorageService.getInt(_lastShowKey);
    if (lastShowMillis == null) return null;

    final lastShow = DateTime.fromMillisecondsSinceEpoch(lastShowMillis);
    final elapsed = DateTime.now().difference(lastShow);
    if (elapsed >= minInterval) return null;

    return minInterval - elapsed;
  }

  static String _todayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}
