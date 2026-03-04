import 'package:flutter/material.dart';

class AppTheme {
  static const Color sc2BgPrimary = Color(0xFF0f0f1a);
  static const Color sc2BgSecondary = Color(0xFF1a1a2e);
  static const Color sc2BgCard = Color(0xFF16213e);
  static const Color sc2AccentPrimary = Color(0xFFe94560);
  static const Color sc2AccentSecondary = Color(0xFF0f3460);
  static const Color sc2Gold = Color(0xFFffd700);
  static const Color sc2Protoss = Color(0xFF00ffff);
  static const Color sc2Terran = Color(0xFFff6600);
  static const Color sc2Zerg = Color(0xFF9932cc);

  static const Color uniTextColor = Color(0xFFe0e0e0);
  static const Color uniTextColorGrey = Color(0xFF7a7a9a);
  static const Color uniTextColorPlaceholder = Color(0xFF5a5a7a);
  static const Color uniColorTitle = Color(0xFFffffff);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'SourceHanSansSC',
      colorScheme: const ColorScheme.dark(
        primary: sc2AccentPrimary,
        secondary: sc2AccentSecondary,
        surface: sc2BgCard,
        background: sc2BgPrimary,
        error: Colors.red,
      ),
      scaffoldBackgroundColor: sc2BgPrimary,
      cardColor: sc2BgCard,
      dialogBackgroundColor: sc2BgSecondary,
      appBarTheme: const AppBarTheme(
        backgroundColor: sc2BgSecondary,
        foregroundColor: uniTextColor,
        elevation: 0,
        centerTitle: true,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 72,
          fontWeight: FontWeight.w800,
          color: uniTextColor,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: uniColorTitle,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: uniColorTitle,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: uniColorTitle,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: uniTextColor,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: uniTextColor,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: uniTextColorGrey,
        ),
        labelLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: sc2BgSecondary,
        hintStyle: const TextStyle(color: uniTextColorPlaceholder),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: sc2AccentSecondary),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: sc2AccentSecondary),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: sc2AccentPrimary, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: sc2AccentPrimary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: uniTextColor,
          side: const BorderSide(color: sc2AccentSecondary),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  static Color getFactionColor(String faction) {
    switch (faction.toUpperCase()) {
      case 'P':
        return sc2Protoss;
      case 'T':
        return sc2Terran;
      case 'Z':
        return sc2Zerg;
      default:
        return uniTextColor;
    }
  }
}
