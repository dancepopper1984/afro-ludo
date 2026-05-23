import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../services/storage_service.dart';
import '../widgets/kente_strip.dart';
import 'age_verification_screen.dart';
import 'menu_screen.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _glowAnimation;

  final _random = math.Random(42);
  late final List<_Bubble> _bubbles;

  @override
  void initState() {
    super.initState();

    _bubbles = List.generate(10, (i) => _Bubble(
      x: _random.nextDouble(),
      size: 2.0 + _random.nextDouble() * 3,
      speed: 0.3 + _random.nextDouble() * 0.5,
    ));

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.32, curve: Curves.elasticOut),
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.32, curve: Curves.easeIn),
      ),
    );

    _glowAnimation = Tween<double>(begin: 0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.32, 0.55, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    final ageVerified = StorageService.getAgeVerified() ?? false;
    if (!ageVerified) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AgeVerificationScreen()),
      );
      return;
    }

    final hasOnboarded = StorageService.getHasCompletedOnboarding() ?? false;
    if (!hasOnboarded) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MenuScreen()),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AfroTheme.background,
      body: Stack(
        children: [
          // 背景粒子
          ..._bubbles.map((b) => Positioned(
            left: b.x * MediaQuery.of(context).size.width,
            bottom: -20 + (b.speed * 300),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (_, __) {
                final t = _controller.value;
                return Opacity(
                  opacity: (1.0 - (t * b.speed + 0.3) % 1.0).clamp(0.0, 0.4),
                  child: Container(
                    width: b.size,
                    height: b.size,
                    decoration: const BoxDecoration(
                      color: AfroTheme.accentGold,
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              },
            ),
          )),

          // 主内容
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 2),
                    // Logo
                    Opacity(
                      opacity: _opacityAnimation.value,
                      child: Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Column(
                          children: [
                            ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(
                                colors: [
                                  AfroTheme.accentGold,
                                  Color(0xFFFFF5CC),
                                  AfroTheme.accentGold,
                                ],
                              ).createShader(bounds),
                              child: const Text(
                                'AFRO',
                                style: TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 8,
                                ),
                              ),
                            ),
                            const Text(
                              'LUDO',
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.w900,
                                color: AfroTheme.textPrimary,
                                letterSpacing: 8,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 金色光晕
                    Opacity(
                      opacity: _glowAnimation.value * 0.6,
                      child: Container(
                        width: 200,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            center: Alignment.topCenter,
                            radius: 1.2,
                            colors: [
                              AfroTheme.accentGold.withValues(alpha: 0.4),
                              AfroTheme.accentGold.withValues(alpha: 0.1),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      'Classic Board Games',
                      style: TextStyle(
                        fontSize: 14,
                        color: AfroTheme.textSecondary,
                        letterSpacing: 2,
                      ),
                    ),

                    const Spacer(flex: 3),
                  ],
                );
              },
            ),
          ),

          // 底部 Kente 条纹
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              top: false,
              child: const KenteStrip(
                height: 4,
                animate: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Bubble {
  final double x;
  final double size;
  final double speed;

  _Bubble({required this.x, required this.size, required this.speed});
}
