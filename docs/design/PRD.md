# Afro Ludo - 产品需求文档 (PRD)

> 版本: v1.0 | 日期: 2026-05-19
> 状态: 待审核

---

## 一、产品概述

### 1.1 产品定位

非洲本土化休闲棋牌游戏，核心玩法为 Ludo（飞行棋）+ Whot（尼日利亚传统卡牌），面向非洲 16-35 岁 Android 用户。

### 1.2 目标市场

| 维度 | 详情 |
|------|------|
| 核心国家 | 尼日利亚、肯尼亚、加纳 |
| 目标设备 | 中低端 Android（1-2GB RAM，Android 8+） |
| 网络环境 | 3G/4G 为主，支持离线 playable |
| 包体目标 | 12-15 MB（App Bundle 分包后） |

### 1.3 核心卖点

1. **超轻量** - 12-15MB，远低于 Ludo King（50MB）
2. **非洲文化** - Afro 主题皮肤、音乐、配色
3. **双模式** - Ludo + Whot 合一
4. **离线 playable** - 无网络也能玩 AI 局

---

## 二、功能需求清单

### 2.1 Ludo 模式

| 功能 | 优先级 | 说明 |
|------|--------|------|
| 经典棋盘（15x15） | P0 | 标准 Ludo 棋盘，4 色家园 |
| 1人 vs 3 AI | P0 | 玩家选 1 个颜色，其余 3 色由 AI 控制 |
| Pass & Play | P0 | 2-4 人本地轮流（一台手机） |
| AI 三档难度 | P0 | Easy / Medium / Hard |
| 标准/快速模式 | P1 | 快速模式：棋子只需绕一圈到家 |
| 安全区规则 | P0 | 星标格子为安全区，不可被吃 |
| 吃子规则 | P0 | 落在敌方棋子格子上，敌方棋子回基地 |
| 6 点出基地 | P0 | 掷出 6 才能从基地出棋子 |
| 连掷奖励 | P0 | 掷出 6 可再掷一次 |
| 胜负判定 | P0 | 4 个棋子全部到家即获胜 |

### 2.2 Whot 模式

| 功能 | 优先级 | 说明 |
|------|--------|------|
| 73 张牌标准规则 | P2 | 尼日利亚 Whot 规则（V1.1） |
| 1人 vs 1 AI | P2 | V1.1 做 1v1 |
| 5 种形状 | P2 | Circle, Square, Star, Cross, Triangle |
| 特殊牌效果 | P2 | Hold On, Pick Two, Pick Three, General Market, Suspension |

### 2.3 经济系统

| 功能 | 优先级 | 说明 |
|------|--------|------|
| AfroCoins 货币 | P0 | 游戏内虚拟货币 |
| 初始赠送 | P0 | 新用户 300 coins |
| 赢局奖励 | P0 | 第一名 +100，第二名 +80 |
| 每日签到 | P0 | 连续 7 天递增奖励（50→100→150...） |
| 每日上限 | P0 | 单日最多获得 1000 coins（防刷） |
| 看广告赚币 | P0 | 激励视频 +50 coins |
| 幸运转盘 | P1 | 每日免费 1 次，付费额外转 |

### 2.4 商店系统

| 功能 | 优先级 | 说明 |
|------|--------|------|
| 棋盘主题 | P1 | 默认、萨凡纳、部落、星空等 |
| 棋子皮肤 | P1 | 不同 Afro 风格纹理 |
| 骰子皮肤 | P1 | 不同材质外观 |
| 价格区间 | P1 | 200-2000 coins |

### 2.5 广告系统

| 功能 | 优先级 | 说明 |
|------|--------|------|
| 激励视频 | P0 | 看广告赚 coins，用户主动触发 |
| 插屏广告 | P0 | 每 3 局结束后显示 |
| Banner 广告 | P1 | 商店/菜单页面底部 |
| 频率限制 | P0 | 插屏最少间隔 60 秒 |

### 2.6 内购系统 (IAP)

| 功能 | 优先级 | 说明 |
|------|--------|------|
| Premium 订阅 | P1 | $2.99/月，去广告 + 每日 bonus |
| 金币包 | P1 | $0.99（1000币）、$4.99（6000币） |
| Starter Pack | P1 | $0.99 新手包（限定 1 次） |

### 2.7 其他系统

| 功能 | 优先级 | 说明 |
|------|--------|------|
| 多语言 | P1 | 首版仅英文，V1.1 评估非洲本地语言 |
| 音效/震动 | P0 | 掷骰子、移动、吃子、胜利音效 |
| 设置 | P0 | 音效开关、震动开关、语言切换 |
| 排行榜 | P1 | 本地排行榜（金币、胜场） |
| 成就系统 | P1 | 15+ 个成就 |
| 分享 | P1 | WhatsApp 分享战绩 |
| 新手引导 | P0 | 首次进入高亮提示 |
| 年龄验证 | P0 | 13+ 确认弹窗（COPPA 合规） |

---

## 三、技术架构

### 3.1 技术栈

| 层级 | 技术 | 版本 |
|------|------|------|
| 跨平台框架 | Flutter | 3.27.1 |
| 渲染方案 | 纯 Flutter Widget | CustomPainter + Stack |
| 状态管理 | Riverpod | 2.6+ |
| 本地存储 | Hive | 2.2+ |
| 广告 | google_mobile_ads | 5.1+ |
| 内购 | in_app_purchase | 3.2+ |
| 音频 | audioplayers | 6.0+ |
| 多语言 | 预留 flutter_localizations 接口 | 首版硬编码英文 |

### 3.2 项目结构

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── constants.dart          # 游戏常量（棋盘大小、颜色等）
│   ├── theme.dart              # Afro 主题配色
│   └── extensions.dart         # Dart 扩展方法
├── l10n/
│   └── app_en.arb              # 英语（首版唯一语言）
├── models/
│   ├── game_state.dart
│   ├── player.dart
│   ├── piece.dart
│   ├── economy_state.dart
│   └── settings_state.dart
├── game/                       # 纯 Dart 游戏逻辑，无 Flutter 依赖
│   ├── ludo/
│   │   ├── board.dart          # 棋盘数据（52+5 轨道）
│   │   ├── move_rules.dart     # 移动规则
│   │   ├── capture_rules.dart  # 吃子规则
│   │   ├── win_checker.dart    # 胜负判定
│   │   └── ai_strategy.dart    # AI 决策
│   └── whot/                   # V1.1
│       ├── deck.dart
│       ├── rules.dart
│       └── ai.dart
├── ui/
│   ├── screens/
│   │   ├── splash_screen.dart
│   │   ├── onboarding_screen.dart
│   │   ├── menu_screen.dart
│   │   ├── ludo_game_screen.dart
│   │   ├── whot_game_screen.dart
│   │   ├── shop_screen.dart
│   │   ├── settings_screen.dart
│   │   ├── leaderboard_screen.dart
│   │   └── season_screen.dart
│   ├── widgets/
│   │   ├── coin_display.dart
│   │   ├── player_avatar.dart
│   │   ├── dice_widget.dart
│   │   └── board_painter.dart  # CustomPainter
│   └── notifiers/
│       ├── game_notifier.dart
│       ├── economy_notifier.dart
│       └── settings_notifier.dart
└── services/
    ├── ads_service.dart
    ├── iap_service.dart
    ├── audio_service.dart
    ├── storage_service.dart
    └── analytics_service.dart
```

### 3.3 状态管理（Riverpod）

```dart
// 游戏状态
@freezed
class GameState with _$GameState {
  const factory GameState({
    required List<Player> players,
    required int currentPlayerIndex,
    required int diceValue,
    required bool isRolling,
    required GamePhase phase, // rolling, selecting, moving, ended
  }) = _GameState;
}

// 经济状态
@freezed
class EconomyState with _$EconomyState {
  const factory EconomyState({
    required int afroCoins,
    required int totalEarned,
    required int dailyEarned,
    required DateTime lastLoginDate,
    required int loginStreak,
  }) = _EconomyState;
}
```

### 3.4 网络层设计

```dart
/// 网络抽象层：统一封装所有外部依赖的网络调用
/// 首版仅有广告填充、IAP 验证需要网络，其他全部离线
abstract class NetworkClient {
  /// AdMob 广告加载（由 google_mobile_ads SDK 内部处理）
  /// 本层仅做网络状态监听和失败重试策略

  /// IAP 购买验证（本地优先，服务端回调查验 V1.1）
  Future<PurchaseVerification> verifyPurchase(String purchaseToken);

  /// 通用网络状态检测
  static Future<bool> get hasConnection async {
    // 使用 connectivity_plus，仅判断是否可联网
    // 不阻塞任何游戏功能
  }
}

/// 网络不可用时的降级策略
class OfflineFallback {
  static const Map<String, dynamic> defaultConfig = {
    'adEnabled': false,      // 离线时不加载广告
    'iapEnabled': false,     // 离线时禁用购买按钮
    'dailyCheckIn': true,    // 签到可离线完成，联网后同步
  };
}
```

| 模块 | 网络依赖 | 离线降级 |
|------|---------|---------|
| 广告加载 | ✅ 必须联网 | 隐藏广告按钮，Premium 状态本地缓存 |
| IAP 购买 | ✅ 必须联网 | 禁用购买入口，提示"需联网" |
| 每日签到 | ⚠️ 本地计算，联网同步 | 允许离线签到，恢复网络后上报 |
| 游戏对局 | ❌ 无需网络 | 完全离线 playable |
| 排行榜 | ✅ 需后端（V1.1） | 仅显示本地缓存 |

### 3.5 崩溃监控（Firebase Crashlytics）

```yaml
# pubspec.yaml 依赖
firebase_core: ^3.0.0
firebase_crashlytics: ^4.0.0
```

```dart
/// main.dart 初始化
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // 崩溃监控：仅 Release 模式启用
  if (kReleaseMode) {
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  runApp(const AfroLudoApp());
}

/// 业务层自定义日志
class AnalyticsService {
  static void logGameStart(String mode, String difficulty) {
    FirebaseCrashlytics.instance.log('Game start: mode=$mode, difficulty=$difficulty');
  }

  static void logEconomyEvent(String event, int amount) {
    FirebaseCrashlytics.instance.setCustomKey('last_economy_event', '$event:$amount');
  }
}
```

| 监控项 | 级别 | 触发条件 |
|--------|------|---------|
| 未捕获异常 | fatal | Dart/Flutter 崩溃 |
| 游戏状态异常 | error | 棋子位置越界、经济负数等 |
| 广告加载失败 | warning | 广告填充率低于阈值 |
| IAP 回调异常 | error | 购买成功但未到账 |
| 性能卡顿 | warning | 帧率低于 30fps 持续 3 秒 |

---

## 四、数据模型

### 4.1 核心模型

```dart
// 玩家
class Player {
  final int id;              // 0-3
  final String name;
  final Color color;
  final PlayerType type;     // human, ai
  final List<Piece> pieces;
  final AIDifficulty? aiDifficulty;
}

// 棋子
class Piece {
  final int id;              // 0-3，每玩家4个
  final int playerId;
  PieceStatus status;        // base, track, homeTrack, home
  int position;              // -1 = base, 0-51 = track, 0-4 = homeTrack
}

// 棋盘格子
class Cell {
  final int index;
  final CellType type;       // normal, safe, start, home
  final int? ownerPlayerId;  // 哪个玩家的家园/起点
}
```

### 4.2 本地存储结构（Hive）

```
economy_box/
  ├── afroCoins: int
  ├── totalEarned: int
  ├── dailyEarnings: Map<String, int>  // date -> amount
  ├── lastLoginDate: String
  ├── loginStreak: int
  └── ownedSkins: List<String>

settings_box/
  ├── language: String        // 'en'（首版仅英文）
  ├── soundEnabled: bool
  ├── hapticsEnabled: bool
  ├── aiDifficulty: String    // 'easy', 'medium', 'hard'
  └── hasCompletedOnboarding: bool

game_stats_box/
  ├── totalGames: int
  ├── totalWins: int
  ├── winStreak: int
  ├── bestWinStreak: int
  └── achievements: Map<String, bool>
```

---

## 五、游戏逻辑设计

### 5.1 Ludo 棋盘（视觉与逻辑分离）

**视觉层**：15×15 网格，用于 `CustomPainter` 渲染，包含家园区域、轨道格子、安全区标记。

**逻辑层**：标准 52+5 轨道
```
外圈：52 格（每玩家 13 格）
Home track：每玩家 5 格

玩家 0 (Red):    起点 = 0,   home entry = 51
玩家 1 (Green):  起点 = 13,  home entry = 12
玩家 2 (Yellow): 起点 = 26,  home entry = 25
玩家 3 (Blue):   起点 = 39,  home entry = 38

安全区（星标）: 0, 8, 13, 21, 26, 34, 39, 47
```

### 5.2 移动规则

```dart
class MoveRules {
  // 棋子能否移动
  static bool canMove(Piece piece, int diceValue, GameState state) {
    if (piece.status == PieceStatus.base) {
      return diceValue == 6; // 只有6才能出基地
    }
    if (piece.status == PieceStatus.homeTrack) {
      return piece.position + diceValue <= 4; // home track 5格，0-4，不能超
    }
    return true;
  }
  
  // 计算移动后的位置
  static int calculateNewPosition(Piece piece, int diceValue) {
    if (piece.status == PieceStatus.track) {
      int rawNewPos = piece.position + diceValue;
      int homeEntry = getHomeEntry(piece.playerId);

      // 先判断是否进入 home track（绕圈前判断）
      if (piece.position <= homeEntry && rawNewPos >= homeEntry) {
        int homeTrackPos = rawNewPos - homeEntry;
        if (homeTrackPos <= 4) return homeTrackPos; // 进入 home track
      }

      // 正常轨道移动
      int newPos = rawNewPos;
      if (newPos >= 52) newPos -= 52; // 绕圈
      return newPos;
    }
    // ...
  }
}
```

### 5.3 吃子规则

```dart
class CaptureRules {
  static Piece? checkCapture(int cellIndex, int attackerPlayerId, GameState state) {
    // 安全区不能吃
    if (isSafeZone(cellIndex)) return null;
    
    // 检查该格是否有敌方棋子
    for (final player in state.players) {
      if (player.id == attackerPlayerId) continue;
      for (final piece in player.pieces) {
        if (piece.position == cellIndex && piece.status == PieceStatus.track) {
          return piece; // 可被吃
        }
      }
    }
    return null;
  }
}
```

### 5.4 胜负判定

```dart
class WinChecker {
  static bool hasWon(Player player) {
    return player.pieces.every(
      (p) => p.status == PieceStatus.home
    );
  }
  
  static List<Player> getRanking(GameState state) {
    // 按到家棋子数排序
    return state.players.sorted(
      (a, b) => b.homePiecesCount.compareTo(a.homePiecesCount)
    );
  }
}
```

---

## 六、AI 设计

### 6.1 评分系统

```dart
class AIStrategy {
  double scoreMove(Piece piece, int diceValue, GameState state) {
    double score = 0;
    final newPos = calculateNewPosition(piece, diceValue);
    
    // 1. 能出基地 (+50)
    if (piece.status == PieceStatus.base && diceValue == 6) {
      score += 50;
    }
    
    // 2. 能吃子 (+100，最高优先级)
    final captured = CaptureRules.checkCapture(newPos, piece.playerId, state);
    if (captured != null) score += 100;
    
    // 3. 能到家 (+80)
    if (newPos.status == PieceStatus.home) score += 80;
    
    // 4. 能进 home track (+40)
    if (piece.status == PieceStatus.track && 
        newPos.status == PieceStatus.homeTrack) {
      score += 40;
    }
    
    // 5. 逃离危险区 (+30)
    if (isInDanger(piece) && !isInDangerAt(newPos)) score += 30;
    
    // 6. 基础前进分
    score += diceValue * 2;
    
    return score;
  }
}
```

### 6.2 三档难度

| 难度 | 策略 | 玩家胜率目标 |
|------|------|-------------|
| **Easy** | 优先移动最前面的棋子，不评估风险 | ~80% |
| **Medium** | 正常评分系统，10% 概率选次优解 | ~50% |
| **Hard** | 完美评分 + 预判玩家下一步（模拟玩家掷6时能否吃回） | ~30% |

### 6.3 动态难度调整

```dart
class DifficultyAdjuster {
  static AIDifficulty adjust(List<GameResult> last5Games) {
    final wins = last5Games.where((g) => g.playerWon).length;
    final winRate = wins / last5Games.length;
    
    if (winRate < 0.2) return AIDifficulty.easy;      // 太难了，降级
    if (winRate > 0.9) return AIDifficulty.hard;      // 太简单，升级
    return currentDifficulty;
  }
}
```

---

## 七、经济系统设计

### 7.1 收支模型

| 收入项 | 金额 | 条件 |
|--------|------|------|
| 初始赠送 | +300 | 新用户 |
| 赢局（第1名） | +100 | 完成一局 |
| 赢局（第2名） | +80 | 完成一局 |
| 首胜奖励 | +50 | 每日首次获胜（不计入上限） |
| 每日签到 | +50~+300 | 连续7天递增 |
| 看广告 | +50 | 激励视频 |
| 幸运转盘 | +20~+200 | 随机 |
| 成就奖励 | +50~+500 | 解锁成就 |

| 支出项 | 金额 | 条件 |
|--------|------|------|
| 棋盘主题 | 200-2000 | 商店购买 |
| 棋子皮肤 | 200-1500 | 商店购买 |
| 骰子皮肤 | 100-1000 | 商店购买 |
| 转盘额外次数 | 100 | 每日免费1次后 |

### 7.2 防刷机制

```dart
enum EarnSource {
  gameWin,      // 对局胜利
  dailyCheckIn, // 每日签到
  adReward,     // 看广告
  wheelSpin,    // 幸运转盘
  achievement,  // 成就奖励
  firstWin,     // 每日首胜
}

class EconomyService {
  static const int dailyEarningLimit = 1000;

  /// 是否 Premium 用户（去广告订阅有效）
  bool get isPremium => _iapService.isPremiumActive;

  Future<EarnResult> earnCoins(int amount, EarnSource source) async {
    final today = DateTime.now().toDateString();
    final todayEarned = await getDailyEarnings(today);

    // 规则：
    // 1. Premium 用户不受每日上限限制（但仍记录统计）
    // 2. 广告收入计入上限（防止刷广告）
    // 3. 首胜奖励不计入上限（鼓励每日活跃）
    // 4. 内购获得的金币不走此方法

    if (!isPremium && todayEarned >= dailyEarningLimit) {
      if (source != EarnSource.firstWin) {
        return EarnResult(
          success: false,
          actualAmount: 0,
          reason: EarnFailReason.dailyLimitReached,
        );
      }
    }

    final remaining = dailyEarningLimit - todayEarned;
    final actualAmount = (isPremium || source == EarnSource.firstWin)
        ? amount
        : min(amount, remaining);

    await addCoins(actualAmount);
    if (source != EarnSource.firstWin) {
      await recordDailyEarning(today, actualAmount);
    }

    return EarnResult(success: true, actualAmount: actualAmount);
  }
}

class EarnResult {
  final bool success;
  final int actualAmount;
  final EarnFailReason? reason;
  EarnResult({required this.success, required this.actualAmount, this.reason});
}
```

---

## 八、广告系统设计

### 8.1 广告单元配置

```dart
class AdsConfig {
  // 测试ID
  static const String testAppId = 'ca-app-pub-3940256099942544~3347511713';
  static const String testBannerId = 'ca-app-pub-3940256099942544/6300978111';
  static const String testInterstitialId = 'ca-app-pub-3940256099942544/1033173712';
  static const String testRewardedId = 'ca-app-pub-3940256099942544/5224354917';
  
  // 生产ID（上线前替换）
  static String get appId => isProduction 
      ? 'ca-app-pub-7765853410525635~3816955106' 
      : testAppId;
}
```

### 8.2 展示策略

| 广告类型 | 触发时机 | 频率限制 | 目标eCPM |
|----------|---------|---------|---------|
| 激励视频 | 用户点击"赚金币" | 无限制（用户主动） | $2-6 |
| 插屏广告 | 每3局结束后 | 最少间隔60秒 | $0.5-2 |
| Banner | 商店/菜单页面 | 常驻 | $0.1-0.5 |

### 8.3 Premium 去广告

```dart
class IAPConfig {
  static const String premiumMonthly = 'afro_ludo_premium_monthly';
  static const String premiumYearly = 'afro_ludo_premium_yearly';
  static const String coinPackSmall = 'afro_coins_1000';
  static const String coinPackLarge = 'afro_coins_6000';
  static const String starterPack = 'afro_ludo_starter_pack';
}
```

---

## 九、多语言方案

### 9.1 语言策略

| 版本 | 语言 | 说明 |
|------|------|------|
| V1.0 | 英语 | 唯一语言，非洲通用语 |
| V1.1+ | 评估本地语言 | 根据用户数据决定是否添加豪萨语、约鲁巴语、斯瓦希里语 |

### 9.2 ARB 文件结构

```json
// app_en.arb
{
  "@@locale": "en",
  "appTitle": "Afro Ludo",
  "play": "Play",
  "settings": "Settings",
  "shop": "Shop",
  "coins": "{count} Coins",
  "win": "You Win!",
  "rollDice": "Roll Dice",
  "@coins": {
    "placeholders": {
      "count": {}
    }
  }
}
```

### 9.3 语言切换（预留接口）

```dart
class LanguageService {
  static const List<Locale> supportedLocales = [
    Locale('en'),
  ];

  static Future<void> setLanguage(String code) async {
    await Hive.box('settings').put('language', code);
  }
}
```

---

## 十、UI/UX 设计

### 10.1 页面流程

```
[Splash] → [Age Verify] → [Onboarding] → [Menu]
                                        ↓
                    ┌───────────────────┼───────────────────┐
                    ↓                   ↓                   ↓
                 [Ludo]             [Whot]            [Shop]
                    ↓                   ↓
              [Game Over]         [Game Over]
                    ↓                   ↓
              [Leaderboard]       [Leaderboard]
```

### 10.2 关键界面

**Menu Screen:**
- 顶部：玩家头像 + AfroCoins 显示
- 中部：Play Ludo / Play Whot 大按钮
- 底部：Shop | Leaderboard | Settings 图标

**Ludo Game Screen:**
- 上部：4 个玩家状态条（头像 + 已到家棋子数）
- 中部：棋盘（CustomPainter 绘制）
- 下部：骰子区域 + 当前玩家提示

**Shop Screen:**
- 分类标签：Boards | Pieces | Dice
- 网格展示，已拥有显示"Owned"
- 底部 Banner 广告（Premium 用户隐藏）

---

## 十一、测试策略

### 11.1 测试分层

| 层级 | 工具 | 覆盖 |
|------|------|------|
| 单元测试 | flutter_test | game/ 目录纯逻辑（移动规则、AI、经济计算） |
| Widget 测试 | flutter_test + mocktail | UI 组件交互 |
| 集成测试 | integration_test | 完整游戏流程 |
| 真机测试 | adb + Firebase Test Lab | 多设备兼容性 |

### 11.2 核心测试用例

```dart
// 移动规则测试
group('MoveRules', () {
  test('dice 6 can exit base', () {
    final piece = Piece(id: 0, playerId: 0, status: PieceStatus.base);
    expect(MoveRules.canMove(piece, 6, state), true);
  });
  
  test('non-6 cannot exit base', () {
    final piece = Piece(id: 0, playerId: 0, status: PieceStatus.base);
    expect(MoveRules.canMove(piece, 5, state), false);
  });
  
  test('capture moves enemy back to base', () {
    // ...
  });
});

// 经济系统测试
group('Economy', () {
  test('daily limit prevents overflow', () {
    final economy = EconomyState(afroCoins: 0, dailyEarned: 950);
    final result = EconomyService.earnCoins(100, EarnSource.gameWin);
    expect(result.actualAmount, 50); // 只能再赚50
  });
});
```

---

## 十二、开发计划（10周）

| 周 | 模块 | 内容 | 测试 |
|----|------|------|------|
| W1 | 环境搭建 | 项目初始化、目录结构、主题、英文文案 | 编译通过 |
| W2 | 游戏核心 | Ludo 棋盘、棋子、移动规则、吃子、胜负 | 单元测试 |
| W3 | AI + 渲染 | AI 三难度、棋盘 CustomPainter、骰子动画 |  playable |
| W4 | UI 框架 | Menu、游戏画面、设置、音效 | Widget 测试 |
| W5 | 经济系统 | AfroCoins、签到、每日上限、防刷 | 单元测试 |
| W6 | 广告 + 内购 | AdMob 集成、IAP 接入 | 真机测试 |
| W7 | 商店 + 皮肤 | 商店 UI、皮肤系统、购买流程 | 集成测试 |
| W8 | 性能优化 | 包体压缩、低端机适配、内存优化 | 性能测试 |
| W9 | 周边功能 | 排行榜、成就、分享、新手引导 | 集成测试 |
| W10 | 优化上架 | 包体压缩、性能优化、Google Play 准备 | 全量测试 |

---

## 十三、风险评估

| 风险 | 概率 | 影响 | 应对 |
|------|------|------|------|
| 包体超 15MB | 中 | 高 | 资源分包、WebP 压缩、按需下载 |
| 低端机卡顿 | 中 | 高 | 性能检测自动降级、纹理压缩 |
| AdMob eCPM 低 | 中 | 中 | 多广告网络聚合备选 |
| IAP 审核被拒 | 低 | 高 | 严格遵循 Google Play Billing 规范 |
| 实时对战延迟 | 中 | 高 | Firebase 实时数据库 + 乐观锁 |

---

*文档结束 — 待审核*
