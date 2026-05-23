import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../models/game_state.dart';
import '../../models/piece.dart';
import '../../models/player.dart';
import '../../services/achievement_service.dart';
import '../../services/ad_service.dart';
import '../../services/audio_service.dart';
import '../../services/haptic_service.dart';
import '../../services/storage_service.dart';
import '../../ui/notifiers/economy_notifier.dart';
import '../../ui/notifiers/game_notifier.dart';

import 'achievements_screen.dart';
import 'game_over_screen.dart';
import '../widgets/board_painter.dart';
import '../widgets/dice_widget.dart';
import '../widgets/pieces_layer.dart';

class LudoGameScreen extends ConsumerStatefulWidget {
  const LudoGameScreen({super.key});

  @override
  ConsumerState<LudoGameScreen> createState() => _LudoGameScreenState();
}

class _LudoGameScreenState extends ConsumerState<LudoGameScreen> {
  bool _isRolling = false;

  void _rollDice() {
    if (_isRolling) return;
    setState(() => _isRolling = true);
    AudioService().playDiceRoll();
    HapticService().medium();

    final diceValue = Random().nextInt(6) + 1;
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() => _isRolling = false);
      ref.read(gameNotifierProvider.notifier).setDiceValue(diceValue);

      final state = ref.read(gameNotifierProvider);
      if (state.currentPlayer.type == PlayerType.ai) {
        _executeAiTurn();
      }
    });
  }

  void _executeAiTurn() {
    final notifier = ref.read(gameNotifierProvider.notifier);
    final movable = notifier.getMovablePieces();
    if (movable.isEmpty) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted) return;
        notifier.skipTurn();
        _nextPlayerOrEnd();
      });
      return;
    }

    final selected = notifier.executeAiMove();
    if (selected == null) {
      _nextPlayerOrEnd();
    } else {
      _checkGameState();
    }
  }

  void _onPieceSelected(Piece piece) {
    AudioService().playPieceMove();
    HapticService().medium();
    ref.read(gameNotifierProvider.notifier).movePiece(piece);
    _checkGameState();
  }

  void _nextPlayerOrEnd() {
    final state = ref.read(gameNotifierProvider);
    if (state.phase == GamePhase.gameOver) {
      _showGameOver(state);
      return;
    }
    if (state.currentPlayer.type == PlayerType.ai) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted) return;
        _rollDice();
      });
    }
  }

  void _checkGameState() {
    final state = ref.read(gameNotifierProvider);
    if (state.phase == GamePhase.gameOver) {
      _showGameOver(state);
      return;
    }
    if (state.currentPlayer.type == PlayerType.ai) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted) return;
        _rollDice();
      });
    }
  }

  void _showGameOver(GameState state) async {
    AudioService().playWin();
    HapticService().success();
    final winner = state.players.firstWhere((p) => p.hasWon);
    final ranked = List<Player>.from(state.players)
      ..sort((a, b) => b.homePiecesCount.compareTo(a.homePiecesCount));

    final humanWon = winner.id == 0;
    final wins = (StorageService.getTotalWins() ?? 0) + (humanWon ? 1 : 0);
    final losses =
        (StorageService.getTotalLosses() ?? 0) + (humanWon ? 0 : 1);
    final currentStreak =
        humanWon ? (StorageService.getCurrentStreak() ?? 0) + 1 : 0;
    final bestStreak = StorageService.getBestStreak() ?? 0;
    final newBestStreak =
        currentStreak > bestStreak ? currentStreak : bestStreak;

    await StorageService.setTotalWins(wins);
    await StorageService.setTotalLosses(losses);
    await StorageService.setCurrentStreak(currentStreak);
    await StorageService.setBestStreak(newBestStreak);

    final newAchievements = await AchievementService.checkAndUnlock();
    if (newAchievements.isNotEmpty) {
      final rewardCoins =
          AchievementService.calculateRewardCoins(newAchievements);
      if (rewardCoins > 0) {
        ref.read(economyNotifierProvider.notifier).addCoins(rewardCoins);
      }
      if (mounted) {
        await showAchievementUnlockDialog(context, newAchievements);
      }
    }

    if (!mounted) return;
    AdService().loadInterstitialAd();

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => GameOverScreen(
          winner: winner,
          rankedPlayers: ranked,
          onBackToMenu: () => Navigator.of(context).pop(),
          onPlayAgain: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gameNotifierProvider);
    final boardSize = MediaQuery.of(context).size.width - 40;

    return Scaffold(
      backgroundColor: AfroTheme.background,
      appBar: AppBar(
        title: const Text('Ludo'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          _PlayerInfoBar(
              players: state.players, currentIndex: state.currentPlayerIndex),
          Expanded(
            child: Center(
              child: _buildBoard(state, boardSize.clamp(200, 420)),
            ),
          ),
          _buildControlPanel(state),
        ],
      ),
    );
  }

  Widget _buildBoard(GameState state, double size) {
    final notifier = ref.read(gameNotifierProvider.notifier);
    final movable = state.phase == GamePhase.selecting &&
            state.currentPlayer.type == PlayerType.human
        ? notifier.getMovablePieces()
        : <Piece>[];

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          LudoBoard(size: size),
          PiecesLayer(
            boardSize: size,
            players: state.players,
            currentPlayerIndex: state.currentPlayerIndex,
            phase: state.phase,
            movablePieces: movable,
            onPieceTap: _onPieceSelected,
          ),
        ],
      ),
    );
  }

  Widget _buildControlPanel(GameState state) {
    final isHumanTurn = state.currentPlayer.type == PlayerType.human;
    final canRoll =
        state.phase == GamePhase.rolling && isHumanTurn && !_isRolling;
    final canSelect = state.phase == GamePhase.selecting && isHumanTurn;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AfroTheme.surface,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(
          top: BorderSide(
              color: AfroTheme.accentGold.withValues(alpha: 0.2)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (canRoll || canSelect || state.phase == GamePhase.rolling)
              // 回合提示
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Color(state.currentPlayer.color),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isHumanTurn
                          ? 'Your Turn!'
                          : '${state.currentPlayer.name} is thinking...',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AfroTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),

            DiceWidget(
              size: 56,
              value: state.diceValue == 0 ? null : state.diceValue,
              isRolling: _isRolling,
              onTap: canRoll ? _rollDice : null,
            ),
            const SizedBox(height: 12),

            if (canRoll)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _rollDice,
                  icon: const Icon(Icons.casino),
                  label: const Text('Roll Dice'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AfroTheme.accentGold,
                    foregroundColor: const Color(0xFF1A1A2E),
                  ),
                ),
              )
            else if (canSelect)
              _buildPieceSelector(state)
            else if (!isHumanTurn && !_isRolling)
              Text(
                '${state.currentPlayer.name}\'s turn',
                style: const TextStyle(
                    fontSize: 14, color: AfroTheme.textSecondary),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieceSelector(GameState state) {
    final notifier = ref.read(gameNotifierProvider.notifier);
    final movable = notifier.getMovablePieces();

    if (movable.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _nextPlayerOrEnd();
      });
      return const Text('No valid moves',
          style: TextStyle(color: AfroTheme.textSecondary));
    }

    return Wrap(
      spacing: 10,
      children: [
        for (final piece in movable)
          ActionChip(
            label: Text('Piece ${piece.id + 1}',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600)),
            backgroundColor: Color(state.currentPlayer.color),
            side: const BorderSide(color: AfroTheme.accentGold),
            onPressed: () => _onPieceSelected(piece),
          ),
      ],
    );
  }
}

// --- Player Info Bar ---

class _PlayerInfoBar extends StatelessWidget {
  final List<Player> players;
  final int currentIndex;

  const _PlayerInfoBar({required this.players, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      color: AfroTheme.surface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (int i = 0; i < players.length; i++)
            _PlayerBadge(player: players[i], isActive: i == currentIndex),
        ],
      ),
    );
  }
}

class _PlayerBadge extends StatelessWidget {
  final Player player;
  final bool isActive;

  const _PlayerBadge({required this.player, required this.isActive});

  @override
  Widget build(BuildContext context) {
    final color = Color(player.color);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: isActive ? 44 : 36,
          height: isActive ? 44 : 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            border: Border.all(
              color:
                  isActive ? AfroTheme.accentGold : Colors.white.withValues(alpha: 0.2),
              width: isActive ? 2.5 : 1,
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: AfroTheme.accentGold.withValues(alpha: 0.5),
                      blurRadius: 8,
                    )
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              '${player.homePiecesCount}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          player.name,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
            color: isActive ? color : AfroTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}
