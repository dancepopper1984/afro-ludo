import 'package:flutter/material.dart';
import '../../core/theme.dart';

class AfroButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onPressed;
  final Gradient? gradient;
  final Color? borderColor;
  final Color? textColor;
  final bool isFullWidth;
  final double height;

  const AfroButton({
    super.key,
    required this.label,
    this.icon,
    required this.onPressed,
    this.gradient,
    this.borderColor,
    this.textColor,
    this.isFullWidth = true,
    this.height = 60,
  });

  @override
  State<AfroButton> createState() => _AfroButtonState();
}

class _AfroButtonState extends State<AfroButton>
    with SingleTickerProviderStateMixin {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    final hasGradient = widget.gradient != null;
    final hasBorder = widget.borderColor != null;

    return AnimatedScale(
      scale: _scale,
      duration: const Duration(milliseconds: 150),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _scale = 0.97),
        onTapUp: (_) {
          setState(() => _scale = 1.0);
          widget.onPressed();
        },
        onTapCancel: () => setState(() => _scale = 1.0),
        child: Container(
          width: widget.isFullWidth ? double.infinity : null,
          height: widget.height,
          decoration: BoxDecoration(
            gradient: hasGradient
                ? widget.gradient
                : (hasBorder ? null : const LinearGradient(
                    colors: [AfroTheme.primary, AfroTheme.primaryDark],
                  )),
            color: (!hasGradient && hasBorder) ? Colors.transparent : null,
            borderRadius: BorderRadius.circular(16),
            border: hasBorder
                ? Border.all(color: widget.borderColor!, width: 1.5)
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(
                  widget.icon,
                  color: widget.textColor ??
                      (hasBorder ? widget.borderColor : AfroTheme.textPrimary),
                  size: 24,
                ),
                const SizedBox(width: 12),
              ],
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: widget.textColor ??
                      (hasBorder ? widget.borderColor : AfroTheme.textPrimary),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                color: (widget.textColor ?? AfroTheme.textPrimary)
                    .withValues(alpha: 0.5),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
