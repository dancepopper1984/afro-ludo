import 'dart:math' as math;
import 'package:flutter/material.dart';

class ConfettiAnimation extends StatefulWidget {
  final int particleCount;
  final List<Color> colors;
  final double particleSize;

  const ConfettiAnimation({
    super.key,
    this.particleCount = 40,
    this.colors = const [
      Color(0xFFFFD700),
      Color(0xFFFF6B35),
      Color(0xFF1A9D3E),
      Color(0xFFE63946),
      Color(0xFF9B59B6),
    ],
    this.particleSize = 8,
  });

  @override
  State<ConfettiAnimation> createState() => _ConfettiAnimationState();
}

class _ConfettiAnimationState extends State<ConfettiAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Particle> _particles;
  final _random = math.Random(42);

  @override
  void initState() {
    super.initState();
    _particles = List.generate(widget.particleCount, (i) {
      return _Particle(
        x: _random.nextDouble(),
        y: -_random.nextDouble() * 0.3,
        rotation: _random.nextDouble() * 2 * math.pi,
        speedX: (_random.nextDouble() - 0.5) * 0.3,
        speedY: 0.3 + _random.nextDouble() * 0.5,
        rotationSpeed: (_random.nextDouble() - 0.5) * 6,
        color: widget.colors[_random.nextInt(widget.colors.length)],
        size: widget.particleSize * (0.5 + _random.nextDouble() * 0.5),
      );
    });

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          painter: _ConfettiPainter(
            particles: _particles,
            progress: _controller.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _Particle {
  final double x;
  double y;
  double rotation;
  final double speedX;
  final double speedY;
  final double rotationSpeed;
  final Color color;
  final double size;

  _Particle({
    required this.x,
    required this.y,
    required this.rotation,
    required this.speedX,
    required this.speedY,
    required this.rotationSpeed,
    required this.color,
    required this.size,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;

  _ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final px = p.x * size.width;
      final py = (p.y + progress * (1.2 - p.y)) * size.height;

      if (py > size.height + 50) continue;

      canvas.save();
      canvas.translate(px, py);
      canvas.rotate(p.rotation + progress * p.rotationSpeed * 10);

      final paint = Paint()..color = p.color;
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.6),
        paint,
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
