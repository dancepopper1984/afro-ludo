import 'package:flutter/material.dart';
import '../../services/storage_service.dart';

/// 排行榜 / 统计界面
///
/// 展示玩家本地游戏统计：胜场、败场、胜率、连胜记录。
class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wins = StorageService.getTotalWins() ?? 0;
    final losses = StorageService.getTotalLosses() ?? 0;
    final bestStreak = StorageService.getBestStreak() ?? 0;
    final currentStreak = StorageService.getCurrentStreak() ?? 0;
    final totalGames = wins + losses;
    final winRate = totalGames > 0 ? (wins / totalGames * 100).toStringAsFixed(1) : '0.0';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stats'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 总览卡片
            _StatOverviewCard(
              totalGames: totalGames,
              winRate: winRate,
              currentStreak: currentStreak,
            ),
            const SizedBox(height: 16),

            // 详细统计
            _StatDetailTile(
              icon: Icons.emoji_events,
              label: 'Total Wins',
              value: '$wins',
              color: Colors.amber,
            ),
            const SizedBox(height: 8),
            _StatDetailTile(
              icon: Icons.close,
              label: 'Total Losses',
              value: '$losses',
              color: Colors.red,
            ),
            const SizedBox(height: 8),
            _StatDetailTile(
              icon: Icons.local_fire_department,
              label: 'Best Win Streak',
              value: '$bestStreak',
              color: Colors.orange,
            ),
            const SizedBox(height: 8),
            _StatDetailTile(
              icon: Icons.trending_up,
              label: 'Current Streak',
              value: '$currentStreak',
              color: Colors.green,
            ),

            const Spacer(),

            // 重置统计
            TextButton.icon(
              onPressed: () => _confirmReset(context),
              icon: const Icon(Icons.delete_outline),
              label: const Text('Reset Stats'),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmReset(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Reset Stats?'),
        content: const Text('This will permanently clear all your game statistics.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await StorageService.setTotalWins(0);
              await StorageService.setTotalLosses(0);
              await StorageService.setBestStreak(0);
              await StorageService.setCurrentStreak(0);
              if (context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Stats reset')),
                );
              }
            },
            child: const Text('Reset', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _StatOverviewCard extends StatelessWidget {
  final int totalGames;
  final String winRate;
  final int currentStreak;

  const _StatOverviewCard({
    required this.totalGames,
    required this.winRate,
    required this.currentStreak,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            '$totalGames',
            style: theme.textTheme.headlineLarge?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
          ),
          Text(
            'Games Played',
            style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onPrimary.withValues(alpha: 0.8),
                ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _MiniStat(label: 'Win Rate', value: '$winRate%'),
              _MiniStat(label: 'Streak', value: '$currentStreak'),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;

  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onPrimary.withValues(alpha: 0.8),
              ),
        ),
      ],
    );
  }
}

class _StatDetailTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatDetailTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(label),
        trailing: Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
