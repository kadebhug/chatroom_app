import 'package:flutter/material.dart';

enum ThemeType { light, dark, custom }

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.blue,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black87),
      bodyMedium: TextStyle(color: Colors.black87),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.deepPurple,
    scaffoldBackgroundColor: const Color(0xFF272822),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF3E3D32),
      foregroundColor: Color(0xFFF8F8F2),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Color(0xFFF8F8F2)),
      bodyMedium: TextStyle(color: Color(0xFFF8F8F2)),
    ),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFFA6E22E),
      secondary: Color(0xFFF92672),
      tertiary: Color(0xFFFD971F),
    ),
  );

  static ThemeData getThemeFromType(ThemeType type) {
    switch (type) {
      case ThemeType.light:
        return lightTheme;
      case ThemeType.dark:
        return darkTheme;
      case ThemeType.custom:
        return lightTheme;
    }
  }
}
