import 'package:flutter_test/flutter_test.dart';
import 'package:afro_ludo_flutter/core/performance_manager.dart';

FrameMetrics _createTiming(int totalMicros) {
  final buildFinish = (totalMicros * 0.3).round();
  return FrameMetrics(
    buildDuration: Duration(microseconds: buildFinish),
    rasterDuration: Duration(microseconds: totalMicros - buildFinish),
    totalSpan: Duration(microseconds: totalMicros),
  );
}

void main() {
  final manager = PerformanceManager();

  setUp(() {
    manager.stopMonitoring();
    manager.reset();
  });

  group('PerformanceManager', () {
    test('is singleton', () {
      expect(PerformanceManager(), same(PerformanceManager()));
    });

    test('isMonitoring is false by default', () {
      expect(manager.isMonitoring, isFalse);
    });

    test('startMonitoring sets isMonitoring to true', () {
      manager.startMonitoring();
      expect(manager.isMonitoring, isTrue);
    });

    test('stopMonitoring sets isMonitoring to false', () {
      manager.startMonitoring();
      manager.stopMonitoring();
      expect(manager.isMonitoring, isFalse);
    });

    test('recordMetrics ignores when not monitoring', () {
      final timing = _createTiming(16667);
      manager.recordMetrics([timing]);
      expect(manager.totalFramesRecorded, equals(0));
    });

    test('recordMetrics records when monitoring', () {
      manager.startMonitoring();
      final timing = _createTiming(16667);
      manager.recordMetrics([timing]);
      expect(manager.totalFramesRecorded, equals(1));
    });

    test('totalFramesRecorded counts multiple frames', () {
      manager.startMonitoring();
      manager.recordMetrics([
        _createTiming(10000),
        _createTiming(15000),
        _createTiming(20000),
      ]);
      expect(manager.totalFramesRecorded, equals(3));
    });

    test('droppedFramesCount counts frames > 16.67ms', () {
      manager.startMonitoring();
      manager.recordMetrics([
        _createTiming(10000), // 10ms - smooth
        _createTiming(16667), // 16.67ms - boundary, not dropped
        _createTiming(20000), // 20ms - dropped
        _createTiming(50000), // 50ms - dropped
      ]);
      expect(manager.droppedFramesCount, equals(2));
    });

    test('averageFrameTimeMs calculates correctly', () {
      manager.startMonitoring();
      manager.recordMetrics([
        _createTiming(10000), // 10ms
        _createTiming(20000), // 20ms
      ]);
      expect(manager.averageFrameTimeMs, closeTo(15.0, 0.1));
    });

    test('averageFps calculates correctly for smooth frames', () {
      manager.startMonitoring();
      manager.recordMetrics([
        _createTiming(16667),
        _createTiming(16667),
        _createTiming(16667),
      ]);
      expect(manager.averageFps, closeTo(60.0, 1.0));
    });

    test('averageFps is null when no frames recorded', () {
      expect(manager.averageFps, isNull);
    });

    test('averageFrameTimeMs is null when no frames recorded', () {
      expect(manager.averageFrameTimeMs, isNull);
    });

    test('reset clears all data', () {
      manager.startMonitoring();
      manager.recordMetrics([
        _createTiming(20000),
        _createTiming(30000),
      ]);
      expect(manager.totalFramesRecorded, greaterThan(0));

      manager.reset();

      expect(manager.totalFramesRecorded, equals(0));
      expect(manager.droppedFramesCount, equals(0));
      expect(manager.averageFps, isNull);
      expect(manager.averageFrameTimeMs, isNull);
    });

    test('reset preserves monitoring state', () {
      manager.startMonitoring();
      manager.reset();
      expect(manager.isMonitoring, isTrue);
    });

    test('max stored frames is limited to 120', () {
      manager.startMonitoring();
      final frames = List.generate(
        150,
        (_) => _createTiming(16667),
      );
      manager.recordMetrics(frames);
      expect(manager.totalFramesRecorded, equals(120));
    });
  });
}
