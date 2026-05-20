/// 经济状态
class EconomyState {
  final int afroCoins;
  final int totalEarned;
  final int dailyEarned;
  final DateTime? lastLoginDate;
  final int loginStreak;

  const EconomyState({
    required this.afroCoins,
    required this.totalEarned,
    required this.dailyEarned,
    this.lastLoginDate,
    required this.loginStreak,
  });

  factory EconomyState.initial() {
    return const EconomyState(
      afroCoins: 300,
      totalEarned: 300,
      dailyEarned: 0,
      loginStreak: 0,
    );
  }

  EconomyState copyWith({
    int? afroCoins,
    int? totalEarned,
    int? dailyEarned,
    DateTime? lastLoginDate,
    int? loginStreak,
  }) {
    return EconomyState(
      afroCoins: afroCoins ?? this.afroCoins,
      totalEarned: totalEarned ?? this.totalEarned,
      dailyEarned: dailyEarned ?? this.dailyEarned,
      lastLoginDate: lastLoginDate ?? this.lastLoginDate,
      loginStreak: loginStreak ?? this.loginStreak,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EconomyState &&
          runtimeType == other.runtimeType &&
          afroCoins == other.afroCoins &&
          totalEarned == other.totalEarned &&
          dailyEarned == other.dailyEarned &&
          lastLoginDate == other.lastLoginDate &&
          loginStreak == other.loginStreak;

  @override
  int get hashCode => Object.hash(
        afroCoins,
        totalEarned,
        dailyEarned,
        lastLoginDate,
        loginStreak,
      );

  @override
  String toString() =>
      'EconomyState(coins: $afroCoins, totalEarned: $totalEarned, dailyEarned: $dailyEarned, streak: $loginStreak)';
}
