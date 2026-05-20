import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/ad_service.dart';
import '../../services/storage_service.dart';
import '../notifiers/economy_notifier.dart';

/// 商店界面
class ShopScreen extends ConsumerWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final economy = ref.watch(economyNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          // 金币余额卡片
          _CoinBalanceCard(coins: economy.afroCoins),

          // 看广告赚金币
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _WatchAdCard(
              onWatchAd: () => _watchAd(context, ref),
            ),
          ),
          const SizedBox(height: 12),

          // 商品列表
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _ShopItemCard(
                  title: 'Golden Dice',
                  description: 'Roll in style with a golden dice skin.',
                  price: 500,
                  icon: Icons.casino,
                  color: Colors.amber,
                  onBuy: () => _buyItem(context, ref, 'Golden Dice', 500),
                ),
                const SizedBox(height: 12),
                _ShopItemCard(
                  title: 'Neon Board',
                  description: 'A vibrant neon-colored board theme.',
                  price: 1000,
                  icon: Icons.grid_on,
                  color: Colors.cyan,
                  onBuy: () => _buyItem(context, ref, 'Neon Board', 1000),
                ),
                const SizedBox(height: 12),
                _ShopItemCard(
                  title: 'Pro Player Badge',
                  description: 'Show off your pro status in matches.',
                  price: 2000,
                  icon: Icons.emoji_events,
                  color: Colors.orange,
                  onBuy: () => _buyItem(context, ref, 'Pro Player Badge', 2000),
                ),
                const SizedBox(height: 12),
                _ShopItemCard(
                  title: 'Afro Theme Pack',
                  description: 'Complete African-inspired visual overhaul.',
                  price: 5000,
                  icon: Icons.palette,
                  color: Colors.green,
                  onBuy: () => _buyItem(context, ref, 'Afro Theme Pack', 5000),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _buyItem(BuildContext context, WidgetRef ref, String name, int price) {
    final notifier = ref.read(economyNotifierProvider.notifier);
    final success = notifier.spendCoins(price);

    if (success) {
      _unlockSkinIfApplicable(name);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Purchased $name!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not enough AfroCoins')),
      );
    }
  }

  void _unlockSkinIfApplicable(String itemName) {
    final skinMap = {
      'Neon Board': 'neon',
      'Afro Theme Pack': 'dark',
    };
    final skinId = skinMap[itemName];
    if (skinId == null) return;

    final unlocked = StorageService.getUnlockedSkins() ?? ['classic'];
    if (!unlocked.contains(skinId)) {
      unlocked.add(skinId);
      StorageService.setUnlockedSkins(unlocked);
      StorageService.setActiveSkin(skinId);
    }
  }

  void _watchAd(BuildContext context, WidgetRef ref) {
    final adService = AdService();
    adService.loadRewardedAd().then((_) {
      adService.showRewardedAd(
        onRewarded: (_) {
          ref.read(economyNotifierProvider.notifier).watchAdReward();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('You earned coins!')),
          );
        },
        onDismissed: () {
          // 广告关闭后预加载下一条
          adService.loadRewardedAd();
        },
      );
    });
  }
}

class _WatchAdCard extends StatelessWidget {
  final VoidCallback onWatchAd;

  const _WatchAdCard({required this.onWatchAd});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      color: theme.colorScheme.secondaryContainer,
      child: InkWell(
        onTap: onWatchAd,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: theme.colorScheme.secondary.withValues(alpha: 0.2),
                child: Icon(
                  Icons.play_circle_outline,
                  color: theme.colorScheme.secondary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Watch Ad',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Earn free AfroCoins',
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: onWatchAd,
                child: const Text('Watch'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CoinBalanceCard extends StatelessWidget {
  final int coins;

  const _CoinBalanceCard({required this.coins});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.monetization_on,
            color: Theme.of(context).colorScheme.primary,
            size: 32,
          ),
          const SizedBox(width: 12),
          Text(
            '$coins',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const Spacer(),
          Text(
            'AfroCoins',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _ShopItemCard extends StatelessWidget {
  final String title;
  final String description;
  final int price;
  final IconData icon;
  final Color color;
  final VoidCallback onBuy;

  const _ShopItemCard({
    required this.title,
    required this.description,
    required this.price,
    required this.icon,
    required this.color,
    required this.onBuy,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.2),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: onBuy,
              child: Text('$price'),
            ),
          ],
        ),
      ),
    );
  }
}
