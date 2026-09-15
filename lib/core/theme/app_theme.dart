import 'package:flutter/material.dart';
import 'text_styles.dart';

class AppTheme {

  static Color withAlphaPercent(Color color, int percent) {
    assert(percent >= 0 && percent <= 100, 'A porcentagem deve estar entre 0 e 100.');
    return color.withAlpha((255 * percent / 100).round());
  }

  static const Color azul = Color(0xFF1E90FF);
  static const Color verde = Color(0xFF2DB93B);
  static const Color vermelho = Color(0xFFEF5350);
  static const Color laranja = Color(0xFFFF9800);
  static const Color roxo = Color(0xFF8E44AD);
  static const Color ciano = Color(0xFF00BCD4);
  static const Color amarelo = Color(0xFFFFC107);
  static const Color marrom = Color(0xFF795548);
  static const Color cinza = Color(0xFF607D8B);
  static const Color branco = Color(0xFFFFFFFF);

  static const Color primaryColor = azul;
  static const Color successColor = verde;
  static const Color errorColor = vermelho;
  static const Color warningColor = laranja;
  static const Color purpleColor = roxo;

  static const Color breakfastColor = Color(0xFF1E90FF);
  static const Color morningSnackColor = Color(0xFF00BCD4);
  static const Color lunchColor = Color(0xFF4CAF50);
  static const Color preWorkoutColor = Color(0xFFFF9800);
  static const Color postWorkoutColor = Color(0xFF9C27B0);
  static const Color dinnerColor = Color(0xFF8E44AD);
  static const Color afternoonSnackColor = Color(0xFFFFC107);
  static const Color supperColor = Color(0xFF795548);
  static const Color contextDefaultColor = Color(0xFF607D8B);

  static Color getContextBackgroundColor(String id) {
    switch (id) {
      case 'breakfast':
        return withAlphaPercent(breakfastColor, 15);
      case 'morning_snack':
      case 'mid_morning':
        return withAlphaPercent(morningSnackColor, 15);
      case 'lunch':
        return withAlphaPercent(lunchColor, 15);
      case 'pre_workout':
        return withAlphaPercent(preWorkoutColor, 15);
      case 'post_workout':
        return withAlphaPercent(postWorkoutColor, 15);
      case 'dinner':
        return withAlphaPercent(dinnerColor, 15);
      case 'afternoon_snack':
      case 'evening_snack':
        return withAlphaPercent(afternoonSnackColor, 15);
      case 'supper':
        return withAlphaPercent(supperColor, 15);
      default:
        return withAlphaPercent(contextDefaultColor, 15);
    }
  }

  static Color getContextBorderColor(String id) {
    switch (id) {
      case 'breakfast':
        return breakfastColor;
      case 'morning_snack':
      case 'mid_morning':
        return morningSnackColor;
      case 'lunch':
        return lunchColor;
      case 'pre_workout':
        return preWorkoutColor;
      case 'post_workout':
        return postWorkoutColor;
      case 'dinner':
        return dinnerColor;
      case 'afternoon_snack':
      case 'evening_snack':
        return afternoonSnackColor;
      case 'supper':
        return supperColor;
      default:
        return contextDefaultColor;
    }
  }

  static const Color textColor = Color(0xFF1F2937);
  static const Color secondaryTextColor = Color(0xFF374151);

  static const Color backgroundColor = Color(0xFFFFFFFF);
  static const Color cardBorderColor = Color(0xFFD9D9D9);

  static BoxDecoration cardDecoration({
    Color? backgroundColor,
    Color? borderColor,
    double borderWidth = 1,
    double radius = 16,
  }) {
    return BoxDecoration(
      color: backgroundColor ?? Colors.white,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: borderColor ?? cardBorderColor,
        width: borderWidth,
      ),
    );
  }

  static const Color infoCardBackground = Color(0x261E90FF); // 15% de 1E90FF
  static const Color infoCardBorder = Color(0xFF64B5F6);

  static const Color simpleCardBackground = Color(0x26FF9800); // 15% de FF9800
  static const Color simpleCardBorder = Color(0xFFFF9800);

  static const Color starchCardBackground = Color(0x26FFF8D6); // 15% de FFF8D6
  static const Color starchCardBorder = Color(0xFFFBC02D);

  static const Color sugarCardBackground = Color(0x26FF9800); // 15% de FF9800
  static const Color sugarCardBorder = Color(0xFFFF9800);

  static const Color complexCardBackground = Color(0x26DFF5E1); // 15% de DFF5E1
  static const Color complexCardBorder = Color(0xFF66BB6A);

  static const Color dangerCardBackground = Color(0x26EF5350); // 15% de EF5350
  static const Color dangerCardBorder = Color(0xFFEF5350);

  static Color getGlycemicIndexColor(double value) {
    if (value <= 55) return complexCardBorder;
    if (value <= 69) return simpleCardBorder;
    return dangerCardBorder;
  }

  static Color getGlycemicIndexBackgroundColor(double value) {
    if (value <= 55) return complexCardBackground;
    if (value <= 69) return simpleCardBackground;
    return dangerCardBackground;
  }

  static Color getGlycemicLoadColor(double value) {
    if (value <= 10) return complexCardBorder;
    if (value <= 19) return simpleCardBorder;
    return dangerCardBorder;
  }

  static Color getGlycemicLoadBackgroundColor(double value) {
    if (value <= 10) return complexCardBackground;
    if (value <= 19) return simpleCardBackground;
    return dangerCardBackground;
  }

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
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
