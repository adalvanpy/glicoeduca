import 'package:flutter/material.dart';

class TextStyles {

  static const TextStyle logoRed = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Color(0xFFEF5350),
  );

  static const TextStyle logoGreen = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Color(0xFF2DB93B),
  );

  static const TextStyle pageTitle = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w700,
    color: Color(0xFF1F2937),
    height: 1.2,
  );

  static const TextStyle cardTitle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: Color(0xFF1F2937),
    height: 1.3,
  );

  static const TextStyle description = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: Color(0xFF374151),
    height: 1.4,
  );

  static const TextStyle cardBodyText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: Color(0xFF374151),
    height: 1.45,
  );

  static const TextStyle highlight = TextStyle(
    fontSize: 13.5,
    fontWeight: FontWeight.w600,
    color: Color(0xFF1F2937),
    height: 1.4,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: Color(0xFF374151),
    height: 1.4,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Color(0xFF1F2937),
    height: 1.4,
  );

  static const TextStyle navigation = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: Color(0xFF374151),
    height: 1.3,
  );

  static const TextStyle question = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Color(0xFF1F2937),
    height: 1.4,
  );

  static const TextStyle foodName = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Color(0xFF1F2937),
  );

  static const TextStyle success = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Color(0xFF2DB93B),
    height: 1.4,
  );

  static const TextStyle explanation = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: Color(0xFF374151),
    height: 1.45,
  );

  static const TextStyle sectionTitle = pageTitle;

  static const TextTheme textTheme = TextTheme(
    headlineSmall: pageTitle,
    titleLarge: cardTitle,
    titleMedium: cardTitle,
    titleSmall: description,
    bodyLarge: cardBodyText,
    bodyMedium: cardBodyText,
    bodySmall: bodySmall,
    labelLarge: highlight,
    labelMedium: highlight,
    labelSmall: bodySmall,
  );
}

