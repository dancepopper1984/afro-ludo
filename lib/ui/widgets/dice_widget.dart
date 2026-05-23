import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme.dart';

class DiceFacePainter extends CustomPainter {
  final int value;
  final Color dotColor;
  final Color backgroundColor;

  DiceFacePainter({
    required this.value,
    Color? dotColor,
    Color? backgroundColor,
  })  : dotColor = dotColor ?? const Color(0xFF1A1A2E),
      backgroundColor = backgroundColor ?? AfroTheme.accentGold;

  static const Map<int, List<(int, int)>> _dotPositions = {
    1: [(1, 1)],
    2: [(0, 0), (2, 2)],
    3: [(0, 0), (1, 1), (2, 2)],
    4: [(0, 0), (2, 0), (0, 2), (2, 2)],
    5: [(0, 0), (2, 0), (1, 1), (0, 2), (2, 2)],
    6: [(0, 0), (2, 0), (0, 1), (2, 1), (0, 2), (2, 2)],
  };

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = backgroundColor;
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(size.width * 0.15),
    );
    canvas.drawRRect(rect, bgPaint);

    final borderPaint = Paint()
      ..color = const Color(0xFFE6B800)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRRect(rect, borderPaint);

    final positions = _dotPositions[value];
    if (positions == null || positions.isEmpty) return;

    final dotRadius = size.width * 0.12;
    final cellSize = size.width / 3;
    final dotPaint = Paint()..color = dotColor;

    for (final (col, row) in positions) {
      final cx = (col + 0.5) * cellSize;
      final cy = (row + 0.5) * cellSize;
      canvas.drawCircle(Offset(cx, cy), dotRadius, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant DiceFacePainter oldDelegate) {
    return oldDelegate.value != value ||
        oldDelegate.dotColor != dotColor ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}

class DiceWidget extends StatefulWidget {
  final double size;
  final int? value;
  final bool isRolling;
  final VoidCallback? onTap;
  final ValueChanged<int>? onRollComplete;

  const DiceWidget({
    super.key,
    this.size = 64,
    this.value,
    this.isRolling = false,
    this.onTap,
    this.onRollComplete,
  });

  @override
  State<DiceWidget> createState() => _DiceWidgetState();
}

class _DiceWidgetState extends State<DiceWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final _random = Random();
  int _displayValue = 1;
  int? _finalValue;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _displayValue = widget.value ?? 1;
    _controller.addListener(_onAnimationFrame);
    _controller.addStatusListener(_onAnimationStatus);
  }

  @override
  void didUpdateWidget(covariant DiceWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRolling && !oldWidget.isRolling) {
      _startRoll();
    }
    if (!widget.isRolling && widget.value != null) {
      _displayValue = widget.value!;
    }
  }

  void _startRoll() {
    _finalValue = null;
    _controller.forward(from: 0);
  }

  void _onAnimationFrame() {
    if (!mounted) return;
    final progress = _animation.value;
    int changeThreshold;
    if (progress < 0.3) {
      changeThreshold = 2;
    } else if (progress < 0.6) {
      changeThreshold = 4;
    } else if (progress < 0.8) {
      changeThreshold = 8;
    } else {
      changeThreshold = 16;
    }
    final frame =
        (_controller.lastElapsedDuration?.inMilliseconds ?? 0) ~/ 16;
    if (frame % changeThreshold == 0) {
      setState(() {
        _displayValue = _random.nextInt(6) + 1;
      });
    }
  }

  void _onAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      final result = widget.value ?? _finalValue ?? (_random.nextInt(6) + 1);
      setState(() {
        _displayValue = result;
      });
      widget.onRollComplete?.call(result);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.isRolling) return;
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final scale = widget.isRolling
              ? 1.0 + (_animation.value * 0.15 * sin(_animation.value * 20))
              : 1.0;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(0, 0, scale)
              ..setEntry(1, 1, scale)
              ..rotateY(_animation.value * 4 * pi),
            child: SizedBox(
              width: widget.size,
              height: widget.size,
              child: CustomPaint(
                painter: DiceFacePainter(
                  value: _displayValue,
                  dotColor: const Color(0xFF1A1A2E),
                  backgroundColor: AfroTheme.accentGold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
