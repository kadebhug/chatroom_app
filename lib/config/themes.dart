import 'package:flutter/material.dart';

enum ThemeType { light, dark }

class AppTheme {
  static const List<Color> predefinedColors = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
  ];

  static ThemeData getThemeFromType(ThemeType type, Color primaryColor) {
    switch (type) {
      case ThemeType.light:
        return _buildLightTheme(primaryColor);
      case ThemeType.dark:
        return _buildDarkTheme(primaryColor);
    }
  }

  static ThemeData _buildLightTheme(Color primaryColor) {
    return ThemeData(
      brightness: Brightness.light,
      primarySwatch: MaterialColor(primaryColor.value, {
        50: primaryColor.withOpacity(0.1),
        100: primaryColor.withOpacity(0.2),
        200: primaryColor.withOpacity(0.3),
        300: primaryColor.withOpacity(0.4),
        400: primaryColor.withOpacity(0.5),
        500: primaryColor,
        600: primaryColor.withOpacity(0.7),
        700: primaryColor.withOpacity(0.8),
        800: primaryColor.withOpacity(0.9),
        900: primaryColor.withOpacity(1),
      }),
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.black87),
        bodyMedium: TextStyle(color: Colors.black87),
      ),
    );
  }

  static ThemeData _buildDarkTheme(Color primaryColor) {
    return ThemeData(
      brightness: Brightness.dark,
      primarySwatch: MaterialColor(primaryColor.value, {
        50: primaryColor.withOpacity(0.1),
        100: primaryColor.withOpacity(0.2),
        200: primaryColor.withOpacity(0.3),
        300: primaryColor.withOpacity(0.4),
        400: primaryColor.withOpacity(0.5),
        500: primaryColor,
        600: primaryColor.withOpacity(0.7),
        700: primaryColor.withOpacity(0.8),
        800: primaryColor.withOpacity(0.9),
        900: primaryColor.withOpacity(1),
      }),
      scaffoldBackgroundColor: const Color(0xFF272822),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Color(0xFFF8F8F2)),
        bodyMedium: TextStyle(color: Color(0xFFF8F8F2)),
      ),
    );
  }
}
