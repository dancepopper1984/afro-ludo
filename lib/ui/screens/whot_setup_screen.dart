import 'package:flutter/material.dart';
import '../../core/theme.dart';
import 'whot_game_screen.dart';

class WhotSetupScreen extends StatefulWidget {
  const WhotSetupScreen({super.key});

  @override
  State<WhotSetupScreen> createState() => _WhotSetupScreenState();
}

class _WhotSetupScreenState extends State<WhotSetupScreen> {
  int _humanCount = 1;
  int _totalPlayers = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AfroTheme.background,
      appBar: AppBar(
        title: const Text('Whot Setup'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Total Players',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AfroTheme.textPrimary)),
            const SizedBox(height: 12),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 2, label: Text('2')),
                ButtonSegment(value: 3, label: Text('3')),
                ButtonSegment(value: 4, label: Text('4')),
              ],
              selected: {_totalPlayers},
              onSelectionChanged: (s) {
                setState(() {
                  _totalPlayers = s.first;
                  if (_humanCount > _totalPlayers) _humanCount = _totalPlayers;
                });
              },
            ),
            const SizedBox(height: 32),
            const Text('Human Players',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AfroTheme.textPrimary)),
            const SizedBox(height: 12),
            SegmentedButton<int>(
              segments: [
                for (int i = 1; i <= _totalPlayers; i++)
                  ButtonSegment(value: i, label: Text('$i')),
              ],
              selected: {_humanCount},
              onSelectionChanged: (s) => setState(() => _humanCount = s.first),
            ),
            const SizedBox(height: 12),
            const Text(
              'AI player(s)',
              style: TextStyle(color: AfroTheme.textSecondary),
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => WhotGameScreen(
                      humanCount: _humanCount,
                      totalPlayers: _totalPlayers,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start Game'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AfroTheme.primary,
                foregroundColor: AfroTheme.textPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
