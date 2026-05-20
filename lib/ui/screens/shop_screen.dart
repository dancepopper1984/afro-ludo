import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/iap_registry.dart';
import '../../core/skin_registry.dart';
import '../../models/skin.dart';
import '../../services/ad_service.dart';
import '../notifiers/economy_notifier.dart';
import '../notifiers/iap_notifier.dart';
import '../notifiers/skin_notifier.dart';

/// 商店界面
class ShopScreen extends ConsumerStatefulWidget {
  const ShopScreen({super.key});

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(iapNotifierProvider.notifier).init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final economy = ref.watch(economyNotifierProvider);
    final skinState = ref.watch(skinNotifierProvider);
    final iapState = ref.watch(iapNotifierProvider);

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
          _CoinBalanceCard(coins: economy.afroCoins),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _WatchAdCard(
              onWatchAd: () => _watchAd(context, ref),
            ),
          ),
          // IAP 金币包
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _IapSection(
              onPurchase: (storeId) => _onIapPurchase(context, ref, storeId),
              isPurchasing: iapState.isPurchasing,
              error: iapState.error,
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Skins',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          const SizedBox(height: 8),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: SkinRegistry.purchasable.length,
              itemBuilder: (context, index) {
                final skin = SkinRegistry.purchasable[index];
                final isUnlocked = skinState.isUnlocked(skin.id);
                final isEquipped = skinState.isEquipped(skin.id);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ShopItemCard(
                    skin: skin,
                    isUnlocked: isUnlocked,
                    isEquipped: isEquipped,
                    onAction: () => _onSkinAction(
                      context, ref, skin, isUnlocked,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _onSkinAction(
    BuildContext context,
    WidgetRef ref,
    Skin skin,
    bool isUnlocked,
  ) {
    if (isUnlocked) {
      final notifier = ref.read(skinNotifierProvider.notifier);
      notifier.equipSkin(skin.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Equipped ${skin.name}!')),
      );
      return;
    }

    final economyNotifier = ref.read(economyNotifierProvider.notifier);
    final skinNotifier = ref.read(skinNotifierProvider.notifier);
    final currentBalance = ref.read(economyNotifierProvider).afroCoins;

    final success = skinNotifier.buySkin(
      skin.id,
      balance: currentBalance,
      deduct: (price) {
        economyNotifier.spendCoins(price);
        return ref.read(economyNotifierProvider).afroCoins;
      },
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Purchased ${skin.name}!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not enough AfroCoins')),
      );
    }
  }

  void _onIapPurchase(
    BuildContext context, WidgetRef ref, String storeId) async {
    final notifier = ref.read(iapNotifierProvider.notifier);
    await notifier.purchase(storeId);
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

class _IapSection extends StatelessWidget {
  final void Function(String storeId) onPurchase;
  final bool isPurchasing;
  final String? error;

  const _IapSection({
    required this.onPurchase,
    required this.isPurchasing,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Buy Coins',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        for (final p in IapRegistry.all)
          Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.amber.withValues(alpha: 0.2),
                child: const Icon(Icons.monetization_on, color: Colors.amber),
              ),
              title: Text(p.name,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('+${p.coinReward} AfroCoins'),
              trailing: ElevatedButton(
                onPressed: isPurchasing ? null : () => onPurchase(p.storeId),
                child: Text(p.priceDisplay),
              ),
            ),
          ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              error!,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.error, fontSize: 12),
            ),
          ),
        const SizedBox(height: 12),
      ],
    );
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
  final Skin skin;
  final bool isUnlocked;
  final bool isEquipped;
  final VoidCallback onAction;

  const _ShopItemCard({
    required this.skin,
    required this.isUnlocked,
    required this.isEquipped,
    required this.onAction,
  });

  Color get _skinColor {
    switch (skin.id) {
      case 'golden_dice':
        return Colors.amber;
      case 'neon':
        return Colors.cyan;
      case 'pro_badge':
        return Colors.orange;
      case 'afro':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData get _skinIcon {
    switch (skin.iconName) {
      case 'casino':
        return Icons.casino;
      case 'grid_on':
        return Icons.grid_on;
      case 'emoji_events':
        return Icons.emoji_events;
      case 'palette':
        return Icons.palette;
      default:
        Icons.shopping_bag;
    }
    return Icons.shopping_bag;
  }

  String get _actionLabel {
    if (isEquipped) return 'Equipped';
    if (isUnlocked) return 'Equip';
    return '${skin.price}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _skinColor;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.2),
              child: Icon(_skinIcon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    skin.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    skin.description,
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: isEquipped ? null : onAction,
              style: isEquipped
                  ? ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.surfaceContainerHighest,
                      foregroundColor: theme.colorScheme.onSurfaceVariant,
                    )
                  : null,
              child: Text(_actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}

class _IapSection extends StatelessWidget {
  final void Function(String storeId) onPurchase;
  final bool isPurchasing;
  final String? error;

  const _IapSection({
    required this.onPurchase,
    required this.isPurchasing,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Buy AfroCoins",
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(error!, style: TextStyle(color: theme.colorScheme.error, fontSize: 12)),
              ),
            Row(
              children: [
                for (final product in IapRegistry.all)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ElevatedButton(
                        onPressed: isPurchasing ? null : () => onPurchase(product.storeId),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("+${product.coinReward}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            Text(product.priceDisplay, style: const TextStyle(fontSize: 13)),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
