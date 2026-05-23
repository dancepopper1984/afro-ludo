import 'package:flutter/material.dart';
import '../../core/achievement_registry.dart';
import '../../core/theme.dart';
import '../../models/achievement.dart';
import '../../services/achievement_service.dart';
import '../../services/storage_service.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  List<String> _unlockedIds = [];

  @override
  void initState() {
    super.initState();
    _loadAchievements();
  }

  void _loadAchievements() {
    setState(() {
      _unlockedIds = AchievementService.getUnlockedIds();
    });
  }

  @override
  Widget build(BuildContext context) {
    final wins = StorageService.getTotalWins() ?? 0;
    final losses = StorageService.getTotalLosses() ?? 0;
    final bestStreak = StorageService.getBestStreak() ?? 0;
    final currentStreak = StorageService.getCurrentStreak() ?? 0;
    final totalGames = wins + losses;
    final winRate = totalGames > 0
        ? (wins / totalGames * 100).toStringAsFixed(1)
        : '0.0';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stats'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _StatOverviewCard(
            totalGames: totalGames,
            winRate: winRate,
            currentStreak: currentStreak,
          ),
          const SizedBox(height: 16),
          _StatDetailTile(
            icon: Icons.emoji_events,
            label: 'Total Wins',
            value: '$wins',
            color: AfroTheme.accentGold,
          ),
          _StatDetailTile(
            icon: Icons.close,
            label: 'Total Losses',
            value: '$losses',
            color: AfroTheme.highlight,
          ),
          _StatDetailTile(
            icon: Icons.local_fire_department,
            label: 'Best Win Streak',
            value: '$bestStreak',
            color: AfroTheme.primary,
          ),
          _StatDetailTile(
            icon: Icons.trending_up,
            label: 'Current Streak',
            value: '$currentStreak',
            color: AfroTheme.secondary,
          ),
          const SizedBox(height: 24),
          Text('Achievements',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AfroTheme.textPrimary,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          for (final achievement in AchievementRegistry.all)
            _AchievementCard(
              achievement: achievement,
              isUnlocked: _unlockedIds.contains(achievement.id),
            ),
          const SizedBox(height: 24),
          TextButton.icon(
            onPressed: () => _confirmReset(context),
            icon: const Icon(Icons.delete_outline),
            label: const Text('Reset Stats'),
            style: TextButton.styleFrom(foregroundColor: AfroTheme.highlight),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _confirmReset(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AfroTheme.surface,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Reset Stats?',
            style: TextStyle(color: AfroTheme.textPrimary)),
        content: const Text(
            'This will clear your game statistics. Achievements will remain unlocked.',
            style: TextStyle(color: AfroTheme.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel',
                style: TextStyle(color: AfroTheme.textSecondary)),
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
            child: const Text('Reset',
                style: TextStyle(color: AfroTheme.highlight)),
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AfroTheme.primary, AfroTheme.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text('$totalGames',
              style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  color: Colors.white)),
          const SizedBox(height: 4),
          const Text('Games Played',
              style: TextStyle(fontSize: 14, color: Colors.white70)),
          const SizedBox(height: 20),
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
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AfroTheme.accentGold)),
        Text(label,
            style: const TextStyle(fontSize: 12, color: Colors.white70)),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        decoration: BoxDecoration(
          color: AfroTheme.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.15),
            child: Icon(icon, color: color),
          ),
          title: Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AfroTheme.textPrimary)),
          trailing: Text(value,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: color)),
        ),
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final Achievement achievement;
  final bool isUnlocked;

  const _AchievementCard({
    required this.achievement,
    required this.isUnlocked,
  });

  IconData get _icon {
    switch (achievement.iconName) {
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

  @override
  Widget build(BuildContext context) {
    final color = isUnlocked ? AfroTheme.accentGold : AfroTheme.textSecondary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        decoration: BoxDecoration(
          color: isUnlocked
              ? AfroTheme.accentGold.withValues(alpha: 0.06)
              : AfroTheme.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.15),
            child: Icon(_icon, color: color),
          ),
          title: Text(
            achievement.name,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color:
                  isUnlocked ? AfroTheme.textPrimary : AfroTheme.textSecondary,
            ),
          ),
          subtitle: Text(achievement.description,
              style:
                  const TextStyle(fontSize: 12, color: AfroTheme.textSecondary)),
          trailing: isUnlocked
              ? const Icon(Icons.check_circle, color: AfroTheme.secondary)
              : const Icon(Icons.lock_outline,
                  color: AfroTheme.textSecondary),
        ),
      ),
    );
  }
}
