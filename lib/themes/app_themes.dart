import 'package:flutter/material.dart';

class AppThemes {
  static const Color _primaryColor = Color(0xFF6750A4);
  static const Color _secondaryColor = Color(0xFF03DAC6);

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _primaryColor,
      brightness: Brightness.light,
    ).copyWith(
      secondary: _secondaryColor,
      tertiary: const Color(0xFFFFB4AB),
    ),
    scaffoldBackgroundColor: const Color(0xFFF7F2FA),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFF7F2FA),
      foregroundColor: Color(0xFF1C1B1F),
      elevation: 0,
    ),
    cardTheme: CardTheme(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    textTheme: const TextTheme(
      headlineMedium:
          TextStyle(color: Color(0xFF1C1B1F), fontWeight: FontWeight.bold),
      bodyLarge: TextStyle(color: Color(0xFF1C1B1F)),
      bodyMedium: TextStyle(color: Color(0xFF1C1B1F)),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: _primaryColor,
      unselectedItemColor: Colors.grey,
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _primaryColor,
      brightness: Brightness.dark,
    ).copyWith(
      secondary: _secondaryColor,
      tertiary: const Color(0xFFFFB4AB),
    ),
    scaffoldBackgroundColor: const Color(0xFF1C1B1F),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1C1B1F),
      foregroundColor: Color(0xFFE6E1E5),
      elevation: 0,
    ),
    cardTheme: CardTheme(
      color: const Color(0xFF2D2C31),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    textTheme: const TextTheme(
      headlineMedium:
          TextStyle(color: Color(0xFFE6E1E5), fontWeight: FontWeight.bold),
      bodyLarge: TextStyle(color: Color(0xFFE6E1E5)),
      bodyMedium: TextStyle(color: Color(0xFFE6E1E5)),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF2D2C31),
      selectedItemColor: _primaryColor,
      unselectedItemColor: Colors.grey,
    ),
  );

  static Color getChartColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? _primaryColor
        : _primaryColor;
  }
}
