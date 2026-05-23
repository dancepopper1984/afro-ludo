import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../services/share_service.dart';
import '../notifiers/economy_notifier.dart';
import '../widgets/afro_button.dart';
import '../widgets/daily_check_in_dialog.dart';
import '../widgets/gold_coin_display.dart';
import '../widgets/kente_strip.dart';
import '../widgets/banner_ad_widget.dart';
import 'achievements_screen.dart';
import 'leaderboard_screen.dart';
import 'ludo_setup_screen.dart';
import 'settings_screen.dart';
import 'shop_screen.dart';
import 'whot_setup_screen.dart';
import 'wheel_screen.dart';

class MenuScreen extends ConsumerStatefulWidget {
  const MenuScreen({super.key});

  @override
  ConsumerState<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends ConsumerState<MenuScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _entranceController;
  late List<Animation<double>> _itemAnimations;

  static const _menuItems = <_MenuItem>[
    _MenuItem('Play Ludo', Icons.videogame_asset,
        [AfroTheme.primary, AfroTheme.primaryDark]),
    _MenuItem('Play Whot', Icons.style,
        [AfroTheme.secondary, Color(0xFF148F3B)]),
    _MenuItem('Lucky Wheel', Icons.casino,
        [AfroTheme.purpleRoyal, AfroTheme.purpleDark]),
    _MenuItem('Settings', Icons.settings, null),
    _MenuItem('Shop', Icons.store,
        [AfroTheme.accentGold, Color(0xFFF4C430)]),
    _MenuItem('Stats', Icons.leaderboard, null),
    _MenuItem('Achievements', Icons.emoji_events,
        [AfroTheme.highlight, Color(0xFFC0392B)]),
    _MenuItem('Share', Icons.share, null),
  ];

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _itemAnimations = List.generate(_menuItems.length, (i) {
      final start = i * 0.06;
      return CurvedAnimation(
        parent: _entranceController,
        curve: Interval(start, (start + 0.25).clamp(0.0, 1.0),
            curve: Curves.easeOutCubic),
      );
    });

    _entranceController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDailyCheckInIfNeeded(context, ref);
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  void _navigateTo(int index) {
    final routes = <Widget>[
      const LudoSetupScreen(),
      const WhotSetupScreen(),
      const WheelScreen(),
      const SettingsScreen(),
      const ShopScreen(),
      const LeaderboardScreen(),
      const AchievementsScreen(),
    ];

    if (index == 7) {
      ShareService.shareApp();
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => routes[index]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final economy = ref.watch(economyNotifierProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.6),
            radius: 0.9,
            colors: [
              Color(0x30FF6B35),
              AfroTheme.background,
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  const Spacer(flex: 8),

                  // Logo 区域
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [AfroTheme.accentGold, Color(0xFFFFF5CC)],
                    ).createShader(bounds),
                    child: const Text(
                      'AFRO LUDO',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Classic Board Games',
                    style: TextStyle(
                      fontSize: 13,
                      color: AfroTheme.textSecondary,
                      letterSpacing: 2,
                    ),
                  ),

                  const Spacer(flex: 6),

                  // 菜单按钮
                  Expanded(
                    flex: 55,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      physics: const BouncingScrollPhysics(),
                      itemCount: _menuItems.length,
                      itemBuilder: (context, index) {
                        final item = _menuItems[index];
                        final animation = _itemAnimations[index];

                        return AnimatedBuilder(
                          animation: animation,
                          builder: (context, child) {
                            return Opacity(
                              opacity: animation.value,
                              child: Transform.translate(
                                offset: Offset(
                                  0,
                                  40 * (1 - animation.value),
                                ),
                                child: child,
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: AfroButton(
                              label: item.label,
                              icon: item.icon,
                              height: 58,
                              gradient: item.gradient != null
                                  ? LinearGradient(colors: item.gradient!)
                                  : null,
                              borderColor: item.gradient == null
                                  ? AfroTheme.accentGold
                                  : null,
                              textColor: item.label == 'Shop'
                                  ? const Color(0xFF1A1A2E)
                                  : null,
                              onPressed: () => _navigateTo(index),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const Spacer(flex: 6),
                ],
              ),

              // 右上角金币显示
              Positioned(
                top: 8,
                right: 16,
                child: GoldCoinDisplay(amount: economy.afroCoins),
              ),

              // 底部 Kente
              const Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: KenteStrip(height: 3, animate: true),
              ),
            ],
          ),
        ),
      ),
      bottomSheet: const BannerAdWidget(),
    );
  }
}

class _MenuItem {
  final String label;
  final IconData icon;
  final List<Color>? gradient;

  const _MenuItem(this.label, this.icon, this.gradient);
}
