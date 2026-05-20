import 'whot_card.dart';

enum WhotPhase { playing, gameOver }

class WhotPlayerState {
  final int id;
  final String name;
  final bool isHuman;
  final List<WhotCard> hand;

  const WhotPlayerState({
    required this.id,
    required this.name,
    required this.isHuman,
    required this.hand,
  });

  bool get hasWon => hand.isEmpty;

  WhotPlayerState copyWith({List<WhotCard>? hand}) {
    return WhotPlayerState(
      id: id,
      name: name,
      isHuman: isHuman,
      hand: hand ?? this.hand,
    );
  }
}

class WhotGameState {
  final List<WhotPlayerState> players;
  final int currentPlayerIndex;
  final List<WhotCard> drawPile;
  final List<WhotCard> discardPile;
  final WhotPhase phase;
  final WhotShape? demandedShape;
  final int? winnerId;

  const WhotGameState({
    required this.players,
    required this.currentPlayerIndex,
    required this.drawPile,
    required this.discardPile,
    required this.phase,
    this.demandedShape,
    this.winnerId,
  });

  WhotPlayerState get currentPlayer => players[currentPlayerIndex];
  WhotCard get topCard => discardPile.last;

  WhotGameState copyWith({
    List<WhotPlayerState>? players,
    int? currentPlayerIndex,
    List<WhotCard>? drawPile,
    List<WhotCard>? discardPile,
    WhotPhase? phase,
    WhotShape? demandedShape,
    int? winnerId,
    bool clearDemanded = false,
  }) {
    return WhotGameState(
      players: players ?? this.players,
      currentPlayerIndex: currentPlayerIndex ?? this.currentPlayerIndex,
      drawPile: drawPile ?? this.drawPile,
      discardPile: discardPile ?? this.discardPile,
      phase: phase ?? this.phase,
      demandedShape: clearDemanded ? null : (demandedShape ?? this.demandedShape),
      winnerId: winnerId ?? this.winnerId,
    );
  }
}
