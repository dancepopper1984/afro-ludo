import 'dart:math' as math;
import 'package:flutter/material.dart';

class AdinkraPainter extends CustomPainter {
  final String symbol;
  final Color color;
  final double strokeWidth;

  AdinkraPainter({
    required this.symbol,
    required this.color,
    this.strokeWidth = 2.5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    switch (symbol) {
      case 'fawohodie':
        _drawFawohodie(canvas, size, paint, fillPaint);
      case 'gye_nyame':
        _drawGyeNyame(canvas, size, paint, fillPaint);
      case 'nkyinkyim':
        _drawNkyinkyim(canvas, size, paint, fillPaint);
    }
  }

  void _drawFawohodie(Canvas canvas, Size size, Paint paint, Paint fill) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.35;

    // 外圆
    canvas.drawCircle(Offset(cx, cy), r, paint);

    // 十字线
    canvas.drawLine(
      Offset(cx - r, cy),
      Offset(cx + r, cy),
      paint,
    );
    canvas.drawLine(
      Offset(cx, cy - r),
      Offset(cx, cy + r),
      paint,
    );

    // 四个 L 形角
    final l = r * 0.4;
    final corners = [
      (Offset(cx - r, cy - r), false, false),
      (Offset(cx + r, cy - r), true, false),
      (Offset(cx - r, cy + r), false, true),
      (Offset(cx + r, cy + r), true, true),
    ];

    for (final (origin, flipX, flipY) in corners) {
      final dx = flipX ? -l : l;
      final dy = flipY ? -l : l;
      final path = Path()
        ..moveTo(origin.dx, origin.dy)
        ..lineTo(origin.dx + dx, origin.dy)
        ..moveTo(origin.dx, origin.dy)
        ..lineTo(origin.dx, origin.dy + dy);
      canvas.drawPath(path, paint);
    }
  }

  void _drawGyeNyame(Canvas canvas, Size size, Paint paint, Paint fill) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.35;

    // 螺旋圆环
    const turns = 4;
    const points = 80;
    final path = Path();
    for (int i = 0; i <= points; i++) {
      final t = i / points;
      final angle = 2 * math.pi * turns * t;
      final radius = r * (0.4 + 0.6 * t);
      final x = cx + radius * math.cos(angle);
      final y = cy + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);

    // 中心点
    canvas.drawCircle(Offset(cx, cy), r * 0.15, fill);
  }

  void _drawNkyinkyim(Canvas canvas, Size size, Paint paint, Paint fill) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final w = size.width * 0.7;
    final h = size.height * 0.5;

    // 锯齿波浪线
    final path = Path();
    const waves = 5;
    final startX = cx - w / 2;
    path.moveTo(startX, cy);

    for (int i = 0; i < waves; i++) {
      final x1 = startX + (w / waves) * (i + 0.5);
      final x2 = startX + (w / waves) * (i + 1);
      final up = i.isEven;
      path.lineTo(x1, up ? cy - h / 2 : cy + h / 2);
      path.lineTo(x2, cy);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant AdinkraPainter oldDelegate) =>
      oldDelegate.symbol != symbol ||
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth;
}
