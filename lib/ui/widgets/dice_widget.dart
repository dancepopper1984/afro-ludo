import 'dart:math';
import 'package:flutter/material.dart';

/// 骰子面绘制器
///
/// 绘制标准骰子的 1-6 点阵
class DiceFacePainter extends CustomPainter {
  final int value;
  final Color dotColor;
  final Color backgroundColor;

  DiceFacePainter({
    required this.value,
    Color? dotColor,
    Color? backgroundColor,
  })  : dotColor = dotColor ?? Colors.black,
      backgroundColor = backgroundColor ?? Colors.white;

  /// 各面值对应的点位置（3×3 网格坐标）
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
    // 画背景圆角矩形
    final bgPaint = Paint()..color = backgroundColor;
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(size.width * 0.15),
    );
    canvas.drawRRect(rect, bgPaint);

    // 画边框
    final borderPaint = Paint()
      ..color = Colors.black12
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(rect, borderPaint);

    // 画点
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

/// 骰子 Widget
///
/// 特性：
/// - 点击触发滚动动画
/// - 动画期间快速切换显示的面
/// - 动画结束后显示最终结果并回调
class DiceWidget extends StatefulWidget {
  final double size;
  final int? value;
  final bool isRolling;
  final VoidCallback? onTap;
  final ValueChanged<int>? onRollComplete;
  final Color? dotColor;
  final Color? backgroundColor;

  const DiceWidget({
    super.key,
    this.size = 64,
    this.value,
    this.isRolling = false,
    this.onTap,
    this.onRollComplete,
    this.dotColor,
    this.backgroundColor,
  });

  @override
  State<DiceWidget> createState() => _DiceWidgetState();
}

class _DiceWidgetState extends State<DiceWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final _random = Random();

  /// 动画期间显示的临时面值
  int _displayValue = 1;

  /// 最终滚动结果
  int? _finalValue;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
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

    // 外部触发滚动
    if (widget.isRolling && !oldWidget.isRolling) {
      _startRoll();
    }

    // 外部直接设置值（非滚动状态）
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

    // 动画前半段快速切换，后半段逐渐减慢
    int changeThreshold;
    if (progress < 0.3) {
      changeThreshold = 2; // 每 2 帧切换
    } else if (progress < 0.6) {
      changeThreshold = 4;
    } else if (progress < 0.8) {
      changeThreshold = 8;
    } else {
      changeThreshold = 16;
    }

    // 基于动画值计算是否切换显示
    final frame = (_controller.lastElapsedDuration?.inMilliseconds ?? 0) ~/ 16;
    if (frame % changeThreshold == 0) {
      setState(() {
        _displayValue = _random.nextInt(6) + 1;
      });
    }
  }

  void _onAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      // 动画结束，优先使用外部传入的值，否则回退到内部随机数
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
          // 滚动时添加轻微缩放和旋转效果
          final scale = widget.isRolling
              ? 1.0 + (_animation.value * 0.1 * sin(_animation.value * 20))
              : 1.0;
          final rotation = widget.isRolling
              ? _animation.value * 0.2 * sin(_animation.value * 15)
              : 0.0;

          return Transform.scale(
            scale: scale,
            child: Transform.rotate(
              angle: rotation,
              child: SizedBox(
                width: widget.size,
                height: widget.size,
                child: CustomPaint(
                  painter: DiceFacePainter(
                    value: _displayValue,
                    dotColor: widget.dotColor,
                    backgroundColor: widget.backgroundColor,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
