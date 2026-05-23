import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../models/player.dart';
import '../../ui/notifiers/game_notifier.dart';

import 'ludo_game_screen.dart';

class LudoSetupScreen extends ConsumerStatefulWidget {
  const LudoSetupScreen({super.key});

  @override
  ConsumerState<LudoSetupScreen> createState() => _LudoSetupScreenState();
}

class _LudoSetupScreenState extends ConsumerState<LudoSetupScreen> {
  int _humanCount = 1;
  AIDifficulty _aiDifficulty = AIDifficulty.medium;

  static const _playerColors = [
    ('Red', 0, AfroTheme.redPlayer),
    ('Green', 1, AfroTheme.greenPlayer),
    ('Yellow', 2, AfroTheme.yellowPlayer),
    ('Blue', 3, AfroTheme.bluePlayer),
  ];

  void _startGame() {
    final players = <Player>[];
    for (final (name, id, _) in _playerColors) {
      final isHuman = id < _humanCount;
      players.add(Player.withPieces(
        id: id,
        name: name,
        color: AfroTheme.playerColorValues[id],
        type: isHuman ? PlayerType.human : PlayerType.ai,
        aiDifficulty: isHuman ? null : _aiDifficulty,
      ));
    }

    ref.read(gameNotifierProvider.notifier).startGame(players);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LudoGameScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Game Setup')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 玩家数量
              const Text('Players',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AfroTheme.textPrimary)),
              const SizedBox(height: 12),
              ...List.generate(4, (i) {
                final count = i + 1;
                final selected = _humanCount == count;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _SetupOptionCard(
                    label: '$count Player${count > 1 ? 's' : ''}',
                    subtitle: count == 1
                        ? 'You vs 3 AI opponents'
                        : count == 4
                            ? 'All 4 players on this device'
                            : '${count} humans, ${4 - count} AI opponents',
                    isSelected: selected,
                    selectedColor: AfroTheme.primary,
                    onTap: () => setState(() => _humanCount = count),
                  ),
                );
              }),

              const SizedBox(height: 20),

              // 玩家颜色预览
              const Text('Player Colors',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AfroTheme.textPrimary)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  for (final (name, id, color) in _playerColors)
                    _PlayerBadge(
                      name: name,
                      color: color,
                      isHuman: id < _humanCount,
                    ),
                ],
              ),

              if (_humanCount == 1) ...[
                const SizedBox(height: 24),
                const Text('AI Difficulty',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AfroTheme.textPrimary)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _DifficultyButton(
                      label: 'Easy',
                      color: AfroTheme.secondary,
                      selected: _aiDifficulty == AIDifficulty.easy,
                      onTap: () =>
                          setState(() => _aiDifficulty = AIDifficulty.easy),
                    ),
                    const SizedBox(width: 10),
                    _DifficultyButton(
                      label: 'Medium',
                      color: AfroTheme.primary,
                      selected: _aiDifficulty == AIDifficulty.medium,
                      onTap: () =>
                          setState(() => _aiDifficulty = AIDifficulty.medium),
                    ),
                    const SizedBox(width: 10),
                    _DifficultyButton(
                      label: 'Hard',
                      color: AfroTheme.highlight,
                      selected: _aiDifficulty == AIDifficulty.hard,
                      onTap: () =>
                          setState(() => _aiDifficulty = AIDifficulty.hard),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 32),

              // Start Game 按钮
              Container(
                width: double.infinity,
                height: 58,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AfroTheme.primary, AfroTheme.primaryDark],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: _startGame,
                    child: const Center(
                      child: Text(
                        'START GAME',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AfroTheme.textPrimary,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SetupOptionCard extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool isSelected;
  final Color selectedColor;
  final VoidCallback onTap;

  const _SetupOptionCard({
    required this.label,
    required this.subtitle,
    required this.isSelected,
    required this.selectedColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: isSelected ? selectedColor.withValues(alpha: 0.2) : AfroTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected ? selectedColor : AfroTheme.accentGold.withValues(alpha: 0.15),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? selectedColor : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? selectedColor : AfroTheme.textSecondary,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AfroTheme.textPrimary)),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: const TextStyle(
                            fontSize: 13, color: AfroTheme.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DifficultyButton extends StatelessWidget {
  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _DifficultyButton({
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 48,
        decoration: BoxDecoration(
          gradient: selected
              ? LinearGradient(
                  colors: [color, color.withValues(alpha: 0.7)])
              : null,
          color: selected ? null : AfroTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: selected
              ? null
              : Border.all(
                  color: AfroTheme.accentGold.withValues(alpha: 0.2)),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : AfroTheme.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PlayerBadge extends StatelessWidget {
  final String name;
  final Color color;
  final bool isHuman;

  const _PlayerBadge({
    required this.name,
    required this.color,
    required this.isHuman,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isHuman ? AfroTheme.accentGold : color.withValues(alpha: 0.3),
          width: isHuman ? 2 : 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: isHuman
                  ? [
                      BoxShadow(
                        color: AfroTheme.accentGold.withValues(alpha: 0.5),
                        blurRadius: 6,
                      )
                    ]
                  : null,
            ),
          ),
          const SizedBox(width: 8),
          Text(name,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AfroTheme.textPrimary)),
          const SizedBox(width: 6),
          Icon(
            isHuman ? Icons.person : Icons.computer,
            size: 14,
            color: isHuman ? AfroTheme.accentGold : AfroTheme.textSecondary,
          ),
        ],
      ),
    );
  }
}
