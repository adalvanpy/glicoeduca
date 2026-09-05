// text_styles.dart

import 'package:flutter/material.dart';

class TextStyles {
  // ==========================================================
  // TEXT THEME
  // ==========================================================

  static const TextTheme textTheme = TextTheme(
    titleLarge: pageTitle,
    titleMedium: sectionTitle,
    bodyLarge: bodyLarge,
    bodyMedium: bodyMedium,
    bodySmall: bodySmall,
    labelLarge: button,
  );

  // ==========================================================
  // LOGO
  // ==========================================================

  static const TextStyle logoRed = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: Color(0xFFE53935),
  );

  static const TextStyle logoGreen = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: Color(0xFF22B83D),
  );

  // ==========================================================
  // TÍTULOS
  // ==========================================================

  static const TextStyle pageTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: Color(0xFF212121),
  );

  static const TextStyle sectionTitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Color(0xFF212121),
  );

  // ==========================================================
  // CORPO
  // ==========================================================

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    color: Color(0xFF212121),
    height: 1.4,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    color: Color(0xFF333333),
    height: 1.4,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    color: Color(0xFF555555),
    height: 1.35,
  );

  static const TextStyle description = TextStyle(
    fontSize: 13,
    color: Color(0xFF444444),
    height: 1.4,
  );

  // ==========================================================
  // BOTÕES
  // ==========================================================

  static const TextStyle button = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  // ==========================================================
  // GUIA TEÓRICO
  // ==========================================================

  static const TextStyle indicator = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: Color(0xFF212121),
  );

  // ==========================================================
  // ALIMENTOS
  // ==========================================================

  static const TextStyle foodName = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: Color(0xFF212121),
  );

  static const TextStyle foodMetric = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: Color(0xFF212121),
  );

  // ==========================================================
  // QUIZ
  // ==========================================================

  static const TextStyle question = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: Color(0xFF212121),
  );

  static const TextStyle success = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: Color(0xFF22B83D),
  );

  static const TextStyle explanation = TextStyle(
    fontSize: 12,
    color: Color(0xFF444444),
    height: 1.4,
  );

  // ==========================================================
  // PERFIL
  // ==========================================================

  static const TextStyle profileName = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Color(0xFF212121),
  );

  // ==========================================================
  // NAVEGAÇÃO
  // ==========================================================

  static const TextStyle navigation = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: Color(0xFF666666),
  );

  static const TextStyle navigationActive = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    color: Color(0xFF1E88E5),
  );
}
