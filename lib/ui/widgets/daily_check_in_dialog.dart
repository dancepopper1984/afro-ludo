import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../notifiers/economy_notifier.dart';
import 'kente_strip.dart';

class DailyCheckInDialog extends ConsumerWidget {
  final int reward;
  final int streak;

  const DailyCheckInDialog({
    super.key,
    required this.reward,
    required this.streak,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: AfroTheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AfroTheme.accentGold.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
              child: const KenteStrip(height: 8, animate: false),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.calendar_today,
                      size: 48, color: AfroTheme.accentGold),
                  const SizedBox(height: 14),
                  const Text(
                    'Daily Check-In',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AfroTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (reward > 0) ...[
                    const Text('You earned',
                        style: TextStyle(color: AfroTheme.textSecondary)),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.monetization_on,
                            color: AfroTheme.accentGold, size: 36),
                        const SizedBox(width: 8),
                        Text(
                          '+$reward',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: AfroTheme.accentGold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (streak > 1)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: AfroTheme.accentGold.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '$streak Day Streak!',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AfroTheme.accentGold,
                          ),
                        ),
                      ),
                    // 连续签到进度
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(7, (i) {
                        final day = i + 1;
                        final isActive = day <= streak;
                        return Container(
                          width: 32,
                          height: 32,
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isActive
                                ? AfroTheme.accentGold
                                : AfroTheme.surface,
                            border: Border.all(
                              color: isActive
                                  ? AfroTheme.accentGold
                                  : AfroTheme.textSecondary.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '$day',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: isActive
                                    ? const Color(0xFF1A1A2E)
                                    : AfroTheme.textSecondary,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ] else ...[
                    const Text(
                      'You have already checked in today.',
                      style: TextStyle(color: AfroTheme.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AfroTheme.secondary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('Claim',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> showDailyCheckInIfNeeded(
    BuildContext context, WidgetRef ref) async {
  final notifier = ref.read(economyNotifierProvider.notifier);
  final reward = notifier.dailyCheckIn(DateTime.now());
  final state = ref.read(economyNotifierProvider);

  if (reward == 0) return;

  if (context.mounted) {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => DailyCheckInDialog(
        reward: reward,
        streak: state.loginStreak,
      ),
    );
  }
}
