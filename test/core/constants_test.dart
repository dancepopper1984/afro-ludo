import 'package:flutter_test/flutter_test.dart';
import 'package:afro_ludo_flutter/core/constants.dart';

void main() {
  group('Board Constants', () {
    test('track length is 52', () {
      expect(kTrackLength, 52);
    });

    test('home track length is 5', () {
      expect(kHomeTrackLength, 5);
    });

    test('player count is 4', () {
      expect(kPlayerCount, 4);
    });

    test('pieces per player is 4', () {
      expect(kPiecesPerPlayer, 4);
    });

    test('exit base requires 6', () {
      expect(kExitBaseDiceValue, 6);
    });

    test('max consecutive sixes is 3', () {
      expect(kMaxConsecutiveSixes, 3);
    });
  });

  group('Safe Zones', () {
    test('has exactly 8 safe zones', () {
      expect(kSafeZones.length, 8);
    });

    test('safe zones are correct positions', () {
      expect(kSafeZones, [0, 8, 13, 21, 26, 34, 39, 47]);
    });

    test('all safe zones are within track bounds', () {
      for (final zone in kSafeZones) {
        expect(zone, greaterThanOrEqualTo(0));
        expect(zone, lessThan(kTrackLength));
      }
    });
  });

  group('Player Configs', () {
    test('has 4 players', () {
      expect(kPlayerConfigs.length, 4);
    });

    test('player IDs are 0-3', () {
      for (int i = 0; i < kPlayerConfigs.length; i++) {
        expect(kPlayerConfigs[i].id, i);
      }
    });

    test('player names are correct', () {
      expect(kPlayerConfigs[0].name, 'Red');
      expect(kPlayerConfigs[1].name, 'Green');
      expect(kPlayerConfigs[2].name, 'Yellow');
      expect(kPlayerConfigs[3].name, 'Blue');
    });

    test('player 0 (Red) starts at 0, home entry at 51', () {
      expect(kPlayerConfigs[0].startPosition, 0);
      expect(kPlayerConfigs[0].homeEntry, 51);
    });

    test('player 1 (Green) starts at 13, home entry at 12', () {
      expect(kPlayerConfigs[1].startPosition, 13);
      expect(kPlayerConfigs[1].homeEntry, 12);
    });

    test('player 2 (Yellow) starts at 26, home entry at 25', () {
      expect(kPlayerConfigs[2].startPosition, 26);
      expect(kPlayerConfigs[2].homeEntry, 25);
    });

    test('player 3 (Blue) starts at 39, home entry at 38', () {
      expect(kPlayerConfigs[3].startPosition, 39);
      expect(kPlayerConfigs[3].homeEntry, 38);
    });

    test('all start positions are within track bounds', () {
      for (final config in kPlayerConfigs) {
        expect(config.startPosition, greaterThanOrEqualTo(0));
        expect(config.startPosition, lessThan(kTrackLength));
      }
    });

    test('all home entries are within track bounds', () {
      for (final config in kPlayerConfigs) {
        expect(config.homeEntry, greaterThanOrEqualTo(0));
        expect(config.homeEntry, lessThan(kTrackLength));
      }
    });
  });

  group('Economy Constants', () {
    test('initial coins is 300', () {
      expect(EconomyConstants.initialCoins, 300);
    });

    test('daily earning limit is 1000', () {
      expect(EconomyConstants.dailyEarningLimit, 1000);
    });

    test('first place reward is 100', () {
      expect(EconomyConstants.firstPlaceReward, 100);
    });

    test('second place reward is 80', () {
      expect(EconomyConstants.secondPlaceReward, 80);
    });

    test('ad reward is 50', () {
      expect(EconomyConstants.adRewardAmount, 50);
    });

    test('first win bonus is 50', () {
      expect(EconomyConstants.firstWinBonus, 50);
    });

    test('daily check-in base is 50', () {
      expect(EconomyConstants.dailyCheckInBase, 50);
    });
  });

  group('Board Visual Config', () {
    test('grid size is 15', () {
      expect(BoardVisualConfig.gridSize, 15);
    });

    test('cell count is 225', () {
      expect(BoardVisualConfig.cellCount, 225);
    });
  });
}
