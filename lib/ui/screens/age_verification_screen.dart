import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../services/storage_service.dart';
import '../widgets/kente_strip.dart';
import 'menu_screen.dart';

class AgeVerificationScreen extends StatelessWidget {
  const AgeVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AfroTheme.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 卡片
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AfroTheme.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: AfroTheme.accentGold.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      // Kente 顶部装饰
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                        child: KenteStrip(
                          height: 8,
                          animate: false,
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(28),
                        child: Column(
                          children: [
                            Icon(
                              Icons.shield_outlined,
                              size: 56,
                              color: AfroTheme.accentGold,
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Age Verification',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: AfroTheme.textPrimary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'To comply with child safety laws, we need to verify your age.',
                              style: TextStyle(
                                fontSize: 14,
                                color: AfroTheme.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Are you 13 years of age or older?',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AfroTheme.textPrimary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 28),

                            // "Yes" 按钮
                            SizedBox(
                              width: double.infinity,
                              child: _AgeButton(
                                label: 'Yes, I am 13 or older',
                                gradient: const LinearGradient(
                                  colors: [
                                    AfroTheme.primary,
                                    AfroTheme.primaryDark,
                                  ],
                                ),
                                onPressed: () => _confirmAge(context),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // "No" 按钮
                            SizedBox(
                              width: double.infinity,
                              child: _AgeButton(
                                label: 'No, I am under 13',
                                borderColor: AfroTheme.accentGold,
                                onPressed: () => _denyAge(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                const Text(
                  'By continuing, you agree to our Terms of Service and Privacy Policy.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AfroTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmAge(BuildContext context) async {
    await StorageService.setAgeVerified(true);
    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MenuScreen()),
      );
    }
  }

  void _denyAge(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AfroTheme.surface,
        title: const Text('Sorry',
            style: TextStyle(color: AfroTheme.textPrimary)),
        content: const Text(
          'You must be at least 13 years old to use Afro Ludo. The app will now close.',
          style: TextStyle(color: AfroTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK',
                style: TextStyle(color: AfroTheme.accentGold)),
          ),
        ],
      ),
    );
  }
}

class _AgeButton extends StatefulWidget {
  final String label;
  final Gradient? gradient;
  final Color? borderColor;
  final VoidCallback onPressed;

  const _AgeButton({
    required this.label,
    this.gradient,
    this.borderColor,
    required this.onPressed,
  });

  @override
  State<_AgeButton> createState() => _AgeButtonState();
}

class _AgeButtonState extends State<_AgeButton>
    with SingleTickerProviderStateMixin {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    final hasGradient = widget.gradient != null;

    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.97),
      onTapUp: (_) {
        setState(() => _scale = 1.0);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 150),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: hasGradient ? widget.gradient : null,
            color: hasGradient ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: !hasGradient
                ? Border.all(
                    color: widget.borderColor ?? AfroTheme.accentGold,
                    width: 1.5)
                : null,
          ),
          child: Center(
            child: Text(
              widget.label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: hasGradient
                    ? AfroTheme.textPrimary
                    : (widget.borderColor ?? AfroTheme.accentGold),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
