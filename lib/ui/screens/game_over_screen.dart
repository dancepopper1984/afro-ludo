import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/player.dart';
import '../../services/ad_service.dart';

/// 游戏结束界面
///
/// 显示获胜者、排名、奖励金币、返回菜单按钮。
/// 返回菜单时展示插页广告。
class GameOverScreen extends StatefulWidget {
  final Player winner;
  final List<Player> rankedPlayers;
  final VoidCallback onBackToMenu;
  final VoidCallback? onPlayAgain;

  const GameOverScreen({
    super.key,
    required this.winner,
    required this.rankedPlayers,
    required this.onBackToMenu,
    this.onPlayAgain,
  });

  @override
  State<GameOverScreen> createState() => _GameOverScreenState();
}

class _GameOverScreenState extends State<GameOverScreen> {
  @override
  void initState() {
    super.initState();
    AdService().loadInterstitialAd();
  }

  void _onBackToMenu() {
    AdService().showInterstitialAd(
      onDismissed: widget.onBackToMenu,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              _buildTrophy(context),
              const SizedBox(height: 24),
              Text(
                '${widget.winner.name} Wins!',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: Color(widget.winner.color),
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Congratulations!',
                style: TextStyle(fontSize: 16, color: AfroTheme.textSecondary),
              ),
              const SizedBox(height: 32),
              _buildPodium(),
              const SizedBox(height: 32),
              _buildRewards(context),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: widget.onPlayAgain,
                  icon: const Icon(Icons.replay),
                  label: const Text('Play Again'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _onBackToMenu,
                  icon: const Icon(Icons.home),
                  label: const Text('Back to Menu'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrophy(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Color(widget.winner.color).withValues(alpha: 0.2),
        border: Border.all(color: Color(widget.winner.color), width: 3),
      ),
      child: Icon(
        Icons.emoji_events,
        size: 64,
        color: Color(widget.winner.color),
      ),
    );
  }

  Widget _buildPodium() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          for (int i = 0; i < widget.rankedPlayers.length; i++)
            _RankRow(
              rank: i + 1,
              player: widget.rankedPlayers[i],
              isWinner: i == 0,
            ),
        ],
      ),
    );
  }

  Widget _buildRewards(BuildContext context) {
    final winnerIndex = widget.rankedPlayers.indexWhere((p) => p.id == widget.winner.id);
    final coins = switch (winnerIndex) {
      0 => 100,
      1 => 80,
      _ => 0,
    };
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _RewardBadge(
          icon: Icons.monetization_on,
          label: 'Coins',
          value: '+$coins',
          color: Colors.amber,
        ),
      ],
    );
  }
}

class _RankRow extends StatelessWidget {
  final int rank;
  final Player player;
  final bool isWinner;

  const _RankRow({
    required this.rank,
    required this.player,
    required this.isWinner,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isWinner ? Color(player.color) : Colors.grey.shade300,
            ),
            child: Center(
              child: Text(
                '#$rank',
                style: TextStyle(
                  color: isWinner ? Colors.white : Colors.black54,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            backgroundColor: Color(player.color),
            radius: 14,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              player.name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isWinner ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Text(
            '${player.homePiecesCount}/4 home',
            style: const TextStyle(fontSize: 12, color: AfroTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _RewardBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _RewardBadge({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 6),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
              Text(label, style: TextStyle(fontSize: 10, color: color)),
            ],
          ),
        ],
      ),
    );
  }
}
