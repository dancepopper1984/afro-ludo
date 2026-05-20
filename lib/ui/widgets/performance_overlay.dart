import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../../core/performance_manager.dart';

class PerformanceOverlay extends StatefulWidget {
  final Widget child;

  const PerformanceOverlay({super.key, required this.child});

  @override
  State<PerformanceOverlay> createState() => _PerformanceOverlayState();
}

class _PerformanceOverlayState extends State<PerformanceOverlay>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  final _manager = PerformanceManager();

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((_) => setState(() {}));
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return widget.child;

    final fps = _manager.averageFps;
    final avgMs = _manager.averageFrameTimeMs;
    final dropped = _manager.droppedFramesCount;
    final total = _manager.totalFramesRecorded;

    return Stack(
      children: [
        widget.child,
        Positioned(
          top: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.7),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(8),
              ),
            ),
            child: DefaultTextStyle(
              style: const TextStyle(color: Colors.white, fontSize: 11, fontFamily: 'monospace'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'FPS: ${fps?.toStringAsFixed(0) ?? "--"}',
                    style: TextStyle(
                      color: (fps ?? 0) >= 55
                          ? Colors.greenAccent
                          : (fps ?? 0) >= 30
                              ? Colors.amberAccent
                              : Colors.redAccent,
                    ),
                  ),
                  if (avgMs != null)
                    Text('${avgMs.toStringAsFixed(1)}ms'),
                  Text('Drop: $dropped/$total'),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
