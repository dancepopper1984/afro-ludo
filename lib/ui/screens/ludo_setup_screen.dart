import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../models/player.dart';
import '../../ui/notifiers/game_notifier.dart';
import 'ludo_game_screen.dart';

/// Ludo 游戏设置界面
///
/// 允许玩家选择：
/// - 自己的颜色（0-3）
/// - AI 难度（Easy / Medium / Hard）
/// - 其他 3 个玩家由 AI 控制
class LudoSetupScreen extends ConsumerStatefulWidget {
  const LudoSetupScreen({super.key});

  @override
  ConsumerState<LudoSetupScreen> createState() => _LudoSetupScreenState();
}

class _LudoSetupScreenState extends ConsumerState<LudoSetupScreen> {
  int _selectedPlayerId = 0;
  AIDifficulty _aiDifficulty = AIDifficulty.medium;
  bool _passAndPlay = false;

  static const List<(String, int)> _playerOptions = [
    ('Red', 0),
    ('Green', 1),
    ('Yellow', 2),
    ('Blue', 3),
  ];

  void _startGame() {
    final players = <Player>[];
    for (final (name, id) in _playerOptions) {
      final isHuman = _passAndPlay || id == _selectedPlayerId;
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
                'Select Your Color',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                children: [
                  for (final (name, id) in _playerOptions)
                    _ColorChip(
                      name: name,
                      color: AfroTheme.playerColors[id],
                      isSelected: _selectedPlayerId == id,
                      onTap: () => setState(() => _selectedPlayerId = id),
                    ),
                ],
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Text(
                    'Pass & Play',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(width: 12),
                  Switch(
                    value: _passAndPlay,
                    onChanged: (value) => setState(() => _passAndPlay = value),
                  ),
                ],
              ),
              Text(
                _passAndPlay
                    ? 'All 4 players take turns on this device.'
                    : 'You vs 3 AI opponents.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              if (!_passAndPlay) ...[
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

class _ColorChip extends StatelessWidget {
  final String name;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ColorChip({
    required this.name,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(name),
      selected: isSelected,
      onSelected: (_) => onTap(),
      avatar: CircleAvatar(
        backgroundColor: color,
        radius: 10,
      ),
      selectedColor: color.withValues(alpha: 0.3),
    );
  }
}
