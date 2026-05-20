import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../models/player.dart';
import '../../services/storage_service.dart';
import '../../ui/widgets/board_painter.dart';
import '../notifiers/settings_notifier.dart';

/// 设置界面
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(settingsNotifierProvider);
    final notifier = ref.read(settingsNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 音效
          SwitchListTile(
            title: const Text('Sound Effects'),
            subtitle: const Text('Enable game sounds'),
            value: state.soundEnabled,
            onChanged: (_) => notifier.toggleSound(),
          ),
          const Divider(),

          // 触觉
          SwitchListTile(
            title: const Text('Haptic Feedback'),
            subtitle: const Text('Vibration on actions'),
            value: state.hapticsEnabled,
            onChanged: (_) => notifier.toggleHaptics(),
          ),
          const Divider(),

          // AI 难度
          ListTile(
            title: const Text('AI Difficulty'),
            subtitle: Text(state.aiDifficulty.name.toUpperCase()),
            trailing: DropdownButton<AIDifficulty>(
              value: state.aiDifficulty,
              underline: const SizedBox.shrink(),
              items: const [
                DropdownMenuItem(value: AIDifficulty.easy, child: Text('EASY')),
                DropdownMenuItem(value: AIDifficulty.medium, child: Text('MEDIUM')),
                DropdownMenuItem(value: AIDifficulty.hard, child: Text('HARD')),
              ],
              onChanged: (value) {
                if (value != null) notifier.setDifficulty(value);
              },
            ),
          ),
          const Divider(),

          // 语言
          ListTile(
            title: const Text('Language'),
            subtitle: Text(_languageLabel(state.language)),
            trailing: DropdownButton<String>(
              value: state.language,
              underline: const SizedBox.shrink(),
              items: const [
                DropdownMenuItem(value: 'en', child: Text('English')),
                DropdownMenuItem(value: 'fr', child: Text('French')),
                DropdownMenuItem(value: 'sw', child: Text('Swahili')),
              ],
              onChanged: (value) {
                if (value != null) notifier.setLanguage(value);
              },
            ),
          ),
          const Divider(),

          // 棋盘主题
          ListTile(
            title: const Text('Board Theme'),
            subtitle: Text(BoardSkinSelector.current.name),
            leading: const Icon(Icons.palette),
            onTap: () => _showSkinPicker(context),
          ),
          const Divider(),

          // 重置新手引导
          ListTile(
            title: const Text('Reset Onboarding'),
            leading: const Icon(Icons.restart_alt),
            onTap: () {
              // TODO: implement onboarding reset
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Onboarding reset')),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showSkinPicker(BuildContext context) {
    final unlocked = StorageService.getUnlockedSkins() ?? ['classic'];

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Select Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final entry in AfroTheme.skins.entries)
              ListTile(
                title: Text(entry.value.name),
                leading: CircleAvatar(
                  backgroundColor: entry.value.boardBackground,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: entry.value.trackArea,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                trailing: entry.key == BoardSkinSelector.current.id
                    ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                    : null,
                enabled: unlocked.contains(entry.key),
                onTap: () async {
                  await StorageService.setActiveSkin(entry.key);
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Theme: ${entry.value.name}')),
                    );
                  }
                },
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _languageLabel(String code) {
    return switch (code) {
      'en' => 'English',
      'fr' => 'French',
      'sw' => 'Swahili',
      _ => 'English',
    };
  }
}
