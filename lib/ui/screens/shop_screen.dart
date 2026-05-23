import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/iap_registry.dart';
import '../../core/skin_registry.dart';
import '../../models/skin.dart';
import '../../services/ad_service.dart';
import '../notifiers/economy_notifier.dart';
import '../notifiers/iap_notifier.dart';
import '../notifiers/skin_notifier.dart';
import '../../core/theme.dart';

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
            child: _WatchAdCard(onWatchAd: () => _watchAd(context, ref)),
          ),
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
                    color: AfroTheme.textPrimary,
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
                    onAction: () =>
                        _onSkinAction(context, ref, skin, isUnlocked),
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
      ref.read(skinNotifierProvider.notifier).equipSkin(skin.id);
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

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Purchased ${skin.name}!')),
      );
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: AfroTheme.surface,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.monetization_on, color: AfroTheme.accentGold),
              SizedBox(width: 8),
              Text('Not Enough Coins',
                  style: TextStyle(color: AfroTheme.textPrimary)),
            ],
          ),
          content: Text(
            '${skin.name} costs ${skin.price} AfroCoins.\nYou have $currentBalance.',
            style: const TextStyle(color: AfroTheme.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Watch Ad',
                  style: TextStyle(color: AfroTheme.secondary)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AfroTheme.primary,
              ),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  void _onIapPurchase(
      BuildContext context, WidgetRef ref, String storeId) async {
    await ref.read(iapNotifierProvider.notifier).purchase(storeId);
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
        onDismissed: () => adService.loadRewardedAd(),
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
        Text('Buy Coins',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AfroTheme.textPrimary,
                )),
        const SizedBox(height: 8),
        for (final p in IapRegistry.all)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: AfroTheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: AfroTheme.accentGold.withValues(alpha: 0.2)),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AfroTheme.accentGold.withValues(alpha: 0.15),
                child: const Icon(Icons.monetization_on,
                    color: AfroTheme.accentGold),
              ),
              title: Text(p.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AfroTheme.textPrimary)),
              subtitle: Text('+${p.coinReward} AfroCoins',
                  style: const TextStyle(color: AfroTheme.textSecondary)),
              trailing: ElevatedButton(
                onPressed:
                    isPurchasing ? null : () => onPurchase(p.storeId),
                child: Text(p.priceDisplay),
              ),
            ),
          ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(error!,
                style: const TextStyle(color: AfroTheme.highlight, fontSize: 12)),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AfroTheme.secondary, Color(0xFF148F3B)],
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: InkWell(
        onTap: onWatchAd,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const CircleAvatar(
                backgroundColor: Colors.white24,
                child: Icon(Icons.play_circle_outline, color: Colors.white),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Watch Ad',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white)),
                    SizedBox(height: 2),
                    Text('Earn free AfroCoins',
                        style: TextStyle(
                            fontSize: 13, color: Colors.white70)),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: onWatchAd,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AfroTheme.secondary,
                ),
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
        color: AfroTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: AfroTheme.accentGold.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.monetization_on,
              color: AfroTheme.accentGold, size: 32),
          const SizedBox(width: 12),
          Text('$coins',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AfroTheme.accentGold,
                  )),
          const Spacer(),
          Text('AfroCoins',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AfroTheme.textSecondary)),
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
        return Icons.shopping_bag;
    }
  }

  String get _actionLabel {
    if (isEquipped) return 'Equipped';
    if (isUnlocked) return 'Equip';
    return '${skin.price}';
  }

  @override
  Widget build(BuildContext context) {
    final color = _skinColor;

    return Container(
      decoration: BoxDecoration(
        color: AfroTheme.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.15),
              child: Icon(_skinIcon, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(skin.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AfroTheme.textPrimary)),
                  const SizedBox(height: 4),
                  Text(skin.description,
                      style: const TextStyle(
                          fontSize: 13, color: AfroTheme.textSecondary)),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: isEquipped ? null : onAction,
              style: isEquipped
                  ? ElevatedButton.styleFrom(
                      backgroundColor: AfroTheme.surface,
                      foregroundColor: AfroTheme.textSecondary,
                    )
                  : ElevatedButton.styleFrom(
                      backgroundColor: AfroTheme.primary,
                    ),
              child: Text(_actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}
