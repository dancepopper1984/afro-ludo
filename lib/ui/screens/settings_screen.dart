import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../models/player.dart';
import '../../services/storage_service.dart';
import '../../ui/widgets/board_painter.dart';
import '../notifiers/settings_notifier.dart';

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
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SettingCard(
            child: SwitchListTile(
              title: const Text('Sound Effects',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AfroTheme.textPrimary)),
              subtitle: const Text('Enable game sounds',
                  style: TextStyle(color: AfroTheme.textSecondary)),
              value: state.soundEnabled,
              activeColor: AfroTheme.secondary,
              onChanged: (_) => notifier.toggleSound(),
            ),
          ),
          const SizedBox(height: 10),

          _SettingCard(
            child: SwitchListTile(
              title: const Text('Haptic Feedback',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AfroTheme.textPrimary)),
              subtitle: const Text('Vibration on actions',
                  style: TextStyle(color: AfroTheme.textSecondary)),
              value: state.hapticsEnabled,
              activeColor: AfroTheme.secondary,
              onChanged: (_) => notifier.toggleHaptics(),
            ),
          ),
          const SizedBox(height: 10),

          _SettingCard(
            child: ListTile(
              title: const Text('AI Difficulty',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AfroTheme.textPrimary)),
              subtitle: Text(state.aiDifficulty.name.toUpperCase(),
                  style: const TextStyle(color: AfroTheme.textSecondary)),
              trailing: _DifficultySelector(
                value: state.aiDifficulty,
                onChanged: (v) => notifier.setDifficulty(v),
              ),
            ),
          ),
          const SizedBox(height: 10),

          _SettingCard(
            child: ListTile(
              title: const Text('Language',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AfroTheme.textPrimary)),
              subtitle: Text(_languageLabel(state.language),
                  style: const TextStyle(color: AfroTheme.textSecondary)),
              trailing: _LanguageSelector(
                value: state.language,
                onChanged: (v) => notifier.setLanguage(v),
              ),
            ),
          ),
          const SizedBox(height: 10),

          _SettingCard(
            child: ListTile(
              title: const Text('Board Theme',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AfroTheme.textPrimary)),
              subtitle: Text(BoardSkinSelector.current.name,
                  style: const TextStyle(color: AfroTheme.textSecondary)),
              leading: const Icon(Icons.palette, color: AfroTheme.accentGold),
              onTap: () => _showSkinPicker(context),
            ),
          ),
          const SizedBox(height: 10),

          _SettingCard(
            child: ListTile(
              title: const Text('Reset Onboarding',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AfroTheme.textPrimary)),
              leading:
                  const Icon(Icons.restart_alt, color: AfroTheme.textSecondary),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Onboarding reset')),
                );
              },
            ),
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
        backgroundColor: AfroTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Select Theme',
            style: TextStyle(color: AfroTheme.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final entry in AfroTheme.skins.entries)
              ListTile(
                title: Text(entry.value.name,
                    style: const TextStyle(color: AfroTheme.textPrimary)),
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
                    ? const Icon(Icons.check, color: AfroTheme.accentGold)
                    : null,
                enabled: unlocked.contains(entry.key),
                onTap: () async {
                  await StorageService.setActiveSkin(entry.key);
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Theme: ${entry.value.name}')),
                    );
                  }
                },
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close',
                style: TextStyle(color: AfroTheme.accentGold)),
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

class _SettingCard extends StatelessWidget {
  final Widget child;
  const _SettingCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AfroTheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}

class _DifficultySelector extends StatelessWidget {
  final AIDifficulty value;
  final ValueChanged<AIDifficulty> onChanged;

  const _DifficultySelector({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return ToggleButtons(
      isSelected: [
        value == AIDifficulty.easy,
        value == AIDifficulty.medium,
        value == AIDifficulty.hard,
      ],
      onPressed: (i) => onChanged(AIDifficulty.values[i]),
      borderRadius: BorderRadius.circular(10),
      selectedColor: Colors.white,
      fillColor: const [AfroTheme.secondary, AfroTheme.primary, AfroTheme.highlight]
          [AIDifficulty.values.indexOf(value)],
      color: AfroTheme.textSecondary,
      constraints: const BoxConstraints(minWidth: 56, minHeight: 36),
      textStyle:
          const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      children: const [
        Text('EASY'),
        Text('MED'),
        Text('HARD'),
      ],
    );
  }
}

class _LanguageSelector extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const _LanguageSelector({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: value,
      underline: const SizedBox.shrink(),
      dropdownColor: AfroTheme.surface,
      style: const TextStyle(color: AfroTheme.textPrimary),
      items: const [
        DropdownMenuItem(value: 'en', child: Text('English')),
        DropdownMenuItem(value: 'fr', child: Text('French')),
        DropdownMenuItem(value: 'sw', child: Text('Swahili')),
      ],
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }
}
