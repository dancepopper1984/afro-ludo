import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/player.dart';
import '../../services/ad_frequency_controller.dart';
import '../../services/ad_service.dart';
import '../../services/share_service.dart';
import '../widgets/confetti_animation.dart';

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

class _GameOverScreenState extends State<GameOverScreen>
    with SingleTickerProviderStateMixin {
  static final _interstitialController = AdFrequencyController.interstitial();
  late AnimationController _titleController;
  late Animation<double> _titleScale;

  @override
  void initState() {
    super.initState();
    AdService().loadInterstitialAd();
    _titleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _titleScale = Tween<double>(begin: 0, end: 1.0).animate(
      CurvedAnimation(parent: _titleController, curve: Curves.elasticOut),
    );
    _titleController.forward();
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _onBackToMenu() {
    if (_interstitialController.canShow()) {
      _interstitialController.recordShow();
      AdService().showInterstitialAd(onDismissed: widget.onBackToMenu);
    } else {
      widget.onBackToMenu();
    }
  }

  void _onShare() {
    final winnerIndex =
        widget.rankedPlayers.indexWhere((p) => p.id == widget.winner.id);
    ShareService.shareGameResult(
      gameName: 'Ludo',
      position: winnerIndex + 1,
      totalPlayers: widget.rankedPlayers.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    final winColor = Color(widget.winner.color);

    return Scaffold(
      body: Stack(
        children: [
          // Ankara 撞色背景
          Positioned.fill(
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          color: AfroTheme.purpleRoyal.withValues(alpha: 0.5),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          color: AfroTheme.primary.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          color: AfroTheme.secondary.withValues(alpha: 0.5),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          color: AfroTheme.accentGold.withValues(alpha: 0.3),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // 半透明遮罩
          Container(color: AfroTheme.background.withValues(alpha: 0.55)),

          // 纸屑
          const Positioned.fill(child: ConfettiAnimation(particleCount: 45)),

          // 内容
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Spacer(),

                  AnimatedBuilder(
                    animation: _titleScale,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _titleScale.value,
                        child: child,
                      );
                    },
                    child: Column(
                      children: [
                        const Text(
                          'VICTORY!',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            color: AfroTheme.accentGold,
                            letterSpacing: 4,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: winColor.withValues(alpha: 0.25),
                            border: Border.all(
                                color: AfroTheme.accentGold, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: AfroTheme.accentGold
                                    .withValues(alpha: 0.4),
                                blurRadius: 20,
                              ),
                            ],
                          ),
                          child: Icon(Icons.emoji_events,
                              size: 52, color: winColor),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  Text(
                    '${widget.winner.name} Wins!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: winColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Congratulations!',
                    style: TextStyle(
                        fontSize: 16, color: AfroTheme.textSecondary),
                  ),

                  const SizedBox(height: 28),

                  // 排名列表
                  _buildPodium(),

                  const SizedBox(height: 24),

                  // 奖励
                  _buildRewards(),

                  const Spacer(),

                  // 按钮
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: widget.onPlayAgain,
                      icon: const Icon(Icons.replay),
                      label: const Text('Play Again'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AfroTheme.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _onShare,
                          icon: const Icon(Icons.share, size: 18),
                          label: const Text('Share'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AfroTheme.accentGold,
                            side: const BorderSide(
                                color: AfroTheme.accentGold),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _onBackToMenu,
                          icon: const Icon(Icons.home, size: 18),
                          label: const Text('Menu'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AfroTheme.textSecondary,
                            side: const BorderSide(
                                color: AfroTheme.textSecondary),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPodium() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AfroTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: AfroTheme.accentGold.withValues(alpha: 0.2)),
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

  Widget _buildRewards() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _RewardBadge(
          icon: Icons.monetization_on,
          label: 'Coins',
          value: '+50',
          color: AfroTheme.accentGold,
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
    final pColor = Color(player.color);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isWinner
                  ? AfroTheme.accentGold
                  : AfroTheme.surface,
              border: isWinner
                  ? null
                  : Border.all(color: AfroTheme.textSecondary),
            ),
            child: Center(
              child: Text(
                '#$rank',
                style: TextStyle(
                  color: isWinner
                      ? const Color(0xFF1A1A2E)
                      : AfroTheme.textSecondary,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: pColor,
              shape: BoxShape.circle,
              border: Border.all(color: AfroTheme.accentGold, width: 1),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              player.name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isWinner ? FontWeight.w700 : FontWeight.w400,
                color: isWinner ? pColor : AfroTheme.textPrimary,
              ),
            ),
          ),
          Text(
            '${player.homePiecesCount}/4 home',
            style: const TextStyle(
                fontSize: 12, color: AfroTheme.textSecondary),
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 8),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(value,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: color)),
              Text(label,
                  style: TextStyle(fontSize: 11, color: color)),
            ],
          ),
        ],
      ),
    );
  }
}
