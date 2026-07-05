import 'package:flutter/material.dart';

class AppTheme {
  // Brand Color Palette
  static const Color primaryEmerald = Color(0xFF0F5132);
  static const Color primaryEmeraldLight = Color(0xFF198754);
  static const Color accentGold = Color(0xFFD4AF37);
  static const Color darkBackground = Color(0xFF10171A);
  static const Color darkSurface = Color(0xFF1A2328);
  static const Color darkCard = Color(0xFF222E34);
  
  static const Color lightBackground = Color(0xFFF4F7F6);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFE9F0EC);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: primaryEmeraldLight,
        secondary: accentGold,
        surface: darkSurface,
        onSurface: Colors.white,
      ),
      cardTheme: const CardThemeData(
        color: darkCard,
        elevation: 2,
        margin: EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkSurface,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
        headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.white),
        titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: accentGold),
        bodyLarge: TextStyle(fontSize: 16, color: Colors.white70),
        bodyMedium: TextStyle(fontSize: 14, color: Colors.white60),
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBackground,
      colorScheme: const ColorScheme.light(
        primary: primaryEmerald,
        secondary: accentGold,
        surface: lightSurface,
        onSurface: Colors.black87,
      ),
      cardTheme: const CardThemeData(
        color: lightCard,
        elevation: 1,
        margin: EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: lightSurface,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.black87),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: primaryEmerald),
        headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: primaryEmerald),
        titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: primaryEmerald),
        bodyLarge: TextStyle(fontSize: 16, color: Colors.black87),
        bodyMedium: TextStyle(fontSize: 14, color: Colors.black54),
      ),
    );
  }
}
