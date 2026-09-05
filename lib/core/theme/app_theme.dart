// app_theme.dart

import 'package:flutter/material.dart';
import 'text_styles.dart';

class AppTheme {
  // ==========================================================
  // CORES PRINCIPAIS
  // ==========================================================

  static const Color primaryColor = Color(0xFF1E88E5);

  static const Color successColor = Color(0xFF22B83D);

  static const Color errorColor = Color(0xFFE53935);

  // ==========================================================
  // TEXTOS
  // ==========================================================

  static const Color textColor = Color(0xFF212121);

  static const Color secondaryTextColor = Color(0xFF555555);

  // ==========================================================
  // FUNDOS E CARDS
  // ==========================================================

  static const Color backgroundColor = Color(0xFFFFFFFF);

  static const Color cardBorderColor = Color(0xFFDADADA);

  static const Color cardSelectedColor = Color(0xFFE8F5E9);

  // ==========================================================
  // CONTEXTOS
  // ==========================================================

  static const Color breakfastColor = Color(0xFFDFF5DF);

  static const Color morningSnackColor = Color(0xFFFFF1D6);

  static const Color lunchColor = Color(0xFFDDEEFF);

  static const Color preWorkoutColor = Color(0xFFF2E3FF);

  static const Color postWorkoutColor = Color(0xFFFFE0E0);

  static const Color dinnerColor = Color(0xFFDFF5DF);

  static const Color afternoonSnackColor = Color(0xFFFFF1D6);

  static const Color supperColor = Color(0xFFE5E8FF);

  static const Color contextDefaultColor = Color(0xFFEAEAEA);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,

      fontFamily: 'Roboto',

      scaffoldBackgroundColor: backgroundColor,

      primaryColor: primaryColor,

      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        surface: Colors.white,
        error: errorColor,
      ),

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
          minimumSize: const Size(double.infinity, 46),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
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
          horizontal: 14,
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

      dividerColor: cardBorderColor,
    );
  }
}