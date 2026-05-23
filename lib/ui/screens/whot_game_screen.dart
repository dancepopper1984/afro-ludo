import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/whot_card.dart';
import '../../models/whot_game_state.dart';
import '../../services/whot_engine.dart';

class WhotGameScreen extends StatefulWidget {
  final int humanCount;
  final int totalPlayers;

  const WhotGameScreen({
    super.key,
    required this.humanCount,
    required this.totalPlayers,
  });

  @override
  State<WhotGameScreen> createState() => _WhotGameScreenState();
}

class _WhotGameScreenState extends State<WhotGameScreen> {
  late WhotGameState _state;
  bool _isAiThinking = false;

  @override
  void initState() {
    super.initState();
    _state = WhotEngine.newGame(
      humanCount: widget.humanCount,
      totalPlayers: widget.totalPlayers,
    );
    _afterBuild();
  }

  void _afterBuild() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_state.currentPlayer.isHuman) return;
      _runAiTurn();
    });
  }

  Future<void> _runAiTurn() async {
    if (_state.phase == WhotPhase.gameOver) return;

    setState(() => _isAiThinking = true);
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    final card = WhotEngine.aiChooseCard(_state);
    if (card != null) {
      final hand = _state.currentPlayer.hand;
      final idx = hand.indexOf(card);
      WhotShape? callShape;
      if (card.isWhot) {
        callShape = WhotEngine.aiCallShape(hand);
      }
      setState(() {
        _state = WhotEngine.playCard(_state, idx, callShape: callShape);
        _isAiThinking = false;
      });
    } else {
      setState(() {
        _state = WhotEngine.drawCard(_state);
        _isAiThinking = false;
      });
    }

    if (_state.phase == WhotPhase.gameOver) return;
    if (_state.currentPlayer.isHuman) return;

    WidgetsBinding.instance.addPostFrameCallback((_) => _runAiTurn());
  }

  void _onCardTap(int index) {
    if (_state.currentPlayer.isHuman == false) return;
    final hand = _state.currentPlayer.hand;
    final card = hand[index];
    if (!card.canPlayOn(_state.topCard, demandedShape: _state.demandedShape)) return;

    if (card.isWhot) {
      _showShapePicker(index);
      return;
    }

    setState(() => _state = WhotEngine.playCard(_state, index));
    _checkState();
  }

  void _showShapePicker(int cardIndex) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AfroTheme.surface,
        title: const Text('Call a Shape',
            style: TextStyle(color: AfroTheme.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final shape in WhotShape.values.where((s) => s != WhotShape.whot))
              ListTile(
                leading: _ShapeIcon(shape: shape, size: 28),
                title: Text(shape.name,
                    style: const TextStyle(color: AfroTheme.textPrimary)),
                onTap: () {
                  Navigator.of(ctx).pop();
                  setState(() {
                    _state = WhotEngine.playCard(_state, cardIndex, callShape: shape);
                  });
                  _checkState();
                },
              ),
          ],
        ),
      ),
    );
  }

  void _onDrawTap() {
    if (_state.currentPlayer.isHuman == false) return;
    if (WhotEngine.canPlayAny(_state.currentPlayer.hand, _state)) return;
    setState(() => _state = WhotEngine.drawCard(_state));
    _checkState();
  }

  void _checkState() {
    if (_state.phase == WhotPhase.gameOver) return;
    if (_state.currentPlayer.isHuman) return;
    WidgetsBinding.instance.addPostFrameCallback((_) => _runAiTurn());
  }

  @override
  Widget build(BuildContext context) {
    final player = _state.currentPlayer;
    final canDraw = player.isHuman && !WhotEngine.canPlayAny(player.hand, _state);

    return Scaffold(
      backgroundColor: AfroTheme.background,
      appBar: AppBar(
        title: const Text('Whot'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _state.phase == WhotPhase.gameOver
          ? _buildGameOver()
          : Column(
              children: [
                _buildPlayerBar(),
                const SizedBox(height: 8),
                if (_state.demandedShape != null)
                  Text(
                    'Called: ${_state.demandedShape!.name}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AfroTheme.accentGold),
                  ),
                if (_isAiThinking)
                  const Text('AI thinking...',
                      style: TextStyle(color: AfroTheme.textSecondary)),
                Expanded(child: _buildTable()),
                const SizedBox(height: 8),
                _buildHand(canDraw),
              ],
            ),
    );
  }

  Widget _buildPlayerBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (int i = 0; i < _state.players.length; i++)
            _buildPlayerChip(_state.players[i], i == _state.currentPlayerIndex),
        ],
      ),
    );
  }

  Widget _buildPlayerChip(WhotPlayerState p, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isActive
            ? AfroTheme.secondary.withValues(alpha: 0.2)
            : AfroTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: isActive
            ? Border.all(color: AfroTheme.secondary, width: 2)
            : Border.all(color: AfroTheme.border, width: 1),
      ),
      child: Text(
        '${p.name} (${p.hand.length})',
        style: TextStyle(
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          fontSize: 13,
          color: isActive ? AfroTheme.textPrimary : AfroTheme.textSecondary,
        ),
      ),
    );
  }

  Widget _buildTable() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(width: 60),
          _buildDrawPile(),
          const SizedBox(width: 40),
          _buildDiscardPile(),
          const SizedBox(width: 60),
        ],
      ),
    );
  }

  Widget _buildDrawPile() {
    return GestureDetector(
      onTap: _onDrawTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 70,
            height: 100,
            decoration: BoxDecoration(
              color: AfroTheme.card,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: AfroTheme.accentGold.withValues(alpha: 0.3)),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3), blurRadius: 4)
              ],
            ),
            child: Center(
              child: Text(
                '${_state.drawPile.length}',
                style: const TextStyle(
                    color: AfroTheme.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 4),
          const Text('Draw',
              style: TextStyle(fontSize: 12, color: AfroTheme.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildDiscardPile() {
    final top = _state.topCard;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _CardWidget(card: top, size: 70),
        const SizedBox(height: 4),
        Text(top.toString(),
            style: const TextStyle(
                fontSize: 12, color: AfroTheme.textSecondary)),
      ],
    );
  }

  Widget _buildHand(bool canDraw) {
    final hand = _state.currentPlayer.hand;
    final isHuman = _state.currentPlayer.isHuman;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AfroTheme.surface,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(16)),
        border: Border(
          top: BorderSide(
              color: AfroTheme.accentGold.withValues(alpha: 0.2)),
        ),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 140,
          child: isHuman
              ? ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: hand.length,
                  itemBuilder: (_, i) => _buildPlayableCard(i, hand[i]),
                )
              : Center(
                  child: Text(
                    '${_state.currentPlayer.name} has ${hand.length} cards',
                    style: const TextStyle(
                        fontSize: 16, color: AfroTheme.textSecondary),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildPlayableCard(int index, WhotCard card) {
    final canPlay = card.canPlayOn(_state.topCard, demandedShape: _state.demandedShape);
    return GestureDetector(
      onTap: () => _onCardTap(index),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Opacity(
          opacity: canPlay ? 1.0 : 0.5,
          child: _CardWidget(card: card),
        ),
      ),
    );
  }

  Widget _buildGameOver() {
    final winner = _state.players.firstWhere((p) => p.id == _state.winnerId);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.emoji_events, size: 80, color: AfroTheme.accentGold),
          const SizedBox(height: 24),
          Text(
            '${winner.name} Wins!',
            style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AfroTheme.textPrimary),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AfroTheme.primary,
              foregroundColor: AfroTheme.textPrimary,
            ),
            child: const Text('Back to Menu'),
          ),
        ],
      ),
    );
  }
}

class _CardWidget extends StatelessWidget {
  final WhotCard card;
  final double size;

  const _CardWidget({required this.card, this.size = 70});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size * 1.43,
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A4A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: AfroTheme.accentGold.withValues(alpha: 0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 3,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _ShapeIcon(shape: card.shape, size: size * 0.35),
          const SizedBox(height: 4),
          Text(
            '${card.number}',
            style: TextStyle(
              fontSize: size * 0.28,
              fontWeight: FontWeight.bold,
              color: AfroTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ShapeIcon extends StatelessWidget {
  final WhotShape shape;
  final double size;

  const _ShapeIcon({required this.shape, required this.size});

  @override
  Widget build(BuildContext context) {
    final color = switch (shape) {
      WhotShape.circle => Colors.red,
      WhotShape.cross => Colors.blue,
      WhotShape.square => Colors.green,
      WhotShape.star => Colors.purple,
      WhotShape.triangle => Colors.orange,
      WhotShape.whot => Colors.black,
    };

    final icon = switch (shape) {
      WhotShape.circle => Icons.circle,
      WhotShape.cross => Icons.close,
      WhotShape.square => Icons.square_outlined,
      WhotShape.star => Icons.star,
      WhotShape.triangle => Icons.change_history,
      WhotShape.whot => Icons.auto_awesome,
    };

    return Icon(icon, color: color, size: size);
  }
}
