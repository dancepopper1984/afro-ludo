import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/daily_check_in_dialog.dart';
import 'achievements_screen.dart';
import 'leaderboard_screen.dart';
import 'ludo_setup_screen.dart';
import 'settings_screen.dart';
import 'shop_screen.dart';
import '../widgets/banner_ad_widget.dart';
import 'wheel_screen.dart';

/// Main menu screen.
class MenuScreen extends ConsumerStatefulWidget {
  const MenuScreen({super.key});

  @override
  ConsumerState<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends ConsumerState<MenuScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDailyCheckInIfNeeded(context, ref);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 鏍囬
              Text(
                'Afro Ludo',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Classic Board Games',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 48),

              // Play 鎸夐挳
              _MenuButton(
                label: 'Play Ludo',
                icon: Icons.videogame_asset,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const LudoSetupScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Lucky Wheel 鎸夐挳
              _MenuButton(
                label: 'Lucky Wheel',
                icon: Icons.casino,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const WheelScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Settings 鎸夐挳
              _MenuButton(
                label: 'Settings',
                icon: Icons.settings,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const SettingsScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Shop 鎸夐挳
              _MenuButton(
                label: 'Shop',
                icon: Icons.store,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ShopScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Stats 鎸夐挳
              _MenuButton(
                label: 'Stats',
                icon: Icons.leaderboard,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const LeaderboardScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Achievements 鎸夐挳
              _MenuButton(
                label: 'Achievements',
                icon: Icons.emoji_events,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const AchievementsScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      bottomSheet: const BannerAdWidget(),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _MenuButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
