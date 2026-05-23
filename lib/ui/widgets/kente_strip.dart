import 'package:flutter/material.dart';
import '../../core/theme.dart';

class KenteStrip extends StatefulWidget {
  final double height;
  final bool animate;
  final List<Color>? colors;
  final double segmentWidth;

  const KenteStrip({
    super.key,
    this.height = 6,
    this.animate = false,
    this.colors,
    this.segmentWidth = 28,
  });

  @override
  State<KenteStrip> createState() => _KenteStripState();
}

class _KenteStripState extends State<KenteStrip>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _animation;

  @override
  void initState() {
    super.initState();
    if (widget.animate) {
      _controller = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 10),
      )..repeat();
      _animation = Tween<double>(begin: 0, end: 1).animate(_controller!);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors ?? AfroTheme.kenteColors;
    final totalWidth = colors.length * widget.segmentWidth;

    if (widget.animate && _animation != null) {
      return SizedBox(
        height: widget.height,
        child: RepaintBoundary(
          child: AnimatedBuilder(
            animation: _animation!,
            builder: (context, child) {
              return CustomPaint(
                painter: _KentePainter(
                  colors: colors,
                  segmentWidth: widget.segmentWidth,
                  offset: _animation!.value * totalWidth,
                ),
                size: Size(double.infinity, widget.height),
              );
            },
          ),
        ),
      );
    }

    return SizedBox(
      height: widget.height,
      child: RepaintBoundary(
        child: CustomPaint(
          painter: _KentePainter(
            colors: colors,
            segmentWidth: widget.segmentWidth,
            offset: 0,
          ),
          size: Size(double.infinity, widget.height),
        ),
      ),
    );
  }
}

class _KentePainter extends CustomPainter {
  final List<Color> colors;
  final double segmentWidth;
  final double offset;

  _KentePainter({
    required this.colors,
    required this.segmentWidth,
    required this.offset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final totalWidth = colors.length * segmentWidth;
    double x = -(offset % totalWidth);

    while (x < size.width) {
      for (final color in colors) {
        canvas.drawRect(
          Rect.fromLTWH(x, 0, segmentWidth, size.height),
          Paint()..color = color,
        );
        x += segmentWidth;
      }
    }

    // 上下边框
    final borderPaint = Paint()
      ..color = colors.first.withValues(alpha: 0.6)
      ..strokeWidth = 0.5;
    canvas.drawLine(Offset(0, 0), Offset(size.width, 0), borderPaint);
    canvas.drawLine(
      Offset(0, size.height),
      Offset(size.width, size.height),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _KentePainter oldDelegate) =>
      oldDelegate.offset != offset;
}
