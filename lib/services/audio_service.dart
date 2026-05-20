import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// 音频服务
///
/// 管理背景音乐和音效播放，受设置中的 soundEnabled 控制。
/// 音效预加载以获得低延迟响应。
class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  AudioPlayer? _bgmPlayer;
  final Map<String, AudioPlayer> _sfxPlayers = {};

  bool _soundEnabled = true;
  bool _initialized = false;

  // === 测试注入点 ===

  @visibleForTesting
  bool get initialized => _initialized;

  @visibleForTesting
  set initialized(bool value) => _initialized = value;

  @visibleForTesting
  AudioPlayer? get bgmPlayer => _bgmPlayer;

  @visibleForTesting
  set bgmPlayer(AudioPlayer? player) => _bgmPlayer = player;

  @visibleForTesting
  Map<String, AudioPlayer> get sfxPlayers => _sfxPlayers;

  // === 初始化 ===

  Future<void> init() async {
    if (_initialized) return;

    _bgmPlayer = AudioPlayer();
    await _bgmPlayer!.setReleaseMode(ReleaseMode.loop);

    // 预加载音效（短音效使用低延迟模式）
    await _preloadSfx('dice_roll');
    await _preloadSfx('piece_move');
    await _preloadSfx('piece_capture');
    await _preloadSfx('piece_home');
    await _preloadSfx('win');
    await _preloadSfx('button_click');

    _initialized = true;
  }

  Future<void> _preloadSfx(String name) async {
    try {
      final player = AudioPlayer();
      await player.setReleaseMode(ReleaseMode.release);
      await player.setSource(AssetSource('audio/sfx/$name.mp3'));
      _sfxPlayers[name] = player;
    } catch (_) {
      // 音频文件缺失，静默跳过
    }
  }

  // === 设置 ===

  set soundEnabled(bool value) {
    _soundEnabled = value;
    if (!value) {
      _bgmPlayer?.pause();
    } else {
      _bgmPlayer?.resume();
    }
  }

  bool get soundEnabled => _soundEnabled;

  // === 背景音乐 ===

  Future<void> playBgm(String path) async {
    if (!_soundEnabled || _bgmPlayer == null) return;
    try {
      await _bgmPlayer!.stop();
      await _bgmPlayer!.setSource(AssetSource(path));
      await _bgmPlayer!.resume();
    } catch (_) {
      // 音频文件缺失，静默跳过
    }
  }

  Future<void> stopBgm() async {
    await _bgmPlayer?.stop();
  }

  Future<void> pauseBgm() async {
    await _bgmPlayer?.pause();
  }

  Future<void> resumeBgm() async {
    if (_soundEnabled) {
      await _bgmPlayer?.resume();
    }
  }

  // === 音效 ===

  void playSfx(String name) {
    if (!_soundEnabled) return;

    final player = _sfxPlayers[name];
    if (player == null) {
      // 未预加载的音效：动态创建（性能较低，仅作后备）
      _playDynamicSfx(name);
      return;
    }

    // 复用预加载的播放器，seek 到开头重新播放
    player.seek(Duration.zero);
    player.resume();
  }

  Future<void> _playDynamicSfx(String name) async {
    try {
      final player = AudioPlayer();
      await player.setSource(AssetSource('audio/sfx/$name.mp3'));
      await player.resume();
      // 播放完成后自动释放
      player.onPlayerStateChanged.listen((state) {
        if (state == PlayerState.completed) {
          player.dispose();
        }
      });
    } catch (_) {
      // 音频文件缺失，静默跳过
    }
  }

  // === 便捷方法 ===

  void playDiceRoll() => playSfx('dice_roll');
  void playPieceMove() => playSfx('piece_move');
  void playPieceCapture() => playSfx('piece_capture');
  void playPieceHome() => playSfx('piece_home');
  void playWin() => playSfx('win');
  void playButtonClick() => playSfx('button_click');

  // === 释放 ===

  Future<void> dispose() async {
    for (final player in _sfxPlayers.values) {
      await player.dispose();
    }
    _sfxPlayers.clear();
    await _bgmPlayer?.dispose();
    _bgmPlayer = null;
    _initialized = false;
  }
}
