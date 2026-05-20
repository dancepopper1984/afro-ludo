// Dart 扩展方法

extension DateTimeExtensions on DateTime {
  /// 转为日期字符串（YYYY-MM-DD）
  String toDateString() {
    return '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
  }

  /// 是否同一天
  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  /// 是否为今天
  bool get isToday {
    final now = DateTime.now();
    return isSameDay(now);
  }

  /// 是否为昨天
  bool get isYesterday {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    return isSameDay(yesterday);
  }
}

extension IntExtensions on int {
  /// 限制在 [min, max] 范围内
  int clampInt(int min, int max) {
    if (this < min) return min;
    if (this > max) return max;
    return this;
  }
}

extension ListExtensions<T> on List<T> {
  /// 安全获取元素，越界返回 null
  T? getOrNull(int index) {
    if (index < 0 || index >= length) return null;
    return this[index];
  }
}
