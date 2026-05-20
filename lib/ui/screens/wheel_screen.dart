import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/wheel_rewards.dart';
import '../../models/wheel_reward.dart';
import '../../services/ad_service.dart';
import '../../services/audio_service.dart';
import '../../services/haptic_service.dart';
import '../notifiers/economy_notifier.dart';
import '../notifiers/wheel_notifier.dart';

class WheelScreen extends ConsumerStatefulWidget {
  const WheelScreen({super.key});

  @override
  ConsumerState<WheelScreen> createState() => _WheelScreenState();
}

class _WheelScreenState extends ConsumerState<WheelScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _spinController;
  double _rotation = 0;
  WheelReward? _result;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
    _spinController.addListener(() {
      setState(() {
        _rotation = _spinController.value * 2 * pi * 5 + _baseAngle;
      });
    });
    _spinController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _onSpinComplete();
      }
    });
  }

  double _baseAngle = 0;

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  void _spin() {
    final notifier = ref.read(wheelNotifierProvider.notifier);
    final result = notifier.spin();
    if (result == null) return;

    AudioService().playDiceRoll();
    HapticService().medium();

    _result = result;
    setState(() {
      _baseAngle = _rotation;
    });
    _spinController.forward(from: 0);
  }

  void _onSpinComplete() {
    if (_result == null) return;
    final reward = _result!;

    ref.read(economyNotifierProvider.notifier).addCoins(reward.coins);
    ref.read(wheelNotifierProvider.notifier).reset();

    AudioService().playWin();
    HapticService().success();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Result'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.celebration, size: 48, color: Colors.amber),
            const SizedBox(height: 16),
            Text(
              '+${reward.coins}',
              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
            ),
            const Text('AfroCoins'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() => _result = null);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _watchAd() {
    final adService = AdService();
    adService.loadRewardedAd().then((_) {
      adService.showRewardedAd(
        onRewarded: (_) {
          ref.read(wheelNotifierProvider.notifier).addAdSpin();
          HapticService().light();
          setState(() {});
        },
        onDismissed: () => adService.loadRewardedAd(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final wheelState = ref.watch(wheelNotifierProvider);
    final isSpinning = wheelState.status == WheelStatus.spinning;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lucky Wheel'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Text(
            'Spin the wheel to win!',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            wheelState.canSpinFree
                ? '1 free spin available'
                : 'Free spin used today',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          if (wheelState.adSpinsAvailable > 0)
            Text(
              'Ad spins: ${wheelState.adSpinsAvailable}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          const SizedBox(height: 16),
          Expanded(
            child: Center(
              child: SizedBox(
                width: 300,
                height: 300,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(300, 300),
                      painter: _WheelPainter(
                        rotation: _rotation,
                        rewards: WheelRewards.rewards,
                      ),
                    ),
                    // 指针（三角形）
                    Positioned(
                      top: 4,
                      child: CustomPaint(
                        size: const Size(20, 28),
                        painter: _PointerPainter(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: (isSpinning || !wheelState.canSpin) ? null : _spin,
                icon: const Icon(Icons.casino),
                label: Text(wheelState.canSpinFree ? 'Free Spin' : 'Spin'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                ),
              ),
              const SizedBox(width: 16),
              OutlinedButton.icon(
                onPressed: isSpinning ? null : _watchAd,
                icon: const Icon(Icons.play_circle_outline),
                label: const Text('Watch Ad'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _WheelPainter extends CustomPainter {
  final double rotation;
  final List<WheelReward> rewards;

  _WheelPainter({required this.rotation, required this.rewards});

  static const List<Color> _colors = [
    Color(0xFFE53935),
    Color(0xFFFFB300),
    Color(0xFF43A047),
    Color(0xFF1E88E5),
    Color(0xFF8E24AA),
    Color(0xFFFF6F00),
    Color(0xFF00ACC1),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;
    final segmentAngle = 2 * pi / rewards.length;

    for (int i = 0; i < rewards.length; i++) {
      final startAngle = rotation + i * segmentAngle;
      final paint = Paint()
        ..color = _colors[i % _colors.length]
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        segmentAngle - 0.02,
        true,
        paint,
      );

      // 画分隔线
      final linePaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      final x = center.dx + radius * cos(startAngle);
      final y = center.dy + radius * sin(startAngle);
      canvas.drawLine(center, Offset(x, y), linePaint);

      // 画文字
      final textAngle = startAngle + segmentAngle / 2;
      final textRadius = radius * 0.65;
      final textX = center.dx + textRadius * cos(textAngle);
      final textY = center.dy + textRadius * sin(textAngle);

      final textPainter = TextPainter(
        text: TextSpan(
          text: rewards[i].label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(textX - textPainter.width / 2, textY - textPainter.height / 2),
      );
    }

    // 画外圈
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(center, radius, borderPaint);

    // 画中心圆
    final centerPaint = Paint()..color = Colors.white;
    canvas.drawCircle(center, 20, centerPaint);
  }

  @override
  bool shouldRepaint(covariant _WheelPainter oldDelegate) => true;
}

class _PointerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.red;
    final path = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
