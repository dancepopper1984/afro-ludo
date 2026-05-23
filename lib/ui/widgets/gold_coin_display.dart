import 'package:flutter/material.dart';
import '../../core/theme.dart';

class GoldCoinDisplay extends StatelessWidget {
  final int amount;
  final double fontSize;
  final double iconSize;

  const GoldCoinDisplay({
    super.key,
    required this.amount,
    this.fontSize = 18,
    this.iconSize = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AfroTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AfroTheme.accentGold.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.monetization_on,
            color: AfroTheme.accentGold,
            size: iconSize,
          ),
          const SizedBox(width: 6),
          Text(
            amount.toString(),
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              color: AfroTheme.accentGold,
            ),
          ),
        ],
      ),
    );
  }
}
