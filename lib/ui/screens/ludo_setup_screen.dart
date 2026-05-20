import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../models/player.dart';
import '../../ui/notifiers/game_notifier.dart';
import 'ludo_game_screen.dart';

/// Ludo 游戏设置界面
///
/// 支持：
/// - 1 人类 + 3 AI（经典模式，可选 AI 难度）
/// - 2-4 人类 Pass & Play（本地多人轮流玩）
class LudoSetupScreen extends ConsumerStatefulWidget {
  const LudoSetupScreen({super.key});

  @override
  ConsumerState<LudoSetupScreen> createState() => _LudoSetupScreenState();
}

class _LudoSetupScreenState extends ConsumerState<LudoSetupScreen> {
  int _humanCount = 1;
  AIDifficulty _aiDifficulty = AIDifficulty.medium;

  static const List<(String, int)> _playerOptions = [
    ('Red', 0),
    ('Green', 1),
    ('Yellow', 2),
    ('Blue', 3),
  ];

  static const List<String> _humanLabels = [
    '1 Player',
    '2 Players',
    '3 Players',
    '4 Players',
  ];

  static const List<String> _humanDescriptions = [
    'You vs 3 AI opponents.',
    '2 humans, 2 AI opponents.',
    '3 humans, 1 AI opponent.',
    'All 4 players on this device.',
  ];

  void _startGame() {
    final players = <Player>[];
    for (final (name, id) in _playerOptions) {
      final isHuman = id < _humanCount;
      players.add(
        Player.withPieces(
          id: id,
          name: name,
          color: AfroTheme.playerColorValues[id],
          type: isHuman ? PlayerType.human : PlayerType.ai,
          aiDifficulty: isHuman ? null : _aiDifficulty,
        ),
      );
    }

    ref.read(gameNotifierProvider.notifier).startGame(players);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const LudoGameScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Setup'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Players',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              SegmentedButton<int>(
                segments: [
                  for (int i = 0; i < 4; i++)
                    ButtonSegment<int>(
                      value: i + 1,
                      label: Text(_humanLabels[i]),
                    ),
                ],
                selected: {_humanCount},
                onSelectionChanged: (set) {
                  if (set.isNotEmpty) {
                    setState(() => _humanCount = set.first);
                  }
                },
              ),
              const SizedBox(height: 8),
              Text(
                _humanDescriptions[_humanCount - 1],
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 16),
              Text(
                'Player Colors',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  for (final (name, id) in _playerOptions)
                    _PlayerBadge(
                      name: name,
                      color: AfroTheme.playerColors[id],
                      isHuman: id < _humanCount,
                    ),
                ],
              ),
              if (_humanCount == 1) ...[
                const SizedBox(height: 32),
                Text(
                  'AI Difficulty',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                SegmentedButton<AIDifficulty>(
                  segments: const [
                    ButtonSegment(
                      value: AIDifficulty.easy,
                      label: Text('Easy'),
                    ),
                    ButtonSegment(
                      value: AIDifficulty.medium,
                      label: Text('Medium'),
                    ),
                    ButtonSegment(
                      value: AIDifficulty.hard,
                      label: Text('Hard'),
                    ),
                  ],
                  selected: {_aiDifficulty},
                  onSelectionChanged: (set) {
                    if (set.isNotEmpty) {
                      setState(() => _aiDifficulty = set.first);
                    }
                  },
                ),
              ],
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _startGame,
                  child: const Text('Start Game'),
                ),
              ),
            ],
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
    return Chip(
      avatar: CircleAvatar(
        backgroundColor: color,
        radius: 10,
      ),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(name),
          const SizedBox(width: 4),
          Icon(
            isHuman ? Icons.person : Icons.computer,
            size: 14,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ],
      ),
      backgroundColor: color.withValues(alpha: 0.1),
    );
  }
}
