import 'dart:collection';
import 'package:flutter/scheduler.dart';

/// 帧性能指标
///
/// 封装单帧的耗时数据，与 Flutter [FrameTiming] 解耦以便测试。
class FrameMetrics {
  final Duration buildDuration;
  final Duration rasterDuration;
  final Duration totalSpan;

  const FrameMetrics({
    required this.buildDuration,
    required this.rasterDuration,
    required this.totalSpan,
  });

  /// 从 Flutter [FrameTiming] 转换
  factory FrameMetrics.fromTiming(FrameTiming timing) => FrameMetrics(
        buildDuration: timing.buildDuration,
        rasterDuration: timing.rasterDuration,
        totalSpan: timing.totalSpan,
      );
}

/// 性能管理器
///
/// 监控应用帧率（FPS）和帧耗时，帮助识别性能瓶颈。
/// 通过 [SchedulerBinding.addTimingsCallback] 接入 Flutter 引擎的帧时序数据。
///
/// 使用方式：
/// ```dart
/// PerformanceManager().startMonitoring();
/// // 在合适的时机（如页面dispose）
/// PerformanceManager().stopMonitoring();
/// ```
class PerformanceManager {
  static final PerformanceManager _instance = PerformanceManager._internal();
  factory PerformanceManager() => _instance;
  PerformanceManager._internal();

  bool _isMonitoring = false;
  final Queue<FrameMetrics> _frames = Queue<FrameMetrics>();
  static const int _maxStoredFrames = 120;
  static const double _frameBudgetUs = 16667; // ~16.67ms for 60 FPS

  /// 是否正在监控性能
  bool get isMonitoring => _isMonitoring;

  /// 开始监控
  void startMonitoring() => _isMonitoring = true;

  /// 停止监控
  void stopMonitoring() => _isMonitoring = false;

  /// 接收 Flutter 引擎的帧时序数据
  ///
  /// 直接绑定到 [SchedulerBinding.addTimingsCallback]：
 /// ```dart
 /// SchedulerBinding.instance.addTimingsCallback(
 ///   PerformanceManager().onFrameTimings,
 /// );
 /// ```
  void onFrameTimings(List<FrameTiming> timings) {
    if (!_isMonitoring) return;
    _recordFrames(timings.map(FrameMetrics.fromTiming));
  }

  /// 接收自定义帧指标（主要用于测试）
  void recordMetrics(List<FrameMetrics> metrics) {
    if (!_isMonitoring) return;
    _recordFrames(metrics);
  }

  void _recordFrames(Iterable<FrameMetrics> frames) {
    for (final frame in frames) {
      _frames.add(frame);
    }
    while (_frames.length > _maxStoredFrames) {
      _frames.removeFirst();
    }
  }

  /// 已记录的帧数
  int get totalFramesRecorded => _frames.length;

  /// 掉帧数（帧耗时超过 16.67ms 的帧）
  int get droppedFramesCount {
    var count = 0;
    for (final frame in _frames) {
      if (frame.totalSpan.inMicroseconds > _frameBudgetUs) {
        count++;
      }
    }
    return count;
  }

  /// 平均帧耗时（毫秒），无数据时返回 null
  double? get averageFrameTimeMs {
    if (_frames.isEmpty) return null;
    final totalMicros = _frames.fold<int>(
      0,
      (sum, f) => sum + f.totalSpan.inMicroseconds,
    );
    return totalMicros / _frames.length / 1000.0;
  }

  /// 平均 FPS，无数据时返回 null
  double? get averageFps {
    if (_frames.isEmpty) return null;
    final avgMs = averageFrameTimeMs!;
    if (avgMs <= 0) return null;
    return 1000.0 / avgMs;
  }

  /// 重置所有统计数据
  void reset() {
    _frames.clear();
  }
}
