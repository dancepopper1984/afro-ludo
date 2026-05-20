# Afro Ludo - Architecture

## Directory Structure

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── constants.dart
│   ├── theme.dart
│   ├── extensions.dart
│   └── performance_manager.dart
├── l10n/
│   └── app_en.arb
├── models/
│   ├── game_state.dart
│   ├── player.dart
│   ├── piece.dart
│   ├── economy_state.dart
│   └── settings_state.dart
├── game/
│   ├── ludo/
│   │   ├── board.dart
│   │   ├── move_rules.dart
│   │   ├── capture_rules.dart
│   │   ├── win_checker.dart
│   │   └── ai_strategy.dart
│   └── whot/
│       ├── deck.dart
│       ├── rules.dart
│       └── ai.dart
├── ui/
│   ├── screens/
│   │   ├── splash_screen.dart
│   │   ├── age_verify_screen.dart
│   │   ├── onboarding_screen.dart
│   │   ├── menu_screen.dart
│   │   ├── ludo_game_screen.dart
│   │   ├── ludo_setup_screen.dart
│   │   ├── shop_screen.dart
│   │   ├── settings_screen.dart
│   │   ├── leaderboard_screen.dart
│   │   └── game_over_screen.dart
│   ├── widgets/
│   │   ├── board_painter.dart
│   │   ├── pieces_layer.dart
│   │   ├── dice_widget.dart
│   │   ├── coin_display.dart
│   │   ├── player_avatar.dart
│   │   └── game_action_bar.dart
│   └── notifiers/
│       ├── game_notifier.dart
│       ├── economy_notifier.dart
│       ├── settings_notifier.dart
│       └── ads_notifier.dart
└── services/
    ├── ads_service.dart
    ├── iap_service.dart
    ├── audio_service.dart
    ├── storage_service.dart
    ├── crashlytics_service.dart
    └── analytics_service.dart
```

## Key Rules

1. `models/` and `game/` are pure Dart, no Flutter imports
2. Dependency direction: models -> game -> services -> ui
3. Game loop is event-driven (no Flame, no 60fps idle loop)
4. Board rendered with CustomPainter (cached), pieces with AnimatedPositioned
5. State managed by Riverpod StateNotifier in `ui/notifiers/`
6. Windows Developer Mode must be ON for plugin compilation
7. Piece.position: -1=base, 0-51=track, 0-4=homeTrack, 5=home