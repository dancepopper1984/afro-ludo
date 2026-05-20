# Splash + 年龄验证 开发规格

## 需求概述
实现应用启动流程：Splash 屏幕 → 年龄验证（首次）→ 主菜单

---

## 1. Splash 屏幕

### 设计规格
- **显示时长**: 2-3 秒（或资源加载完成后）
- **背景**: 非洲风格图案/渐变（使用 AppTheme.primaryColor）
- **内容**:
  - 应用 Logo（居中）
  - 应用名称 "Afro Ludo"
  - 可选：加载指示器（CircularProgressIndicator）
- **过渡**: 淡入淡出动画

### 技术实现
```dart
// lib/screens/splash_screen.dart
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    // 并行初始化
    await Future.wait([
      _preloadAssets(),
      _checkFirstLaunch(),
      Future.delayed(const Duration(seconds: 2)), // 最少显示 2 秒
    ]);

    // 导航到下一页
    if (mounted) {
      final needsAgeVerify = await _needsAgeVerification();
      context.go(needsAgeVerify ? '/age-verify' : '/menu');
    }
  }

  Future<void> _preloadAssets() async {
    // 预加载图片、音效
  }

  Future<bool> _checkFirstLaunch() async {
    // 检查是否首次启动
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('first_launch') ?? true;
  }

  Future<bool> _needsAgeVerification() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_age') == null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryColor,
              AppTheme.primaryColorDark,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Image.asset('assets/images/logo.png', width: 120, height: 120),
              const SizedBox(height: 24),
              // 应用名称
              Text(
                'Afro Ludo',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 48),
              // 加载指示器
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

## 2. 年龄验证界面

### 设计规格
- **标题**: "Welcome to Afro Ludo"
- **说明文字**: "Please select your age to continue"
- **年龄选择**: 滑块或数字选择器
  - 范围：5-100 岁
  - 默认：18 岁
- **确认按钮**: "Continue"
- **隐私提示**: "Your age is only used to ensure age-appropriate content"

### 业务规则
- 年龄 < 13：提示 "This app is not intended for users under 13"
- 年龄 13-17：允许使用，但标记为未成年
- 年龄 ≥ 18：正常使用
- 选择后保存到本地存储，不再重复询问

### 技术实现
```dart
// lib/screens/age_verify_screen.dart
class AgeVerifyScreen extends StatefulWidget {
  const AgeVerifyScreen({super.key});

  @override
  State<AgeVerifyScreen> createState() => _AgeVerifyScreenState();
}

class _AgeVerifyScreenState extends State<AgeVerifyScreen> {
  double _selectedAge = 18;

  Future<void> _onContinue() async {
    final age = _selectedAge.round();
    
    if (age < 13) {
      _showUnderAgeDialog();
      return;
    }

    // 保存年龄
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_age', age);
    await prefs.setBool('is_minor', age < 18);

    // 导航到主菜单
    if (mounted) {
      context.go('/menu');
    }
  }

  void _showUnderAgeDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Age Restriction'),
        content: const Text(
          'This app is not intended for users under 13. '
          'Please check with a parent or guardian.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to Afro Ludo',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Please select your age to continue',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 48),
            // 年龄显示
            Text(
              '${_selectedAge.round()}',
              style: const TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const Text('years old', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            // 年龄滑块
            Slider(
              value: _selectedAge,
              min: 5,
              max: 100,
              divisions: 95,
              label: _selectedAge.round().toString(),
              onChanged: (value) {
                setState(() => _selectedAge = value);
              },
            ),
            const SizedBox(height: 48),
            // 继续按钮
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _onContinue,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Continue', style: TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(height: 16),
            // 隐私提示
            const Text(
              'Your age is only used to ensure age-appropriate content',
              style: TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 3. 路由配置更新

```dart
// lib/main.dart 或 lib/router.dart
final router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/age-verify',
      builder: (context, state) => const AgeVerifyScreen(),
    ),
    GoRoute(
      path: '/menu',
      builder: (context, state) => const MainMenuScreen(),
    ),
    // ... 其他路由
  ],
);
```

---

## 4. 依赖添加

```yaml
# pubspec.yaml 添加（如果还没有）
dependencies:
  shared_preferences: ^2.2.2
```

---

## 5. 资源需求

| 资源 | 路径 | 说明 |
|------|------|------|
| Logo | assets/images/logo.png | 应用 Logo，建议 512×512 |
| 背景图案 | assets/images/splash_bg.png | 可选，非洲风格图案 |

---

## 6. 测试要点

- [ ] Splash 显示 2-3 秒后自动跳转
- [ ] 首次启动进入年龄验证
- [ ] 非首次启动跳过年龄验证
- [ ] 年龄 < 13 显示限制提示
- [ ] 年龄选择保存到本地
- [ ] 旋转屏幕后状态保持
- [ ] 按返回键不退出应用（Splash 和年龄验证）

---

## 7. 与现有代码集成

### 需要修改的文件
1. `lib/main.dart` - 更新初始路由为 `/splash`
2. `lib/router.dart`（如存在）- 添加 Splash 和年龄验证路由
3. `pubspec.yaml` - 添加 `shared_preferences` 依赖

### 新增文件
1. `lib/screens/splash_screen.dart`
2. `lib/screens/age_verify_screen.dart`

---

## 备注
- 年龄验证为 COPPA/GDPR 合规要求
- 实际年龄数据不上传服务器，仅本地存储
- 后续可扩展为完整的家长控制功能
