# Afro Ludo UI 全面改版设计规格

> **目标**：将当前极简米黄白 UI 升级为符合非洲市场审美的视觉体验
> **原则**：不考虑开发成本，追求最佳效果
> **性能底线**：禁止 BackdropFilter/blur、复杂粒子系统、多层阴影

---

## 一、设计语言定义

### 1.1 品牌色板（Afro Vibrant）

```
主色（Primary）:        #FF6B35  活力橙 — 按钮、CTA、强调
主色深（Primary Dark）:  #E55A2B  深橙 — 按下态、渐变终点
辅助色1（Secondary）:    #1A9D3E  森林绿 — 成功、确认、正面反馈
辅助色2（Accent Gold）:  #FFD700  非洲金 — 奖励、金币、高亮
强调色（Highlight）:     #E63946  非洲红 — 警告、吃子、重要通知
背景色（Background）:    #1A1A2E  深蓝黑 — 主背景（暗色主题风格）
表面色（Surface）:       #16213E  深海蓝 — 卡片、面板、对话框
卡片色（Card）:          #0F3460  宝石蓝 — 次级容器
文字主色（Text Primary）:   #FFFFFF  纯白
文字次色（Text Secondary）: #B8B8D0  柔紫灰
边框色（Border）:         #FFD700 30%  金色半透明
```

### 1.2 玩家颜色（升级版，更高饱和度）

```
Red Player:    #FF4757  → 渐变 #FF4757 → #FF6B81
Green Player:  #2ED573  → 渐变 #2ED573 → #7BED9F  
Yellow Player: #FFA502  → 渐变 #FFA502 → #FFDA79
Blue Player:   #1E90FF  → 渐变 #1E90FF → #70A1FF
```

### 1.3 非洲文化元素

**Kente 条纹**（加纳传统织物图案）：
- 用途：棋盘边框装饰、弹窗标题栏、成就卡片边框
- 实现：CustomPainter 绘制交替色条（金/绿/橙/红），宽度 4-6px
- 颜色序列：`#FFD700 → #1A9D3E → #FF6B35 → #E63946 → #FFD700`

**Adinkra 符号**（西非传统符号）：
- 安全格（Star 格）：用 Adinkra "Fawohodie"（独立/自由符号）替代普通星星
- 起点格：用 "Nkyinkyim"（坚韧符号，曲折线条）标记
- 中心 Home：用 "Gye Nyame"（至高无上，最著名的 Adinkra 符号）
- 实现：SVG path 或 CustomPainter 绘制简单几何图案

**Ankara 撞色**（胜利/奖励场景）：
- 胜利画面背景：紫 #9B59B6 + 橙 #FF6B35 + 绿 #1A9D3E 大色块拼接
- 每日签到弹窗：Ankara 花纹边框
- 排行榜：Ankara 色条分隔

---

## 二、各屏幕详细设计

### 2.1 Splash 启动页

**当前问题**：纯白背景 + 简单 fade 动画，毫无品牌感

**改版设计**：
- **背景**：深蓝黑 `#1A1A2E` 全屏
- **中心 Logo**：
  - "AFRO" 大字（48px，fontWeight: w900，金色 `#FFD700`）
  - "LUDO" 大字（48px，fontWeight: w900，白色 `#FFFFFF`）
  - 两行垂直排列，字间距 8px
- **Logo 动画**：
  - 0-800ms：从 scale(0.5) + opacity(0) → scale(1.0) + opacity(1.0)，弹性曲线 Curves.elasticOut
  - 800-1200ms：Logo 下方出现金色光晕（RadialGradient，中心金色向外淡出）
- **底部装饰**：
  - Kente 条纹横带（4px 高，水平滚动动画，从左到右无限循环）
  - 位置：屏幕底部 SafeArea 上方
- **背景粒子**（轻量）：
  - 8-10 个金色小圆点，从底部缓慢上浮，随机大小 2-4px
  - 用 AnimationController + Positioned 实现，不用粒子引擎
- **持续时间**：2.5 秒

### 2.2 年龄验证页

**当前问题**：纯白对话框，无设计感

**改版设计**：
- **背景**：继承 Splash 的深蓝黑 + 半透明金色粒子（复用）
- **卡片**：
  - 圆角 24px，背景 `#16213E`，边框金色 1px
  - 顶部 Kente 条纹装饰带（8px 高，水平方向）
  - 阴影：不用 BoxShadow，用 Container 底层放一个略大的深色 Container 模拟
- **文字**：
  - "Age Verification" 标题：24px，白色 w700
  - 副标题："To comply with child safety laws..."：14px，柔紫灰 #B8B8D0
  - "Are you 13 years of age or older?"：16px，白色 w600
- **按钮**：
  - "Yes, I am 13 or older"：
    - 渐变背景 `LinearGradient(#FF6B35 → #E55A2B)`
    - 白色文字 16px w600
    - 圆角 16px
    - 点击时 scale(0.97) 动画（150ms）
  - "No, I am under 13"：
    - 透明背景，金色 `#FFD700` 边框 1.5px
    - 金色文字 16px w500
    - 同样点击缩放动画

### 2.3 主菜单

**当前问题**：米黄背景 + 棕色标题 + 扁平橙色小按钮，无视觉层次

**改版设计**：
- **背景**：
  - 深蓝黑 `#1A1A2E` 底色
  - 顶部 1/3 区域加径向渐变光晕：`RadialGradient(center: Alignment.topCenter, radius: 0.8, colors: [#FF6B35 15%, #1A1A2E 100%])`，营造暖光氛围
  - 底部 10% 区域加 Kente 条纹装饰带（水平滚动）
- **Logo 区域**（屏幕上方 25%）：
  - "AFRO" 金色 #FFD700 + "LUDO" 白色，字号 36px，w900
  - 副标题 "Classic Board Games"：柔紫灰 #B8B8D0，14px
  - Logo 下方有微弱的金色光晕
- **菜单按钮**（屏幕中间 60%）：
  - 改为全宽（margin horizontal 24）的 **大卡片按钮**
  - 每个按钮高度 64px
  - 背景色方案（每个按钮不同主题色）：

  ```
  Play Ludo:    渐变 #FF6B35 → #E55A2B（活力橙）+ 游戏手柄图标
  Play Whot:    渐变 #1A9D3E → #148F3B（森林绿）+ 卡牌图标
  Lucky Wheel:  渐变 #9B59B6 → #8E44AD（皇室紫）+ 星星图标
  Settings:     纯色 #16213E + 金色边框（齿轮图标，金色）
  Shop:         渐变 #FFD700 → #F4C430（非洲金）+ 深色文字 + 购物车图标
  Stats:        纯色 #16213E + 金色边框（柱状图图标，金色）
  Achievements: 渐变 #E63946 → #C0392B（非洲红）+ 奖杯图标
  Share:        纯色 #16213E + 金色边框（分享图标，金色）
  ```

  - 按钮样式统一：
    - 圆角 16px
    - 左侧图标（白色或金色，28px）
    - 右侧文字（白色 18px w600）
    - 右侧箭头 `Icons.chevron_right`（白色半透明）
    - 按钮间距 12px
    - 点击动画：scale 0.97（150ms）+ 颜色变亮 10%
  - **按钮入场动画**：
    - 从下方依次滑入（每个延迟 60ms）
    - AnimatedSlide + AnimatedOpacity，duration 400ms，Curves.easeOutCubic

- **金币显示**（右上角悬浮）：
  - 圆角胶囊形背景 `#16213E`
  - 金色金币图标 + 金色数字
  - 边框金色半透明

### 2.4 游戏 Setup 界面

**改版设计**：
- **背景**：深蓝黑 `#1A1A2E`
- **标题 "Game Setup"**：白色 24px w700
- **玩家数量选择**：
  - 改为大圆角正方形卡片（而非 RadioButton）
  - 选中态：对应玩家颜色的渐变背景 + 白色文字 + 金色边框
  - 未选中态：`#16213E` 背景 + 柔紫灰文字
  - 过渡动画：AnimatedContainer 300ms
- **玩家颜色预览**：
  - 每个颜色改为圆形头像风格
  - 底部标注 "You" 或 "AI" 标签
  - 人类玩家有金色光环
- **AI 难度**：
  - 三个大按钮横排
  - Easy：绿色渐变
  - Medium：橙色渐变
  - Hard：红色渐变
- **Start Game 按钮**：
  - 全宽大按钮
  - 渐变 `#FF6B35 → #E55A2B`
  - 文字 "START GAME" 白色 20px w700
  - 持续脉冲动画（scale 1.0 → 1.02 循环），吸引用户点击

### 2.5 游戏棋盘

**改版设计**：

**棋盘背景**：
- 整体背景：深棕木纹色 `#3E2723`（经典模式）
- 棋盘四边加 Kente 条纹装饰带（8px）
- 玩家基地：对应玩家颜色的 30% 透明度 + 玩家图标
- 轨道格子：`#F4E8C1`（沙漠米白）
- 安全格：Adinkra Fawohodie 符号（金色 #FFD700），替代普通星星
- Home Track：玩家颜色渐变路径
- 中心 Home：Gye Nyame 符号（金色大图标）+ 发光效果

**棋子设计**：
- 圆形棋子（直径 cellSize * 0.7）
- 玩家颜色填充
- 金色描边 2px
- 内部数字（白色 w700）
- 选中态：脉冲发光动画（ScaleTransition 1.0 → 1.1 循环）+ 金色外圈光环
- 可移动态：底部出现金色小箭头指示

**骰子区域**（底部）：
- "Roll Dice" 按钮：
  - 大圆形按钮（直径 72px）
  - 渐变背景 `#FFD700 → #F4C430`
  - 黑色骰子图标（⚫ 或 ⚄）
  - 按下时 3D 翻转旋转动画（RotateTransition，绕 Y 轴旋转 720°，800ms）
- 骰子结果展示：
  - 大号数字（36px w900，金色）
  - 出现时弹跳动画（Curves.bounceOut）
- 棋子选择按钮：
  - "Piece 1/2/3/4" 改为圆形按钮
  - 玩家颜色背景 + 白色数字
  - 可点击时有呼吸动画

**HUD 信息区**（顶部）：
- 四个玩家状态横排
- 当前玩家高亮（底部金色下划线 + 微弱发光）
- 每个玩家显示：颜色圆点 + "0/4" 完成数
- 被吃棋子半透明显示

**回合指示**：
- 当前玩家名字 + "Your Turn!" 或 "AI Thinking..."
- AI 思考时显示三点跳动动画（...

**操作栏**：
- Back 按钮：改为圆形，`#16213E` 背景 + 白色箭头

### 2.6 设置界面

**改版设计**：
- **背景**：深蓝黑 `#1A1A2E`
- **设置项卡片**：
  - 每项为独立圆角卡片（16px），背景 `#16213E`
  - 左侧标题 + 描述（白色 + 柔紫灰）
  - 右侧控件区域
  - 间距 12px
- **开关（Sound/Haptic）**：
  - 自定义 Toggle 颜色：开启 `#1A9D3E`，关闭 `#333355`
  - 切换动画 200ms
- **AI 难度选择器**：
  - 三个并排圆角按钮
  - Easy 绿 / Medium 橙 / Hard 红
  - 选中态：亮色 + 白色文字；未选中：暗色 + 灰色文字
- **语言选择器**：
  - 下拉样式，金色边框
- **Board Theme**：
  - 横向滑动选择器，显示主题预览缩略图
  - Classic / Neon / Afro 三个主题缩略图

### 2.7 商店界面

**改版设计**：
- **背景**：深蓝黑 `#1A1A2E`
- **金币显示**（顶部）：
  - 大号金色数字 + 金币图标
  - 金色光晕背景
- **Watch Ad 按钮**：
  - 渐变绿色背景 `#1A9D3E → #148F3B`
  - 播放图标 + "Watch Ad for Free Coins"
- **金币包卡片**：
  - 每个包为独立卡片，背景 `#16213E`，金色边框
  - 左侧：金币图标堆叠（数量越多堆越高）
  - 中间："+500 AfroCoins"
  - 右侧：价格按钮（金色渐变）
  - 卡片间距 12px
- **皮肤展示**：
  - 横向滑动卡片
  - 每张卡片：皮肤预览 + 名称 + 价格
  - 已购买：金色勾标记 + "Equipped" 按钮
  - 金币不足：按钮变灰 + 点击弹出友好提示 "You need X more AfroCoins"
  - **金币不足提示**（修复 BUG）：
    - 弹出 SnackBar 或 Dialog
    - 图标：金币 + 红色叉
    - 文字："Not enough AfroCoins! You need {X} more."
    - 底部两个按钮："Watch Ad" / "Buy Coins"

### 2.8 Lucky Wheel 转盘

**改版设计**：
- **背景**：深蓝黑 + 中心紫色光晕 `RadialGradient(#9B59B6 20%, #1A1A2E 80%)`
- **转盘**：
  - 8 个扇区，交替使用 Afro 色板（橙/绿/金/红/紫/蓝）
  - 每个扇区内：奖品图标 + 数量
  - 中心：金色圆盘 + "SPIN" 文字
  - 外圈：金色装饰环 + 灯泡点阵（小圆点交替亮灭动画）
  - 指针：顶部金色三角形
- **Spin 按钮**：
  - "Free Spin"：绿色渐变大按钮
  - "Watch Ad"：紫色渐变按钮
- **旋转动画**：
  - 用 AnimationController 驱动旋转角度
  - 减速曲线：Curves.decelerate（先快后慢）
  - 持续时间 4 秒
  - 停止时弹跳效果（最后 30° 范围内轻微回弹）

### 2.9 每日签到弹窗

**改版设计**：
- **背景遮罩**：黑色 60% 透明
- **弹窗卡片**：
  - 圆角 24px，背景 `#16213E`
  - 顶部 Kente 条纹装饰（8px）
  - 标题："Daily Check-In" 金色 24px w700
  - 中心：奖励展示
    - 金币图标（大号 48px）+ "+50" 金色数字 32px w900
    - 光芒放射动画（RadialGradient 从中心向外扩散）
  - 底部 "Claim" 按钮：
    - 渐变绿色 `#1A9D3E → #148F3B`
    - 白色文字 18px w700
    - 全宽（margin 24px）
  - 连续签到进度条（如适用）：
    - 7 格横排，当前天数高亮
    - 每格显示天数 + 奖励数量

### 2.10 胜利画面

**改版设计**：
- **背景**：
  - Ankara 撞色大色块（紫/橙/绿/金 四个象限）
  - 半透明深色遮罩确保文字可读
- **中心内容**：
  - "🎉 VICTORY!" 大标题（36px w900，金色）
  - 入场动画：scale(0) → scale(1.2) → scale(1.0) 弹性效果
  - 获胜者颜色大圆点 + 名称
  - 金币奖励："+50 AfroCoins" 金色闪烁
- **金色纸屑动画**：
  - 30-50 个金色小方块从顶部下落
  - 随机旋转 + 左右飘移
  - 用多个 AnimatedBuilder + Positioned 实现
  - 不用粒子引擎
- **按钮**：
  - "Play Again"：渐变橙 `#FF6B35 → #E55A2B`
  - "Main Menu"：金色边框按钮

### 2.11 Stats 统计页

**改版设计**：
- 深蓝黑背景
- 顶部三格大数字面板（Games Played / Win Rate / Streak）
- 每格为独立卡片，背景 `#16213E`，金色上边框 3px
- 下方成就列表：每项为横向卡片，图标 + 标题 + 描述 + 进度条

### 2.12 Achievements 成就页

**改版设计**：
- 深蓝黑背景
- 每个成就为卡片，未解锁时灰暗（灰度滤镜 + 锁图标）
- 解锁时：对应颜色渐变 + 金色勾
- 进度条：金色填充 + 深色底

---

## 三、通用组件规范

### 3.1 AfroButton 组件（替代 _MenuButton）

```dart
// 所有主要按钮统一使用此组件
class AfroButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final Gradient? gradient;     // 可选渐变
  final Color? borderColor;     // 可选边框色
  final bool isFullWidth;       // 默认 true
  
  // 样式：
  // - 高度 56-64px
  // - 圆角 16px
  // - 渐变背景 或 纯色+边框
  // - 左图标(28px) + 中文字(18px w600 白色) + 右箭头
  // - 点击：AnimatedScale(0.97, 150ms)
  // - 长按：ripple 效果（金色）
}
```

### 3.2 AfroCard 组件

```dart
// 所有卡片统一使用
class AfroCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final Color? borderColor;
  
  // 样式：
  // - 圆角 16px
  // - 背景 #16213E
  // - 边框：可选金色半透明 1px
  // - padding: 16px
}
```

### 3.3 KenteStrip 装饰组件

```dart
// Kente 条纹装饰带
class KenteStrip extends StatelessWidget {
  final double height;       // 默认 4px（棋盘边框）或 8px（标题装饰）
  final bool animate;        // 是否水平滚动
  
  // 用 CustomPainter 或 Row of Containers 绘制
  // 颜色序列：金 → 绿 → 橙 → 红 → 金（循环）
  // 每段宽度 20-30px
  // animate=true 时用 AnimatedPositioned 实现水平滚动
}
```

### 3.4 AdinkraSymbol Painter

```dart
// Adinkra 符号绘制器
class AdinkraPainter extends CustomPainter {
  final String symbol;  // 'fawohodie' | 'nkyinkyim' | 'gye_nyame'
  final Color color;
  final double size;
  
  // 用 Path 绘制简化版几何图案
  // Fawohodie：十字 + 四个 L 形（简洁版）
  // Gye Nyame：螺旋圆环（简化版）
  // Nkyinkyim：锯齿波浪线
}
```

### 3.5 GoldCoinDisplay 组件

```dart
// 金币显示（用于右上角、商店、签到等）
class GoldCoinDisplay extends StatelessWidget {
  final int amount;
  final double fontSize;
  
  // 金色圆形底 + 金色数字
  // 可选：数字变化时的计数动画（TweenAnimationBuilder）
}
```

---

## 四、动画规范

| 动画场景 | 类型 | 持续时间 | 曲线 | 说明 |
|---------|------|---------|------|------|
| 按钮点击 | Scale | 150ms | easeInOut | scale 1.0 → 0.97 → 1.0 |
| 页面跳转 | Slide + Fade | 300ms | easeOutCubic | 从右滑入 |
| 列表项入场 | Slide + Fade | 400ms | easeOutCubic | 每项延迟 60ms |
| 骰子旋转 | Rotation3D | 800ms | easeOut | 绕 Y 轴 720° |
| 棋子移动 | Slide + Bounce | 400ms | bounceOut | 格间跳动 |
| 棋子选中 | Scale pulse | 800ms | easeInOut | 1.0 → 1.1 循环 |
| 吃子效果 | Scale + Shake | 500ms | easeOut | 被吃棋子抖动后缩小消失 |
| 到家效果 | Scale + Glow | 600ms | easeOut | 放大后金色光环 |
| 胜利标题 | Scale elastic | 800ms | elasticOut | 0 → 1.2 → 1.0 |
| 金币飘落 | Translate + Rotate | 2000ms | easeIn | 从奖励源飘向金币显示 |
| 转盘旋转 | Rotation | 4000ms | decelerate | 减速停止 |
| Kente 滚动 | Translate | 10000ms | linear | 无限循环 |

---

## 五、主题系统扩展

### 5.1 BoardSkin 扩展

```dart
class BoardSkin {
  final String id;
  final String name;
  
  // 棋盘
  final Color boardBackground;
  final Color boardGridLine;
  final Color homeArea;
  final Color trackArea;
  
  // 新增字段
  final Color safeCellColor;        // 安全格颜色
  final Color kenteBorderColor;     // Kente 边框主色
  final String adinkraSymbol;       // 安全格符号类型
  final Color centerSymbolColor;    // 中心符号颜色
  final List<Color> kenteSequence;  // Kente 颜色序列
}
```

### 5.2 三套主题最终设计

**Classic Wood（经典木质）**：
- 棋盘：深棕 `#3E2723` + 木纹 CustomPainter 纹理
- 轨道：米白 `#F4E8C1`
- Kente：金/绿/橙序列
- 基地：玩家颜色 25% 透明度

**Ankara Vibrant（Ankara 活力）**：
- 棋盘：深蓝 `#0F3460`
- 轨道：浅金 `#FFF8E1`
- Kente：紫/橙/绿/粉序列（Ankara 特色撞色）
- 基地：玩家颜色 40% 透明度 + 花纹装饰
- 安全格用 Ankara 印花图案

**Afropunk Neon（Afropunk 霓虹）**：
- 棋盘：纯黑 `#0D0D0D`
- 轨道：深灰 `#1A1A2E`
- 轨道线：霓虹发光效果（绿 `#00FF88` 的 20% 透明度外层模拟发光）
- Kente：霓虹青/粉/紫序列
- 棋子：霓虹描边 + 内部暗色
- 骰子：霓虹绿发光

---

## 六、字体规范

```yaml
# 推荐使用 Google Fonts
标题字体: Poppins (w700/w900) — 圆润现代，非洲市场流行
正文字体: Poppins (w400/w500)  
数字字体: Poppins (w700) — 用于金币、分数、骰子数
```

在 `pubspec.yaml` 中添加：
```yaml
dependencies:
  google_fonts: ^6.1.0
```

---

## 七、需要修改的文件清单

| 文件 | 修改内容 |
|------|---------|
| `lib/core/theme.dart` | 全部重写：新色板、BoardSkin 扩展、TextTheme、组件主题 |
| `lib/ui/screens/menu_screen.dart` | 全部重写：新布局、AfroButton、入场动画 |
| `lib/ui/screens/splash_screen.dart` | 重写：深色背景、Logo 动画、Kente 装饰 |
| `lib/ui/screens/age_verification_screen.dart` | 重写：深色卡片、渐变按钮 |
| `lib/ui/screens/ludo_setup_screen.dart` | 重写：卡片式选择器、脉冲按钮 |
| `lib/ui/screens/ludo_game_screen.dart` | 大改：HUD、骰子区、操作栏 |
| `lib/ui/screens/game_over_screen.dart` | 重写：Ankara 背景、纸屑动画 |
| `lib/ui/screens/settings_screen.dart` | 重写：深色卡片、自定义 Toggle |
| `lib/ui/screens/shop_screen.dart` | 重写：深色卡片、皮肤预览、修复金币不足提示 |
| `lib/ui/screens/wheel_screen.dart` | 重写：转盘绘制、旋转动画、灯泡动画 |
| `lib/ui/screens/achievements_screen.dart` | 重写：深色卡片、进度条 |
| `lib/ui/screens/stats_screen.dart` 或 `leaderboard_screen.dart` | 重写：深色面板 |
| `lib/ui/widgets/board_painter.dart` | 大改：Kente 边框、Adinkra 符号、基地图标 |
| `lib/ui/widgets/dice_widget.dart` | 重写：3D 旋转动画 |
| `lib/ui/widgets/pieces_layer.dart` | 大改：棋子样式、选中发光、移动弹跳 |
| `lib/ui/widgets/daily_check_in_dialog.dart` | 重写：Kente 装饰、光芒动画 |
| `lib/ui/widgets/coin_display.dart` | 重写：金色主题 |
| `lib/ui/widgets/player_avatar.dart` | 重写：金色光环 |
| `lib/main.dart` | 更新 ThemeData 引用 |

### 新增文件

| 文件 | 内容 |
|------|------|
| `lib/ui/widgets/afro_button.dart` | AfroButton 通用按钮组件 |
| `lib/ui/widgets/afro_card.dart` | AfroCard 通用卡片组件 |
| `lib/ui/widgets/kente_strip.dart` | Kente 条纹装饰组件 |
| `lib/ui/widgets/adinkra_painter.dart` | Adinkra 符号绘制器 |
| `lib/ui/widgets/gold_coin_display.dart` | 金币显示组件 |
| `lib/ui/widgets/confetti_animation.dart` | 胜利纸屑动画 |
| `lib/ui/widgets/pulse_animation.dart` | 脉冲发光动画 |

---

## 八、实施顺序建议

Claude Code 按此顺序实施，每步完成后可独立验证：

1. **theme.dart 重写** — 新色板、BoardSkin 扩展、全局 ThemeData
2. **通用组件** — AfroButton、AfroCard、KenteStrip、GoldCoinDisplay
3. **Splash + 年龄验证** — 第一个用户可见的变化
4. **主菜单** — 最直观的视觉提升
5. **游戏 Setup** — 卡片式选择器
6. **棋盘 BoardPainter** — Kente 边框 + Adinkra 符号
7. **棋子 + 骰子** — 新样式 + 动画
8. **游戏 HUD** — 玩家状态、回合指示
9. **胜利画面** — Ankara 背景 + 纸屑
10. **设置/商店/Stats/Achievements** — 统一深色风格
11. **每日签到** — Kente 装饰 + 光芒动画
12. **Lucky Wheel** — 转盘重绘 + 旋转动画
13. **最终打磨** — 入场动画、过渡动画、微交互

---

## 九、性能保护规则

1. ✅ 允许：LinearGradient、RadialGradient（静态背景）
2. ✅ 允许：CustomPainter（配合 RepaintBoundary）
3. ✅ 允许：Implicit Animations（AnimatedContainer、AnimatedScale 等）
4. ✅ 允许：SVG（flutter_svg 缓存渲染）
5. ✅ 允许：TweenAnimationBuilder（数字动画）
6. ⚠️ 限制：Explicit AnimationController（每屏幕不超过 3 个同时运行）
7. ❌ 禁止：BackdropFilter、ImageFilter.blur
8. ❌ 禁止：多层 BoxShadow（用单层或纯色描边替代）
9. ❌ 禁止：粒子引擎（自定义轻量实现除外，上限 50 粒子）
10. ❌ 禁止：每帧重建 Widget（所有动画用 const + AnimatedBuilder）

---

## 十、验收标准

完成后，以下每个场景截图应满足：

- [ ] Splash：深色背景 + 金色 Logo + Kente 底部装饰 → 3秒内给人"这不是小作坊"的感觉
- [ ] 主菜单：暗色 + 多色渐变大按钮 → 一眼看去有 3+ 种颜色层次
- [ ] 游戏棋盘：Kente 边框 + Adinkra 符号 → 有非洲文化辨识度
- [ ] 胜利画面：Ankara 撞色 + 金色纸屑 → 值得截图分享
- [ ] 商店金币不足：弹出友好提示（修复现有 BUG）
- [ ] 全局：零白屏/米黄屏，所有页面深色主题统一
