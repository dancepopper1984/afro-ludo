import 'package:flutter/material.dart';
import '../../services/storage_service.dart';
import 'menu_screen.dart';

/// 新手引导界面
///
/// 首次打开应用时的滑动教学，完成后标记 hasCompletedOnboarding。
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<_OnboardingPageData> _pages = const [
    _OnboardingPageData(
      icon: Icons.videogame_asset,
      title: 'Welcome to Afro Ludo',
      description: 'Play the classic African board game with friends or against AI.',
      color: Colors.red,
    ),
    _OnboardingPageData(
      icon: Icons.casino,
      title: 'Roll & Move',
      description: 'Roll the dice, move your pieces around the board, and race to get all 4 home first.',
      color: Colors.green,
    ),
    _OnboardingPageData(
      icon: Icons.monetization_on,
      title: 'Earn AfroCoins',
      description: 'Win games, check in daily, and watch ads to earn coins for skins and themes.',
      color: Colors.amber,
    ),
    _OnboardingPageData(
      icon: Icons.store,
      title: 'Customize Your Style',
      description: 'Visit the shop to unlock dice skins, board themes, and badges.',
      color: Colors.purple,
    ),
  ];

  void _onNext() {
    if (_currentPage < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    await StorageService.setHasCompletedOnboarding(true);
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MenuScreen()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 跳过按钮
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _finish,
                child: const Text('Skip'),
              ),
            ),

            // 页面内容
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemCount: _pages.length,
                itemBuilder: (context, index) => _OnboardingPage(data: _pages[index]),
              ),
            ),

            // 指示器 + 按钮
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // 页码指示点
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (int i = 0; i < _pages.length; i++)
                        Container(
                          width: i == _currentPage ? 24 : 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: i == _currentPage
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 下一步 / 开始 按钮
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _onNext,
                      child: Text(
                        _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                      ),
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

class _OnboardingPageData {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const _OnboardingPageData({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}

class _OnboardingPage extends StatelessWidget {
  final _OnboardingPageData data;

  const _OnboardingPage({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: data.color.withValues(alpha: 0.2),
            ),
            child: Icon(
              data.icon,
              size: 64,
              color: data.color,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            data.title,
            style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            data.description,
            style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
