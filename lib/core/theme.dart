import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Emerald and Gold Islamic Palette
  static const Color primaryEmerald = Color(0xFF0F5132);
  static const Color primaryEmeraldLight = Color(0xFF198754);
  static const Color goldAccent = Color(0xFFD4AF37);
  static const Color goldAccentDark = Color(0xFFAA7C11);
  static const Color sandBackgroundLight = Color(0xFFFDFBF7);
  static const Color darkSlateBackground = Color(0xFF121814);
  static const Color darkCardBackground = Color(0xFF1E2621);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryEmerald,
      colorScheme: const ColorScheme.light(
        primary: primaryEmerald,
        secondary: goldAccent,
        tertiary: primaryEmeraldLight,
        background: sandBackgroundLight,
        surface: Colors.white,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
      ),
      scaffoldBackgroundColor: sandBackgroundLight,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryEmerald,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 2,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      textTheme: GoogleFonts.plusJakartaSansTextTheme(
        const TextTheme(
          displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: primaryEmerald),
          titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryEmerald),
          bodyLarge: TextStyle(fontSize: 16, color: Colors.black87),
          bodyMedium: TextStyle(fontSize: 14, color: Colors.black54),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryEmerald,
          foregroundColor: Colors.white,
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryEmeraldLight,
      colorScheme: const ColorScheme.dark(
        primary: primaryEmeraldLight,
        secondary: goldAccent,
        tertiary: goldAccent,
        background: darkSlateBackground,
        surface: darkCardBackground,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
      ),
      scaffoldBackgroundColor: darkSlateBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: darkCardBackground,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardTheme(
        color: darkCardBackground,
        elevation: 1,
        shadowColor: Colors.black38,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      textTheme: GoogleFonts.plusJakartaSansTextTheme(
        const TextTheme(
          displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
          titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          bodyLarge: TextStyle(fontSize: 16, color: Colors.white90),
          bodyMedium: TextStyle(fontSize: 14, color: Colors.white70),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryEmeraldLight,
          foregroundColor: Colors.white,
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
    );
  }
}
