import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/achievement_registry.dart';
import '../../core/theme.dart';
import '../../models/achievement.dart';
import '../../services/achievement_service.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unlockedIds = AchievementService.getUnlockedIds();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: AchievementRegistry.all.length,
        itemBuilder: (context, index) {
          final achievement = AchievementRegistry.all[index];
          final isUnlocked = unlockedIds.contains(achievement.id);

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              decoration: BoxDecoration(
                color: isUnlocked
                    ? AfroTheme.accentGold.withValues(alpha: 0.08)
                    : AfroTheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: isUnlocked
                    ? Border.all(
                        color: AfroTheme.accentGold.withValues(alpha: 0.3))
                    : null,
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      _iconForName(achievement.iconName),
                      size: 36,
                      color: isUnlocked
                          ? AfroTheme.accentGold
                          : AfroTheme.textSecondary,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            achievement.name,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: isUnlocked
                                  ? AfroTheme.textPrimary
                                  : AfroTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            achievement.description,
                            style: const TextStyle(
                                fontSize: 13,
                                color: AfroTheme.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    if (isUnlocked)
                      const Icon(Icons.check_circle,
                          color: AfroTheme.secondary)
                    else
                      const Icon(Icons.lock,
                          color: AfroTheme.textSecondary),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _iconForName(String name) {
    switch (name) {
      case 'emoji_events':
        return Icons.emoji_events;
      case 'local_fire_department':
        return Icons.local_fire_department;
      case 'whatshot':
        return Icons.whatshot;
      case 'military_tech':
        return Icons.military_tech;
      case 'verified':
        return Icons.verified;
      case 'account_balance':
        return Icons.account_balance;
      default:
        return Icons.star;
    }
  }
}

Future<void> showAchievementUnlockDialog(
  BuildContext context,
  List<Achievement> achievements,
) async {
  if (achievements.isEmpty) return;

  for (final a in achievements) {
    if (!context.mounted) return;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AfroTheme.surface,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events,
                size: 56, color: AfroTheme.accentGold),
            const SizedBox(height: 12),
            const Text(
              'Achievement Unlocked!',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AfroTheme.textPrimary),
            ),
            const SizedBox(height: 16),
            Text(a.name,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AfroTheme.textPrimary)),
            const SizedBox(height: 8),
            Text(a.description,
                style: const TextStyle(
                    fontSize: 14, color: AfroTheme.textSecondary),
                textAlign: TextAlign.center),
            if ((a.coinReward ?? 0) > 0) ...[
              const SizedBox(height: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AfroTheme.accentGold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.monetization_on,
                        size: 20, color: AfroTheme.accentGold),
                    const SizedBox(width: 4),
                    Text('+${a.coinReward}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AfroTheme.accentGold)),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AfroTheme.primary,
              ),
              child: const Text('Continue'),
            ),
          ),
        ],
      ),
    );
  }
}
