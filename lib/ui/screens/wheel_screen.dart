import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
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
      duration: const Duration(milliseconds: 4000),
    );
    _spinController.addListener(() {
      setState(() {
        _rotation =
            _spinController.value * 2 * pi * 6 + _baseAngle;
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
        backgroundColor: AfroTheme.surface,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.celebration,
                size: 48, color: AfroTheme.accentGold),
            const SizedBox(height: 16),
            Text('+${reward.coins}',
                style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    color: AfroTheme.accentGold)),
            const Text('AfroCoins',
                style: TextStyle(color: AfroTheme.textSecondary)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() => _result = null);
            },
            child: const Text('OK',
                style: TextStyle(color: AfroTheme.accentGold)),
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.0,
            colors: [
              Color(0x309B59B6),
              AfroTheme.background,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                title: const Text('Lucky Wheel'),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Spin the wheel to win!',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AfroTheme.textPrimary,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                wheelState.canSpinFree
                    ? '1 free spin available'
                    : 'Free spin used today',
                style: const TextStyle(
                    fontSize: 13, color: AfroTheme.textSecondary),
              ),
              if (wheelState.adSpinsAvailable > 0)
                Text(
                  'Ad spins: ${wheelState.adSpinsAvailable}',
                  style: const TextStyle(
                      fontSize: 13, color: AfroTheme.accentGold),
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
                        // 指针
                        Positioned(
                          top: 0,
                          child: CustomPaint(
                            size: const Size(24, 30),
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
                    onPressed:
                        (isSpinning || !wheelState.canSpin) ? null : _spin,
                    icon: const Icon(Icons.casino),
                    label: Text(
                        wheelState.canSpinFree ? 'Free Spin' : 'Spin'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AfroTheme.secondary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 14),
                    ),
                  ),
                  const SizedBox(width: 14),
                  OutlinedButton.icon(
                    onPressed: isSpinning ? null : _watchAd,
                    icon: const Icon(Icons.play_circle_outline),
                    label: const Text('Watch Ad'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AfroTheme.purpleRoyal,
                      side: const BorderSide(color: AfroTheme.purpleRoyal),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _WheelPainter extends CustomPainter {
  final double rotation;
  final List<WheelReward> rewards;

  _WheelPainter({required this.rotation, required this.rewards});

  static const _colors = [
    AfroTheme.primary,
    AfroTheme.secondary,
    AfroTheme.accentGold,
    AfroTheme.highlight,
    AfroTheme.purpleRoyal,
    Color(0xFF00ACC1),
    AfroTheme.primaryDark,
    Color(0xFFF4C430),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;
    final segmentAngle = 2 * pi / rewards.length;

    // 外圈金色装饰
    final ringPaint = Paint()
      ..color = AfroTheme.accentGold.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(center, radius + 2, ringPaint);

    for (int i = 0; i < rewards.length; i++) {
      final startAngle = rotation + i * segmentAngle;
      final paint = Paint()
        ..color = _colors[i % _colors.length]
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        segmentAngle - 0.03,
        true,
        paint,
      );

      // 分隔线
      final linePaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      final x = center.dx + radius * cos(startAngle);
      final y = center.dy + radius * sin(startAngle);
      canvas.drawLine(center, Offset(x, y), linePaint);

      // 文字
      final textAngle = startAngle + segmentAngle / 2;
      final textRadius = radius * 0.62;
      final textX = center.dx + textRadius * cos(textAngle);
      final textY = center.dy + textRadius * sin(textAngle);

      final textPainter = TextPainter(
        text: TextSpan(
          text: rewards[i].label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(textX - textPainter.width / 2,
            textY - textPainter.height / 2),
      );
    }

    // 外圈
    canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.2)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);

    // 中心 SPIN 按钮
    final centerPaint = Paint()
      ..color = AfroTheme.accentGold;
    canvas.drawCircle(center, 24, centerPaint);
    final centerText = TextPainter(
      text: const TextSpan(
        text: 'SPIN',
        style: TextStyle(
          color: Color(0xFF1A1A2E),
          fontSize: 13,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    centerText.layout();
    centerText.paint(
      canvas,
      Offset(center.dx - centerText.width / 2,
          center.dy - centerText.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _WheelPainter oldDelegate) => true;
}

class _PointerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AfroTheme.accentGold
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, paint);

    // 描边
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF1A1A2E)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
