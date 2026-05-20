import 'package:flutter/material.dart';

/// 棋盘皮肤配置
class BoardSkin {
  final String id;
  final String name;
  final Color boardBackground;
  final Color boardGridLine;
  final Color homeArea;
  final Color trackArea;

  const BoardSkin({
    required this.id,
    required this.name,
    required this.boardBackground,
    required this.boardGridLine,
    required this.homeArea,
    required this.trackArea,
  });
}

/// Afro Ludo 主题配置
class AfroTheme {
  AfroTheme._();

  // === 玩家颜色 ===
  static const Color redPlayer = Color(0xFFE53935);
  static const Color greenPlayer = Color(0xFF43A047);
  static const Color yellowPlayer = Color(0xFFFDD835);
  static const Color bluePlayer = Color(0xFF1E88E5);

  static const List<Color> playerColors = [
    redPlayer,
    greenPlayer,
    yellowPlayer,
    bluePlayer,
  ];

  static const List<int> playerColorValues = [
    0xFFE53935,
    0xFF43A047,
    0xFFFDD835,
    0xFF1E88E5,
  ];

  // === Afro 主题色板 ===
  static const Color primary = Color(0xFF8D6E63);      // 暖棕色
  static const Color primaryDark = Color(0xFF5D4037);  // 深棕色
  static const Color accent = Color(0xFFFFB300);       // 非洲金
  static const Color background = Color(0xFFF5F5DC);   // 米黄
  static const Color surface = Color(0xFFFFFFFF);
  static const Color error = Color(0xFFD32F2F);

  // === 棋盘颜色 (Classic) ===
  static const Color boardBackground = Color(0xFFFFF8E1);
  static const Color boardGridLine = Color(0xFFD7CCC8);
  static const Color safeZone = Color(0xFFFFECB3);     // 安全区高亮
  static const Color homeArea = Color(0xFFFFE0B2);     // 家园区域

  // === 可用皮肤 ===
  static const BoardSkin classicSkin = BoardSkin(
    id: 'classic',
    name: 'Classic',
    boardBackground: Color(0xFFFFF8E1),
    boardGridLine: Color(0xFFD7CCC8),
    homeArea: Color(0xFFFFE0B2),
    trackArea: Colors.white,
  );

  static const BoardSkin neonSkin = BoardSkin(
    id: 'neon',
    name: 'Neon',
    boardBackground: Color(0xFF0D1117),
    boardGridLine: Color(0xFF30363D),
    homeArea: Color(0xFF161B22),
    trackArea: Color(0xFF21262D),
  );

  static const BoardSkin afroSkin = BoardSkin(
    id: 'afro',
    name: 'Afro Theme',
    boardBackground: Color(0xFF3E2723),
    boardGridLine: Color(0xFF8D6E63),
    homeArea: Color(0xFFFFB300),
    trackArea: Color(0xFFEFEBE9),
  );

  static const Map<String, BoardSkin> skins = {
    'classic': classicSkin,
    'neon': neonSkin,
    'afro': afroSkin,
  };

  // === 文字颜色 ===
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: primary,
        onPrimary: textOnPrimary,
        secondary: accent,
        onSecondary: textPrimary,
        surface: surface,
        onSurface: textPrimary,
        error: error,
        onError: textOnPrimary,
      ),
      scaffoldBackgroundColor: background,
      appBarTheme: const AppBarTheme(
        backgroundColor: primary,
        foregroundColor: textOnPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: textPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: textSecondary,
        ),
      ),
    );
  }
}
