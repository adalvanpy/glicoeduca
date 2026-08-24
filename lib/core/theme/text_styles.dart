import 'package:flutter/material.dart';

class TextStyles {
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    color: Color(0xFF333333),
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    color: Color(0xFF333333),
    height: 1.2,
  );

  static const TextTheme textTheme = TextTheme(
    bodyLarge: TextStyle(
      fontSize: 16,
      color: Color(0xFF222222),
    ),
    bodyMedium: bodyMedium,
    bodySmall: bodySmall,
    titleLarge: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Color(0xFF222222),
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Color(0xFF222222),
    ),
    labelLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: Colors.white,
    ),
  );

  static const TextStyle logoRed = TextStyle(
    fontSize: 22,
    color: Color(0xFFE53935),
    fontWeight: FontWeight.bold,
  );

  static const TextStyle logoGreen = TextStyle(
    fontSize: 22,
    color: Color(0xFF22B83D),
    fontWeight: FontWeight.bold,
  );

  static const TextStyle pageTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Color(0xFF222222),
  );

  static const TextStyle description = TextStyle(
    fontSize: 13,
    height: 1.2,
    color: Color(0xFF333333),
  );

  static const TextStyle sectionTitle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.bold,
    color: Color(0xFF333333),
  );

  static const TextStyle foodName = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Color(0xFF333333),
  );

  static const TextStyle foodMetric = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.bold,
    color: Color(0xFF222222),
  );

  static const TextStyle indicator = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Color(0xFF222222),
    height: 1.05,
  );

  static const TextStyle question = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Color(0xFF333333),
  );

  static const TextStyle success = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: Color(0xFF22B83D),
  );

  static const TextStyle explanation = TextStyle(
    fontSize: 12,
    height: 1.25,
    color: Color(0xFF333333),
  );

  static const TextStyle navigation = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: Color(0xFF444444),
  );

  static const TextStyle navigationActive = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.bold,
    color: Color(0xFF2196F3),
  );
}
