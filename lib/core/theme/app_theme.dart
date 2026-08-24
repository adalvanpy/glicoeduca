import 'package:flutter/material.dart';
import 'text_styles.dart';

class AppTheme {
  // Cores principais
  static const Color primaryColor = Color(0xFF2196F3);
  static const Color successColor = Color(0xFF22B83D);
  static const Color errorColor = Color(0xFFE53935);

  // Textos
  static const Color textColor = Color(0xFF222222);
  static const Color secondaryTextColor = Color(0xFF444444);

  // Fundo e cards
  static const Color backgroundColor = Color(0xFFF8F9FA);
  static const Color cardBorderColor = Color(0xFFE0E0E0);
  static const Color cardSelectedColor = Color(0xFFE8F5E9);

  // ==========================================================
  // CORES DOS CONTEXTOS
  // ==========================================================

  static const Color breakfastColor = Color(0xFFB8E6B8);
  static const Color morningSnackColor = Color(0xFFFFD59A);
  static const Color lunchColor = Color(0xFFB8D8F5);
  static const Color preWorkoutColor = Color(0xFFD5B8E8);
  static const Color postWorkoutColor = Color(0xFFF3B8B8);
  static const Color dinnerColor = Color(0xFFB8E6B8);
  static const Color afternoonSnackColor = Color(0xFFFFD59A);
  static const Color supperColor = Color(0xFFBFC8E8);

  static const Color contextDefaultColor = Color(0xFFE0E0E0);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,

      scaffoldBackgroundColor: backgroundColor,

      primaryColor: primaryColor,

      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        surface: Colors.white,
        error: errorColor,
      ),

      fontFamily: 'Roboto',

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: textColor,
      ),

      textTheme: TextStyles.textTheme,

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(
            color: cardBorderColor,
            width: 1,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: cardBorderColor,
          ),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: cardBorderColor,
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: primaryColor,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}