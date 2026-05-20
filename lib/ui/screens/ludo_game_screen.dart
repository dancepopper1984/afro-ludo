import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/game_state.dart';
import '../../models/piece.dart';
import '../../models/player.dart';
import '../../services/audio_service.dart';
import '../../services/haptic_service.dart';
import '../../services/storage_service.dart';
import '../../ui/notifiers/game_notifier.dart';
import 'game_over_screen.dart';
import '../widgets/board_painter.dart';
import '../widgets/dice_widget.dart';
import '../widgets/pieces_layer.dart';

/// Ludo 游戏主界面
///
/// 包含：棋盘、玩家信息栏、骰子、操作按钮
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

    // 模拟骰子动画延迟
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() => _isRolling = false);
      ref.read(gameNotifierProvider.notifier).setDiceValue(diceValue);

      // 如果是 AI 玩家，自动执行
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
      // AI 无可移动棋子，跳过回合
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted) return;
        notifier.skipTurn();
        _nextPlayerOrEnd();
      });
      return;
    }

    final selected = notifier.executeAiMove();
    if (selected == null) {
      // AI 无法移动，跳过回合
      _nextPlayerOrEnd();
    } else {
      // AI 已移动，检查游戏状态并触发下一位
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

    // 检查是否下一位是 AI
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

    // 如果切换到 AI 玩家，自动开始回合
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

    // 记录统计（假设人类玩家为索引 0）
    final humanWon = winner.id == 0;
    final wins = (StorageService.getTotalWins() ?? 0) + (humanWon ? 1 : 0);
    final losses = (StorageService.getTotalLosses() ?? 0) + (humanWon ? 0 : 1);
    final currentStreak = humanWon ? (StorageService.getCurrentStreak() ?? 0) + 1 : 0;
    final bestStreak = StorageService.getBestStreak() ?? 0;
    final newBestStreak = currentStreak > bestStreak ? currentStreak : bestStreak;

    await StorageService.setTotalWins(wins);
    await StorageService.setTotalLosses(losses);
    await StorageService.setCurrentStreak(currentStreak);
    await StorageService.setBestStreak(newBestStreak);

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => GameOverScreen(
          winner: winner,
          rankedPlayers: ranked,
          onBackToMenu: () {
            Navigator.of(context).pop();
          },
          onPlayAgain: () {
            Navigator.of(context).pop();
            // TODO: restart game with same settings
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gameNotifierProvider);
    final boardSize = MediaQuery.of(context).size.width - 32;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ludo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 玩家信息栏
          _PlayerInfoBar(players: state.players, currentIndex: state.currentPlayerIndex),

          // 棋盘 + 棋子层
          Expanded(
            child: Center(
              child: _buildBoard(state, boardSize.clamp(200, 400)),
            ),
          ),

          // 底部控制栏
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
    final canRoll = state.phase == GamePhase.rolling && isHumanTurn && !_isRolling;
    final canSelect = state.phase == GamePhase.selecting && isHumanTurn;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 骰子显示
            DiceWidget(
              size: 64,
              value: state.diceValue == 0 ? null : state.diceValue,
              isRolling: _isRolling,
              onTap: canRoll ? _rollDice : null,
            ),
            const SizedBox(height: 12),

            // 操作提示 / 按钮
            if (canRoll)
              ElevatedButton.icon(
                onPressed: _rollDice,
                icon: const Icon(Icons.casino),
                label: const Text('Roll Dice'),
              )
            else if (canSelect)
              _buildPieceSelector(state)
            else if (state.phase == GamePhase.gameOver)
              const Text('Game Over', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
            else if (isHumanTurn && _isRolling)
              const Text('Rolling...')
            else
              Text('${state.currentPlayer.name}\'s turn'),
          ],
        ),
      ),
    );
  }

  Widget _buildPieceSelector(GameState state) {
    final notifier = ref.read(gameNotifierProvider.notifier);
    final movable = notifier.getMovablePieces();

    if (movable.isEmpty) {
      // 无可移动棋子，自动跳过
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _nextPlayerOrEnd();
      });
      return const Text('No valid moves');
    }

    return Wrap(
      spacing: 8,
      children: [
        for (final piece in movable)
          ActionChip(
            label: Text('Piece ${piece.id + 1}'),
            onPressed: () => _onPieceSelected(piece),
          ),
      ],
    );
  }
}

/// 玩家信息栏
class _PlayerInfoBar extends StatelessWidget {
  final List<Player> players;
  final int currentIndex;

  const _PlayerInfoBar({
    required this.players,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (int i = 0; i < players.length; i++)
            _PlayerBadge(
              player: players[i],
              isActive: i == currentIndex,
            ),
        ],
      ),
    );
  }
}

class _PlayerBadge extends StatelessWidget {
  final Player player;
  final bool isActive;

  const _PlayerBadge({
    required this.player,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          backgroundColor: Color(player.color),
          radius: isActive ? 20 : 16,
          child: isActive
              ? const Icon(Icons.person, color: Colors.white, size: 20)
              : null,
        ),
        const SizedBox(height: 4),
        Text(
          player.name,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? Color(player.color) : null,
          ),
        ),
        Text(
          '${player.homePiecesCount}/4',
          style: const TextStyle(fontSize: 10),
        ),
      ],
    );
  }
}
