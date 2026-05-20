#!/bin/bash
# HERMES Flutter 测试脚本（WSL 优化版）

set -e

PROJECT_DIR="/mnt/d/GameSpace/afro_ludo"
FLUTTER="/mnt/c/Windows/System32/cmd.exe /c D:\\dev-env\\flutter\\flutter\\bin\\flutter.bat"
ADB="/mnt/d/Android/SDK/platform-tools/adb.exe"
SCREENSHOT_DIR="/mnt/d/GameSpace/afro_ludo/screenshots"
LOG_DIR="/mnt/d/GameSpace/afro_ludo/logs"

echo "=== HERMES Flutter 测试脚本 ==="
echo "项目: $PROJECT_DIR"
echo ""

# 1. 构建 APK（不执行 clean，避免 symlink 问题）
echo "[1/6] 构建 Release APK..."
cd "$PROJECT_DIR"
$FLUTTER build apk --release 2>&1 | tail -5
echo "✅ 构建完成"
echo ""

# 2. 安装 APK
echo "[2/6] 安装 APK..."
$ADB install -r "D:\GameSpace\afro_ludo\build\app\outputs\flutter-apk\app-release.apk" 2>&1
echo "✅ 安装完成"
echo ""

# 3. 启动应用
echo "[3/6] 启动应用..."
$ADB shell am start -n com.afroludo.afro_ludo_flutter/.MainActivity 2>&1
sleep 3
echo "✅ 应用已启动"
echo ""

# 4. 执行测试步骤并截图
echo "[4/6] 执行测试步骤..."
mkdir -p "$SCREENSHOT_DIR"

# 截图函数
screenshot() {
    local name=$1
    $ADB shell screencap -p "/sdcard/$name.png" 2>/dev/null
    $ADB pull "/sdcard/$name.png" "D:\GameSpace\afro_ludo\screenshots\$name.png" 2>&1 | grep -v "pulled" || true
}

# 步骤 1: 初始状态
screenshot "01_start"

# 步骤 2: 点击 Play Ludo
$ADB shell input tap 540 2160
sleep 1
screenshot "02_play"

# 步骤 3: 点击 Start Game
$ADB shell input tap 540 2160
sleep 1
screenshot "03_game"

# 步骤 4: 点击 Roll Dice
$ADB shell input tap 540 2160
sleep 2
screenshot "04_dice"

# 步骤 5: 点击棋子
$ADB shell input tap 200 2000
sleep 2
screenshot "05_piece"

# 步骤 6: 等待 AI
sleep 3
screenshot "06_ai"

echo "✅ 测试步骤完成"
echo ""

# 5. 抓取日志
echo "[5/6] 抓取日志..."
mkdir -p "$LOG_DIR"
$ADB logcat -d | grep -E "flutter|Ludo|Dice|AI|Game" > "$LOG_DIR/test_log.txt" 2>&1 || true
echo "✅ 日志已保存"
echo ""

# 6. 分析结果
echo "[6/6] 分析截图..."
python3 << 'PYTHON'
import os
from PIL import Image

screenshots_dir = "/mnt/d/GameSpace/afro_ludo/screenshots"
files = ["01_start", "02_play", "03_game", "04_dice", "05_piece", "06_ai"]

print("=== 截图分析结果 ===\n")

prev_pixels = None
for f in files:
    path = os.path.join(screenshots_dir, f"{f}.png")
    if os.path.exists(path):
        img = Image.open(path)
        pixels = list(img.getdata())
        total = len(pixels)
        
        # 计算关键指标
        yellow = sum(1 for p in pixels if p[0] > 200 and p[1] > 150 and p[2] < 100)
        red = sum(1 for p in pixels if p[0] > 200 and p[1] < 100 and p[2] < 100)
        dark = sum(1 for p in pixels if p[0] < 50 and p[1] < 50 and p[2] < 50)
        light = sum(1 for p in pixels if p[0] > 200 and p[1] > 200 and p[2] > 200)
        
        # 计算与上一张的差异
        diff_pct = 0
        if prev_pixels:
            diff = sum(1 for p1, p2 in zip(prev_pixels, pixels) if p1 != p2)
            diff_pct = diff / total * 100
        
        print(f"{f}:")
        print(f"  黄色: {yellow/total*100:.2f}% 红色: {red/total*100:.2f}%")
        print(f"  深色: {dark/total*100:.2f}% 浅色: {light/total*100:.2f}%")
        if diff_pct > 0:
            print(f"  变化: {diff_pct:.2f}%")
        print()
        
        prev_pixels = pixels
    else:
        print(f"{f}: ❌ 文件不存在\n")

print("=== 测试完成 ===")
PYTHON

echo ""
echo "截图保存: $SCREENSHOT_DIR"
echo "日志保存: $LOG_DIR/test_log.txt"
