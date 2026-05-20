import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../services/storage_service.dart';

/// Ludo 棋盘绘制器
///
/// 绘制 15×15 标准 Ludo 棋盘：
/// - 四个 6×6 角为玩家基地（半透明底色）
/// - 十字形轨道区域（白色背景）
/// - 四条 home track（5 格，玩家颜色）
/// - 3×3 中心 home 区域
/// - 网格线
///
/// 棋盘共 15×15 = 225 格，其中：
/// - 外圈轨道：52 格
/// - Home track：4 × 5 = 20 格
/// - Home 中心：3 × 3 = 9 格
/// - 四个基地：4 × 6 × 6 = 144 格
class BoardPainter extends CustomPainter {
  final double cellSize;
  final BoardSkin skin;

  BoardPainter({required this.cellSize, required this.skin});

  double get boardSize => cellSize * 15;

  @override
  void paint(Canvas canvas, Size size) {
    _drawBackground(canvas);
    _drawTrackArea(canvas);
    _drawBaseAreas(canvas);
    _drawHomeTracks(canvas);
    _drawHomeCenter(canvas);
    _drawGridLines(canvas);
  }

  /// 画整体背景
  void _drawBackground(Canvas canvas) {
    final paint = Paint()..color = skin.boardBackground;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, boardSize, boardSize),
      paint,
    );
  }

  /// 画轨道区域（十字形条带）
  void _drawTrackArea(Canvas canvas) {
    final paint = Paint()..color = skin.trackArea;

    // 水平条带：行 6-8，全宽
    canvas.drawRect(
      Rect.fromLTWH(0, 6 * cellSize, boardSize, 3 * cellSize),
      paint,
    );

    // 垂直条带：列 6-8，全高（水平条带已覆盖中心，所以只画上下两部分）
    // 上部：行 0-5
    canvas.drawRect(
      Rect.fromLTWH(6 * cellSize, 0, 3 * cellSize, 6 * cellSize),
      paint,
    );
    // 下部：行 9-14
    canvas.drawRect(
      Rect.fromLTWH(6 * cellSize, 9 * cellSize, 3 * cellSize, 6 * cellSize),
      paint,
    );
  }

  /// 画四个基地（6×6 角）
  void _drawBaseAreas(Canvas canvas) {
    final bases = [
      (0, 0, AfroTheme.redPlayer),
      (0, 9, AfroTheme.greenPlayer),
      (9, 0, AfroTheme.yellowPlayer),
      (9, 9, AfroTheme.bluePlayer),
    ];

    for (final (row, col, color) in bases) {
      final paint = Paint()..color = color.withValues(alpha: 0.2);
      final rect = Rect.fromLTWH(
        col * cellSize,
        row * cellSize,
        6 * cellSize,
        6 * cellSize,
      );
      canvas.drawRect(rect, paint);

      // 画基地边框
      final borderPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawRect(rect, borderPaint);
    }
  }

  /// 画 home track（通向中心的 5 格路径）
  void _drawHomeTracks(Canvas canvas) {
    final tracks = [
      // (row, col, rowCount, colCount, color)
      (1, 7, 5, 1, AfroTheme.redPlayer),      // Red: 垂直向下，列 7，行 1-5
      (7, 9, 1, 5, AfroTheme.greenPlayer),    // Green: 水平向左，行 7，列 9-13
      (7, 1, 1, 5, AfroTheme.yellowPlayer),   // Yellow: 水平向右，行 7，列 1-5
      (9, 7, 5, 1, AfroTheme.bluePlayer),     // Blue: 垂直向上，列 7，行 9-13
    ];

    for (final (row, col, rows, cols, color) in tracks) {
      final paint = Paint()..color = color.withValues(alpha: 0.5);
      final rect = Rect.fromLTWH(
        col * cellSize,
        row * cellSize,
        cols * cellSize,
        rows * cellSize,
      );
      canvas.drawRect(rect, paint);
    }
  }

  /// 画 home 中心（3×3）
  void _drawHomeCenter(Canvas canvas) {
    final rect = Rect.fromLTWH(
      6 * cellSize,
      6 * cellSize,
      3 * cellSize,
      3 * cellSize,
    );
    final paint = Paint()..color = skin.homeArea;
    canvas.drawRect(rect, paint);

    // 画对角线（经典 Ludo 中心装饰）
    final linePaint = Paint()
      ..color = skin.boardGridLine
      ..strokeWidth = 1;

    // 从左上到右下
    canvas.drawLine(
      Offset(6 * cellSize, 6 * cellSize),
      Offset(9 * cellSize, 9 * cellSize),
      linePaint,
    );
    // 从右上到左下
    canvas.drawLine(
      Offset(9 * cellSize, 6 * cellSize),
      Offset(6 * cellSize, 9 * cellSize),
      linePaint,
    );
  }

  /// 画网格线
  void _drawGridLines(Canvas canvas) {
    final paint = Paint()
      ..color = skin.boardGridLine
      ..strokeWidth = 0.5;

    for (int i = 0; i <= 15; i++) {
      final offset = i * cellSize;
      // 横线
      canvas.drawLine(
        Offset(0, offset),
        Offset(boardSize, offset),
        paint,
      );
      // 竖线
      canvas.drawLine(
        Offset(offset, 0),
        Offset(offset, boardSize),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant BoardPainter oldDelegate) {
    return oldDelegate.cellSize != cellSize || oldDelegate.skin.id != skin.id;
  }
}

/// 棋盘皮肤选择工具
class BoardSkinSelector {
  static BoardSkin get current {
    final id = StorageService.getActiveSkin() ?? 'classic';
    return AfroTheme.skins[id] ?? AfroTheme.classicSkin;
  }
}

/// 棋盘 Widget 封装
class LudoBoard extends StatelessWidget {
  final double size;

  const LudoBoard({
    super.key,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final cellSize = size / 15;

    return CustomPaint(
      size: Size(size, size),
      painter: BoardPainter(
        cellSize: cellSize,
        skin: BoardSkinSelector.current,
      ),
    );
  }
}
