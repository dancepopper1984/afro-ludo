import 'dart:math';
import '../models/whot_card.dart';
import '../models/whot_game_state.dart';

class WhotEngine {
  static const int handSize = 6;
  static const List<WhotShape> _shapes = [
    WhotShape.circle,
    WhotShape.cross,
    WhotShape.square,
    WhotShape.star,
    WhotShape.triangle,
  ];

  static List<WhotCard> createDeck() {
    final cards = <WhotCard>[];
    for (final shape in _shapes) {
      for (int num = 1; num <= 14; num++) {
        cards.add(WhotCard(shape: shape, number: num));
      }
    }
    for (int i = 0; i < 5; i++) {
      cards.add(const WhotCard(shape: WhotShape.whot, number: 20));
    }
    return cards;
  }

  static List<WhotCard> shuffle(List<WhotCard> deck) {
    final shuffled = List<WhotCard>.from(deck);
    shuffled.shuffle(Random());
    return shuffled;
  }

  static WhotGameState newGame({required int humanCount, required int totalPlayers}) {
    final deck = shuffle(createDeck());
    final players = <WhotPlayerState>[];
    for (int i = 0; i < totalPlayers; i++) {
      final hand = deck.sublist(i * handSize, (i + 1) * handSize).toList();
      final isHuman = i < humanCount;
      players.add(WhotPlayerState(
        id: i,
        name: isHuman ? 'You' : 'AI $i',
        isHuman: isHuman,
        hand: hand,
      ));
    }

    final drawStart = totalPlayers * handSize;
    final drawPile = deck.sublist(drawStart);

    final topCard = drawPile.removeAt(0);
    final discardPile = [topCard];
    final demandedShape = topCard.isWhot ? _shapes[Random().nextInt(5)] : null;

    return WhotGameState(
      players: players,
      currentPlayerIndex: 0,
      drawPile: drawPile,
      discardPile: discardPile,
      phase: WhotPhase.playing,
      demandedShape: demandedShape,
    );
  }

  static bool canPlayAny(List<WhotCard> hand, WhotGameState state) {
    return hand.any((c) => c.canPlayOn(state.topCard, demandedShape: state.demandedShape));
  }

  static WhotGameState playCard(WhotGameState state, int cardIndex, {WhotShape? callShape}) {
    final players = state.players.map((p) => p.copyWith(hand: List.from(p.hand))).toList();
    final discardPile = List<WhotCard>.from(state.discardPile);
    final drawPile = List<WhotCard>.from(state.drawPile);

    final player = players[state.currentPlayerIndex];
    final card = player.hand.removeAt(cardIndex);
    discardPile.add(card);

    WhotShape? demandedShape;
    if (card.isWhot) {
      demandedShape = callShape ?? _shapes[Random().nextInt(5)];
    }

    final winnerId = player.hasWon ? player.id : null;
    final nextPlayer = _resolveEffect(state, players, drawPile, card, demandedShape);

    return WhotGameState(
      players: players,
      currentPlayerIndex: nextPlayer,
      drawPile: drawPile,
      discardPile: discardPile,
      phase: winnerId != null ? WhotPhase.gameOver : WhotPhase.playing,
      demandedShape: card.isWhot ? demandedShape : null,
      winnerId: winnerId,
    );
  }

  static int _resolveEffect(
    WhotGameState state,
    List<WhotPlayerState> players,
    List<WhotCard> drawPile,
    WhotCard card,
    WhotShape? demandedShape,
  ) {
    final current = state.currentPlayerIndex;
    final next = _nextAlivePlayer(players, current);

    switch (card.effect) {
      case WhotEffect.holdOn:
        return current;

      case WhotEffect.pickTwo:
        _drawCards(players[next], drawPile, 2);
        return _nextAlivePlayer(players, next);

      case WhotEffect.pickThree:
        _drawCards(players[next], drawPile, 3);
        return _nextAlivePlayer(players, next);

      case WhotEffect.skip:
        return _nextAlivePlayer(players, next);

      case WhotEffect.generalMarket:
        for (int i = 0; i < players.length; i++) {
          if (i != current) {
            _drawCards(players[i], drawPile, 1);
          }
        }
        return next;

      default:
        return next;
    }
  }

  static WhotGameState drawCard(WhotGameState state) {
    final players = state.players.map((p) => p.copyWith(hand: List.from(p.hand))).toList();
    final drawPile = List<WhotCard>.from(state.drawPile);

    if (drawPile.isEmpty) {
      return state.copyWith(
        currentPlayerIndex: _nextAlivePlayer(players, state.currentPlayerIndex),
        clearDemanded: true,
      );
    }

    final player = players[state.currentPlayerIndex];
    player.hand.add(drawPile.removeAt(0));

    final drawn = player.hand.last;
    final top = state.discardPile.last;
    final canPlay = drawn.canPlayOn(top, demandedShape: state.demandedShape);

    return WhotGameState(
      players: players,
      currentPlayerIndex: canPlay ? state.currentPlayerIndex : _nextAlivePlayer(players, state.currentPlayerIndex),
      drawPile: drawPile,
      discardPile: state.discardPile,
      phase: state.phase,
      demandedShape: state.demandedShape,
      winnerId: state.winnerId,
    );
  }

  static WhotGameState skipTurn(WhotGameState state) {
    return state.copyWith(
      currentPlayerIndex: _nextAlivePlayer(state.players, state.currentPlayerIndex),
      clearDemanded: true,
    );
  }

  static int _nextAlivePlayer(List<WhotPlayerState> players, int current) {
    for (int i = 1; i <= players.length; i++) {
      final idx = (current + i) % players.length;
      if (!players[idx].hasWon) return idx;
    }
    return current;
  }

  static void _drawCards(WhotPlayerState player, List<WhotCard> drawPile, int count) {
    for (int i = 0; i < count; i++) {
      if (drawPile.isEmpty) break;
      player.hand.add(drawPile.removeAt(0));
    }
  }

  static WhotCard? aiChooseCard(WhotGameState state) {
    final hand = state.currentPlayer.hand;
    for (int i = 0; i < hand.length; i++) {
      if (hand[i].canPlayOn(state.topCard, demandedShape: state.demandedShape)) {
        return hand[i];
      }
    }
    return null;
  }

  static WhotShape aiCallShape(List<WhotCard> hand) {
    final count = <WhotShape, int>{};
    for (final card in hand) {
      if (card.shape != WhotShape.whot) {
        count[card.shape] = (count[card.shape] ?? 0) + 1;
      }
    }
    if (count.isEmpty) return _shapes[Random().nextInt(5)];
    return count.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }
}
