import 'package:flutter_test/flutter_test.dart';
import 'package:afro_ludo_flutter/models/game_state.dart';
import 'package:afro_ludo_flutter/models/player.dart';

void main() {
  group('GameState', () {
    test('initial state has empty players and menu phase', () {
      final state = GameState.initial();

      expect(state.players, isEmpty);
      expect(state.currentPlayerIndex, 0);
      expect(state.diceValue, 0);
      expect(state.isRolling, false);
      expect(state.phase, GamePhase.menu);
      expect(state.consecutiveSixesCount, 0);
    });

    test('currentPlayer returns correct player', () {
      final players = [
        Player.withPieces(id: 0, name: 'Red', color: 0xFFE53935, type: PlayerType.human),
        Player.withPieces(id: 1, name: 'Green', color: 0xFF43A047, type: PlayerType.ai, aiDifficulty: AIDifficulty.medium),
      ];
      final state = GameState(
        players: players,
        currentPlayerIndex: 1,
        diceValue: 3,
        isRolling: false,
        phase: GamePhase.selecting,
      );

      expect(state.currentPlayer.id, 1);
      expect(state.currentPlayer.name, 'Green');
    });

    test('isGameOver when phase is gameOver', () {
      final state = GameState(
        players: [],
        currentPlayerIndex: 0,
        diceValue: 0,
        isRolling: false,
        phase: GamePhase.gameOver,
      );

      expect(state.isGameOver, true);
    });

    test('isGameOver is false when not gameOver', () {
      final state = GameState(
        players: [],
        currentPlayerIndex: 0,
        diceValue: 0,
        isRolling: false,
        phase: GamePhase.rolling,
      );

      expect(state.isGameOver, false);
    });

    test('copyWith changes only specified field', () {
      final state = GameState.initial();
      final updated = state.copyWith(
        diceValue: 6,
        phase: GamePhase.selecting,
      );

      expect(updated.diceValue, 6);
      expect(updated.phase, GamePhase.selecting);
      expect(updated.players, state.players);
      expect(updated.currentPlayerIndex, state.currentPlayerIndex);
    });

    test('copyWith does not mutate original', () {
      final state = GameState.initial();
      final updated = state.copyWith(diceValue: 6);

      expect(state.diceValue, 0);
      expect(updated.diceValue, 6);
    });

    test('two identical states are equal', () {
      final stateA = GameState.initial();
      final stateB = GameState.initial();

      expect(stateA, stateB);
      expect(stateA.hashCode, stateB.hashCode);
    });

    test('states with different phases are not equal', () {
      final a = GameState.initial();
      final b = a.copyWith(phase: GamePhase.rolling);

      expect(a, isNot(b));
    });

    test('states with different players are not equal', () {
      final players = [
        Player.withPieces(id: 0, name: 'Red', color: 0xFFE53935, type: PlayerType.human),
      ];
      final a = GameState.initial();
      final b = a.copyWith(players: players);

      expect(a, isNot(b));
    });

    test('consecutiveSixesCount defaults to 0', () {
      final state = GameState.initial();
      expect(state.consecutiveSixesCount, 0);
    });

    test('consecutiveSixesCount can be set', () {
      final state = GameState.initial().copyWith(consecutiveSixesCount: 2);
      expect(state.consecutiveSixesCount, 2);
    });
  });
}
