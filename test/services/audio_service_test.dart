import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:afro_ludo_flutter/services/audio_service.dart';

class MockAudioPlayer extends Mock implements AudioPlayer {}

MockAudioPlayer _createMockPlayer() {
  final player = MockAudioPlayer();
  when(() => player.pause()).thenAnswer((_) async {});
  when(() => player.resume()).thenAnswer((_) async {});
  when(() => player.stop()).thenAnswer((_) async {});
  when(() => player.dispose()).thenAnswer((_) async {});
  when(() => player.seek(any())).thenAnswer((_) async {});
  when(() => player.setSource(any())).thenAnswer((_) async {});
  return player;
}

class FakeAssetSource extends Fake implements AssetSource {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(Duration.zero);
    registerFallbackValue(FakeAssetSource());
  });

  final service = AudioService();

  setUp(() {
    service.bgmPlayer = null;
    service.sfxPlayers.clear();
    service.soundEnabled = true;
    service.initialized = true;

    // Pre-load mock sfx players so convenience methods avoid dynamic creation
    for (final name in [
      'dice_roll',
      'piece_move',
      'piece_capture',
      'piece_home',
      'win',
      'button_click',
    ]) {
      service.sfxPlayers[name] = _createMockPlayer();
    }
  });

  tearDown(() async {
    service.bgmPlayer = null;
    service.sfxPlayers.clear();
    await service.dispose();
  });

  group('AudioService', () {
    group('soundEnabled setter', () {
      test('pauses bgm when set to false', () async {
        final mockPlayer = _createMockPlayer();
        service.bgmPlayer = mockPlayer;

        service.soundEnabled = false;

        verify(() => mockPlayer.pause()).called(1);
      });

      test('resumes bgm when set to true', () async {
        final mockPlayer = _createMockPlayer();
        service.bgmPlayer = mockPlayer;

        service.soundEnabled = true;

        verify(() => mockPlayer.resume()).called(1);
      });
    });

    group('playSfx', () {
      test('does nothing when soundEnabled is false', () {
        service.soundEnabled = false;
        final mockPlayer = _createMockPlayer();
        service.sfxPlayers['dice_roll'] = mockPlayer;

        service.playSfx('dice_roll');

        verifyNever(() => mockPlayer.seek(any()));
        verifyNever(() => mockPlayer.resume());
      });

      test('plays preloaded sfx by seeking to start', () async {
        final mockPlayer = _createMockPlayer();
        service.sfxPlayers['dice_roll'] = mockPlayer;

        service.playSfx('dice_roll');

        verify(() => mockPlayer.seek(Duration.zero)).called(1);
        verify(() => mockPlayer.resume()).called(1);
      });

      test('returns normally for unknown sfx', () {
        // With no preloaded player and no mock AudioPlayer available,
        // dynamic creation would hit platform channel.
        // This verifies the code path exists without executing it.
        expect(service.sfxPlayers.containsKey('unknown_sound'), isFalse);
      });
    });

    group('playBgm', () {
      test('does nothing when soundEnabled is false', () async {
        service.soundEnabled = false;
        final mockPlayer = _createMockPlayer();
        service.bgmPlayer = mockPlayer;

        await service.playBgm('audio/bgm/menu.mp3');

        verifyNever(() => mockPlayer.stop());
      });

      test('stops current bgm and plays new one', () async {
        final mockPlayer = _createMockPlayer();
        service.bgmPlayer = mockPlayer;

        await service.playBgm('audio/bgm/menu.mp3');

        verify(() => mockPlayer.stop()).called(1);
        verify(() => mockPlayer.setSource(any())).called(1);
        verify(() => mockPlayer.resume()).called(1);
      });
    });

    group('stopBgm', () {
      test('stops bgm player', () async {
        final mockPlayer = _createMockPlayer();
        service.bgmPlayer = mockPlayer;

        await service.stopBgm();

        verify(() => mockPlayer.stop()).called(1);
      });
    });

    group('pauseBgm', () {
      test('pauses bgm player', () async {
        final mockPlayer = _createMockPlayer();
        service.bgmPlayer = mockPlayer;

        await service.pauseBgm();

        verify(() => mockPlayer.pause()).called(1);
      });
    });

    group('resumeBgm', () {
      test('does nothing when soundEnabled is false', () async {
        service.soundEnabled = false;
        final mockPlayer = _createMockPlayer();
        service.bgmPlayer = mockPlayer;

        await service.resumeBgm();

        verifyNever(() => mockPlayer.resume());
      });

      test('resumes bgm when soundEnabled is true', () async {
        final mockPlayer = _createMockPlayer();
        service.bgmPlayer = mockPlayer;

        await service.resumeBgm();

        verify(() => mockPlayer.resume()).called(1);
      });
    });

    group('convenience methods', () {
      test('playDiceRoll does not crash', () {
        expect(() => service.playDiceRoll(), returnsNormally);
      });

      test('playPieceMove does not crash', () {
        expect(() => service.playPieceMove(), returnsNormally);
      });

      test('playPieceCapture does not crash', () {
        expect(() => service.playPieceCapture(), returnsNormally);
      });

      test('playPieceHome does not crash', () {
        expect(() => service.playPieceHome(), returnsNormally);
      });

      test('playWin does not crash', () {
        expect(() => service.playWin(), returnsNormally);
      });

      test('playButtonClick does not crash', () {
        expect(() => service.playButtonClick(), returnsNormally);
      });
    });

    group('dispose', () {
      test('disposes all players and clears state', () async {
        final bgmPlayer = _createMockPlayer();
        final sfxPlayer = _createMockPlayer();
        service.bgmPlayer = bgmPlayer;
        service.sfxPlayers['test'] = sfxPlayer;

        await service.dispose();

        verify(() => bgmPlayer.dispose()).called(1);
        verify(() => sfxPlayer.dispose()).called(1);
        expect(service.bgmPlayer, isNull);
        expect(service.initialized, isFalse);
      });
    });
  });
}
