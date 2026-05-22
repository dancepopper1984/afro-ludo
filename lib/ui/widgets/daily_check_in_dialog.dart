import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../notifiers/economy_notifier.dart';

/// 每日签到弹窗
///
/// 显示今日签到奖励和连续签到天数。
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
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_today,
              size: 48,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Daily Check-In',
              style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            if (reward > 0) ...[
              Text(
                'You earned',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.monetization_on,
                    color: Colors.amber.shade700,
                    size: 32,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '+$reward',
                    style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.amber.shade700,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (streak > 1)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '$streak Day Streak!',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
            ] else ...[
              Text(
                'You have already checked in today.',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Claim'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 触发每日签到检查并显示弹窗（如需要）
///
/// 仅在今日首次签到时弹窗，已签到则静默跳过。
Future<void> showDailyCheckInIfNeeded(BuildContext context, WidgetRef ref) async {
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
