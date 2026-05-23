import 'package:flutter/material.dart';

/// 棋盘皮肤配置
class BoardSkin {
  final String id;
  final String name;
  final Color boardBackground;
  final Color boardGridLine;
  final Color homeArea;
  final Color trackArea;

  // 新增字段
  final Color safeCellColor;
  final Color kenteBorderColor;
  final String adinkraSymbol;
  final Color centerSymbolColor;
  final List<Color> kenteSequence;

  const BoardSkin({
    required this.id,
    required this.name,
    required this.boardBackground,
    required this.boardGridLine,
    required this.homeArea,
    required this.trackArea,
    this.safeCellColor = const Color(0xFFFFD700),
    this.kenteBorderColor = const Color(0xFFFFD700),
    this.adinkraSymbol = 'fawohodie',
    this.centerSymbolColor = const Color(0xFFFFD700),
    this.kenteSequence = const [
      Color(0xFFFFD700),
      Color(0xFF1A9D3E),
      Color(0xFFFF6B35),
      Color(0xFFE63946),
    ],
  });
}

/// Afro Ludo 主题配置 — Afro Vibrant 暗色体系
class AfroTheme {
  AfroTheme._();

  // === Afro Vibrant 色板 ===
  static const Color primary = Color(0xFFFF6B35);
  static const Color primaryDark = Color(0xFFE55A2B);
  static const Color secondary = Color(0xFF1A9D3E);
  static const Color accentGold = Color(0xFFFFD700);
  static const Color highlight = Color(0xFFE63946);
  static const Color background = Color(0xFF1A1A2E);
  static const Color surface = Color(0xFF16213E);
  static const Color card = Color(0xFF0F3460);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB8B8D0);
  static const Color border = Color(0x4DFFD700);
  static const Color error = Color(0xFFE63946);

  // 辅助色
  static const Color purpleRoyal = Color(0xFF9B59B6);
  static const Color purpleDark = Color(0xFF8E44AD);

  // === 预定义渐变 ===
  static const Gradient orangeGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient greenGradient = LinearGradient(
    colors: [secondary, Color(0xFF148F3B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient goldGradient = LinearGradient(
    colors: [accentGold, Color(0xFFF4C430)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient redGradient = LinearGradient(
    colors: [highlight, Color(0xFFC0392B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient purpleGradient = LinearGradient(
    colors: [purpleRoyal, purpleDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // === 玩家颜色（升级版） ===
  static const Color redPlayer = Color(0xFFFF4757);
  static const Color greenPlayer = Color(0xFF2ED573);
  static const Color yellowPlayer = Color(0xFFFFA502);
  static const Color bluePlayer = Color(0xFF1E90FF);

  static const List<Color> playerColors = [
    redPlayer,
    greenPlayer,
    yellowPlayer,
    bluePlayer,
  ];

  static const List<int> playerColorValues = [
    0xFFFF4757,
    0xFF2ED573,
    0xFFFFA502,
    0xFF1E90FF,
  ];

  // 玩家渐变
  static const List<List<Color>> playerGradients = [
    [Color(0xFFFF4757), Color(0xFFFF6B81)],
    [Color(0xFF2ED573), Color(0xFF7BED9F)],
    [Color(0xFFFFA502), Color(0xFFFFDA79)],
    [Color(0xFF1E90FF), Color(0xFF70A1FF)],
  ];

  // === Kente 颜色序列 ===
  static const List<Color> kenteColors = [
    Color(0xFFFFD700),
    Color(0xFF1A9D3E),
    Color(0xFFFF6B35),
    Color(0xFFE63946),
  ];

  // === 棋盘颜色 (Classic Wood) ===
  static const Color boardBgClassic = Color(0xFF3E2723);
  static const Color trackAreaClassic = Color(0xFFF4E8C1);
  static const Color safeZone = Color(0xFFFFECB3);

  // === 可用皮肤 ===
  static const BoardSkin classicSkin = BoardSkin(
    id: 'classic',
    name: 'Classic Wood',
    boardBackground: Color(0xFF3E2723),
    boardGridLine: Color(0xFF5D4037),
    homeArea: Color(0xFFFFD700),
    trackArea: Color(0xFFF4E8C1),
    safeCellColor: Color(0xFFFFD700),
    kenteBorderColor: Color(0xFFFFD700),
    adinkraSymbol: 'fawohodie',
    centerSymbolColor: Color(0xFFFFD700),
    kenteSequence: [
      Color(0xFFFFD700),
      Color(0xFF1A9D3E),
      Color(0xFFFF6B35),
      Color(0xFFE63946),
    ],
  );

  static const BoardSkin neonSkin = BoardSkin(
    id: 'neon',
    name: 'Afropunk Neon',
    boardBackground: Color(0xFF0D0D0D),
    boardGridLine: Color(0xFF1A1A2E),
    homeArea: Color(0xFF00FF88),
    trackArea: Color(0xFF1A1A2E),
    safeCellColor: Color(0xFF00FF88),
    kenteBorderColor: Color(0xFF00FF88),
    adinkraSymbol: 'fawohodie',
    centerSymbolColor: Color(0xFF00FF88),
    kenteSequence: [
      Color(0xFF00FF88),
      Color(0xFFFF69B4),
      Color(0xFF9B59B6),
      Color(0xFF00BFFF),
    ],
  );

  static const BoardSkin afroSkin = BoardSkin(
    id: 'afro',
    name: 'Ankara Vibrant',
    boardBackground: Color(0xFF0F3460),
    boardGridLine: Color(0xFF1A5276),
    homeArea: Color(0xFFFFD700),
    trackArea: Color(0xFFFFF8E1),
    safeCellColor: Color(0xFFFFD700),
    kenteBorderColor: Color(0xFFFF6B35),
    adinkraSymbol: 'nkyinkyim',
    centerSymbolColor: Color(0xFFFFD700),
    kenteSequence: [
      Color(0xFF9B59B6),
      Color(0xFFFF6B35),
      Color(0xFF1A9D3E),
      Color(0xFFFF69B4),
    ],
  );

  static const Map<String, BoardSkin> skins = {
    'classic': classicSkin,
    'neon': neonSkin,
    'afro': afroSkin,
  };

  static ThemeData get lightTheme => darkTheme;

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        onPrimary: textPrimary,
        secondary: accentGold,
        onSecondary: Color(0xFF1A1A2E),
        surface: surface,
        onSurface: textPrimary,
        error: error,
        onError: textPrimary,
        primaryContainer: card,
        secondaryContainer: surface,
      ),
      scaffoldBackgroundColor: background,
      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 1,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: textPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: accentGold,
          side: const BorderSide(color: accentGold, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return secondary;
          return const Color(0xFF333355);
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return secondary.withValues(alpha: 0.4);
          }
          return const Color(0xFF222244);
        }),
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
        titleMedium: TextStyle(
          fontSize: 16,
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
        labelLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
      ),
    );
  }
}
