import 'package:flutter/material.dart';

class AppTheme {
  // ========================================
  // CORES SISTEC
  // ========================================

  // Primárias
  static const Color midnightNavy = Color(0xFF000033);
  static const Color vibrantViolet = Color(0xFF8564FF);
  static const Color peachOrange = Color(0xFFFF9966);

  // Secundárias
  static const Color delftBlue = Color(0xFF3E3D66);
  static const Color tropicalIndigo = Color(0xFFB09AFF);
  static const Color atomicTangerine = Color(0xFFFDB08D);

  // Neutras
  static const Color coolGray = Color(0xFF7B7A99);
  static const Color periwinkle = Color(0xFFDCD3FF);
  static const Color apricot = Color(0xFFFFC6B3);
  static const Color frenchGray = Color(0xFFB9B7CC);
  static const Color lavenderWeb = Color(0xFFEFEBFF);
  static const Color mistyRose = Color(0xFFF9DDD9);

  // ========================================
  // TEMA LIGHT (PRINCIPAL)
  // ========================================

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,

      // Esquema de cores
      colorScheme: const ColorScheme.light(
        primary: vibrantViolet,
        secondary: peachOrange,
        surface: Colors.white,
        error: Colors.red,
        onPrimary: Colors.white,
        onSecondary: midnightNavy,
        onSurface: midnightNavy,
      ),

      // Cor de fundo principal
      scaffoldBackgroundColor: midnightNavy,

      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: midnightNavy,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'BrandonGrotesque',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),

      // Botões Elevados
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: vibrantViolet,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Botões de Texto
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: vibrantViolet,
          textStyle: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Botões com Borda
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: vibrantViolet,
          side: const BorderSide(color: vibrantViolet, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // FloatingActionButton
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: peachOrange,
        foregroundColor: midnightNavy,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      // Cards
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Colors.white,
      ),

      // Input Fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lavenderWeb,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: frenchGray, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: vibrantViolet, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        labelStyle: const TextStyle(fontFamily: 'Montserrat', color: coolGray),
        hintStyle: TextStyle(
          fontFamily: 'Montserrat',
          // ignore: deprecated_member_use
          color: coolGray.withOpacity(0.6),
        ),
      ),

      // Tipografia
      textTheme: const TextTheme(
        // Títulos Grandes (Brandon Grotesque)
        displayLarge: TextStyle(
          fontFamily: 'BrandonGrotesque',
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: midnightNavy,
        ),
        displayMedium: TextStyle(
          fontFamily: 'BrandonGrotesque',
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: midnightNavy,
        ),
        displaySmall: TextStyle(
          fontFamily: 'BrandonGrotesque',
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: midnightNavy,
        ),

        // Títulos Médios (Brandon Grotesque)
        headlineLarge: TextStyle(
          fontFamily: 'BrandonGrotesque',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: midnightNavy,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'BrandonGrotesque',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: midnightNavy,
        ),
        headlineSmall: TextStyle(
          fontFamily: 'BrandonGrotesque',
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: midnightNavy,
        ),

        // Texto Principal (Montserrat)
        bodyLarge: TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: midnightNavy,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: midnightNavy,
        ),
        bodySmall: TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: coolGray,
        ),

        // Labels
        labelLarge: TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: midnightNavy,
        ),
        labelMedium: TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: coolGray,
        ),
        labelSmall: TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: coolGray,
        ),
      ),

      // Cores de Status (para badges)
      extensions: <ThemeExtension<dynamic>>[
        StatusColors(
          open: vibrantViolet,
          inProgress: peachOrange,
          waiting: atomicTangerine,
          resolved: const Color(0xFF4CAF50),
          closed: coolGray,
        ),
      ],
    );
  }

  // ========================================
  // TEMA DARK (OPCIONAL)
  // ========================================

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      colorScheme: const ColorScheme.dark(
        primary: tropicalIndigo,
        secondary: atomicTangerine,
        surface: delftBlue,
        error: Colors.red,
        onPrimary: midnightNavy,
        onSecondary: Colors.white,
        onSurface: Colors.white,
      ),

      scaffoldBackgroundColor: midnightNavy,

      appBarTheme: const AppBarTheme(
        backgroundColor: delftBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),

      // Continua com as mesmas configurações adaptadas para dark
    );
  }
}

// ========================================
// EXTENSÃO PARA CORES DE STATUS
// ========================================

class StatusColors extends ThemeExtension<StatusColors> {
  final Color open;
  final Color inProgress;
  final Color waiting;
  final Color resolved;
  final Color closed;

  StatusColors({
    required this.open,
    required this.inProgress,
    required this.waiting,
    required this.resolved,
    required this.closed,
  });

  @override
  StatusColors copyWith({
    Color? open,
    Color? inProgress,
    Color? waiting,
    Color? resolved,
    Color? closed,
  }) {
    return StatusColors(
      open: open ?? this.open,
      inProgress: inProgress ?? this.inProgress,
      waiting: waiting ?? this.waiting,
      resolved: resolved ?? this.resolved,
      closed: closed ?? this.closed,
    );
  }

  @override
  StatusColors lerp(ThemeExtension<StatusColors>? other, double t) {
    if (other is! StatusColors) return this;
    return StatusColors(
      open: Color.lerp(open, other.open, t)!,
      inProgress: Color.lerp(inProgress, other.inProgress, t)!,
      waiting: Color.lerp(waiting, other.waiting, t)!,
      resolved: Color.lerp(resolved, other.resolved, t)!,
      closed: Color.lerp(closed, other.closed, t)!,
    );
  }
}
