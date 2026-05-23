import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../services/storage_service.dart';
import 'adinkra_painter.dart';

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
    _drawSafeCells(canvas);
    _drawGridLines(canvas);
    _drawKenteBorder(canvas);
  }

  void _drawBackground(Canvas canvas) {
    final paint = Paint()..color = skin.boardBackground;
    canvas.drawRect(Rect.fromLTWH(0, 0, boardSize, boardSize), paint);
  }

  void _drawTrackArea(Canvas canvas) {
    final paint = Paint()..color = skin.trackArea;

    canvas.drawRect(
      Rect.fromLTWH(0, 6 * cellSize, boardSize, 3 * cellSize),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(6 * cellSize, 0, 3 * cellSize, 6 * cellSize),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(6 * cellSize, 9 * cellSize, 3 * cellSize, 6 * cellSize),
      paint,
    );
  }

  void _drawBaseAreas(Canvas canvas) {
    final bases = [
      (0, 0, AfroTheme.redPlayer),
      (0, 9, AfroTheme.greenPlayer),
      (9, 0, AfroTheme.yellowPlayer),
      (9, 9, AfroTheme.bluePlayer),
    ];

    for (final (row, col, color) in bases) {
      final paint = Paint()..color = color.withValues(alpha: 0.25);
      final rect = Rect.fromLTWH(
        col * cellSize,
        row * cellSize,
        6 * cellSize,
        6 * cellSize,
      );
      canvas.drawRect(rect, paint);

      final borderPaint = Paint()
        ..color = color.withValues(alpha: 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawRect(rect, borderPaint);

      // 基地内装饰：对角十字线
      final decoPaint = Paint()
        ..color = color.withValues(alpha: 0.15)
        ..strokeWidth = 1;
      canvas.drawLine(
        Offset(col * cellSize, row * cellSize),
        Offset((col + 6) * cellSize, (row + 6) * cellSize),
        decoPaint,
      );
      canvas.drawLine(
        Offset((col + 6) * cellSize, row * cellSize),
        Offset(col * cellSize, (row + 6) * cellSize),
        decoPaint,
      );
    }
  }

  void _drawHomeTracks(Canvas canvas) {
    final tracks = [
      (1, 7, 5, 1, AfroTheme.redPlayer),
      (7, 9, 1, 5, AfroTheme.greenPlayer),
      (7, 1, 1, 5, AfroTheme.yellowPlayer),
      (9, 7, 5, 1, AfroTheme.bluePlayer),
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

  void _drawHomeCenter(Canvas canvas) {
    final rect = Rect.fromLTWH(
      6 * cellSize,
      6 * cellSize,
      3 * cellSize,
      3 * cellSize,
    );
    final paint = Paint()..color = skin.homeArea.withValues(alpha: 0.3);
    canvas.drawRect(rect, paint);

    // Gye Nyame 符号
    final symbolSize = cellSize * 2.4;
    canvas.save();
    canvas.translate(
      7.5 * cellSize - symbolSize / 2,
      7.5 * cellSize - symbolSize / 2,
    );
    final symbolPainter = AdinkraPainter(
      symbol: 'gye_nyame',
      color: skin.centerSymbolColor,
      strokeWidth: 2.5,
    );
    symbolPainter.paint(canvas, Size(symbolSize, symbolSize));
    canvas.restore();
  }

  void _drawSafeCells(Canvas canvas) {
    // Ludo 安全格位置（经典位置）
    final safeCells = [
      (2, 2),
      (2, 12),
      (8, 1),
      (8, 13),
      (12, 2),
      (12, 12),
      (6, 8),
      (8, 8),
      (8, 6),
    ];

    final symbolSize = cellSize * 0.6;
    for (final (row, col) in safeCells) {
      canvas.save();
      canvas.translate(
        (col + 0.5) * cellSize - symbolSize / 2,
        (row + 0.5) * cellSize - symbolSize / 2,
      );
      final symbolPainter = AdinkraPainter(
        symbol: skin.adinkraSymbol,
        color: skin.safeCellColor,
        strokeWidth: 2,
      );
      symbolPainter.paint(canvas, Size(symbolSize, symbolSize));
      canvas.restore();
    }
  }

  void _drawGridLines(Canvas canvas) {
    final paint = Paint()
      ..color = skin.boardGridLine.withValues(alpha: 0.4)
      ..strokeWidth = 0.5;

    for (int i = 0; i <= 15; i++) {
      final offset = i * cellSize;
      canvas.drawLine(Offset(0, offset), Offset(boardSize, offset), paint);
      canvas.drawLine(Offset(offset, 0), Offset(offset, boardSize), paint);
    }
  }

  void _drawKenteBorder(Canvas canvas) {
    const borderWidth = 6.0;
    final colors = skin.kenteSequence;
    final segWidth = cellSize * 1.5;
    final kentePaint = Paint()..style = PaintingStyle.fill;

    // 上边框
    for (double x = -borderWidth; x < boardSize + borderWidth; x += segWidth) {
      for (int ci = 0; ci < colors.length && x + ci * segWidth / colors.length < boardSize + borderWidth; ci++) {
        kentePaint.color = colors[ci];
        canvas.drawRect(
          Rect.fromLTWH(x + ci * segWidth / colors.length, -borderWidth,
              segWidth / colors.length, borderWidth),
          kentePaint,
        );
      }
    }

    // 下边框
    for (double x = -borderWidth; x < boardSize + borderWidth; x += segWidth) {
      for (int ci = 0; ci < colors.length && x + ci * segWidth / colors.length < boardSize + borderWidth; ci++) {
        kentePaint.color = colors[ci];
        canvas.drawRect(
          Rect.fromLTWH(x + ci * segWidth / colors.length, boardSize,
              segWidth / colors.length, borderWidth),
          kentePaint,
        );
      }
    }

    // 左边框
    for (double y = -borderWidth; y < boardSize + borderWidth; y += segWidth) {
      for (int ci = 0; ci < colors.length && y + ci * segWidth / colors.length < boardSize + borderWidth; ci++) {
        kentePaint.color = colors[ci];
        canvas.drawRect(
          Rect.fromLTWH(-borderWidth, y + ci * segWidth / colors.length,
              borderWidth, segWidth / colors.length),
          kentePaint,
        );
      }
    }

    // 右边框
    for (double y = -borderWidth; y < boardSize + borderWidth; y += segWidth) {
      for (int ci = 0; ci < colors.length && y + ci * segWidth / colors.length < boardSize + borderWidth; ci++) {
        kentePaint.color = colors[ci];
        canvas.drawRect(
          Rect.fromLTWH(boardSize, y + ci * segWidth / colors.length,
              borderWidth, segWidth / colors.length),
          kentePaint,
        );
      }
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

  const LudoBoard({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    final cellSize = size / 15;
    final kenteBorder = 6.0;
    final totalSize = size + kenteBorder * 2;

    return SizedBox(
      width: totalSize,
      height: totalSize,
      child: Stack(
        children: [
          // Kente 边框层（已包含在 BoardPainter 内）
          Positioned(
            left: kenteBorder,
            top: kenteBorder,
            child: RepaintBoundary(
              child: CustomPaint(
                size: Size(size, size),
                painter: BoardPainter(
                  cellSize: cellSize,
                  skin: BoardSkinSelector.current,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
