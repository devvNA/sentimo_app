import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color background = Color(0xFF1F2937);
  static const Color blue = Color(0xFF2B8CEE);
  static const Color softBlue = Color(0xFF6BA5CF);
  static const Color mintGreen = Color(0xFF91C2A9);
  static const Color offWhite = Color(0xFFF7F7F7);
  static const Color darkGray = Color(0xFF2C3E50);
  static const Color white = Color(0xFFFFFFFF);

  // Dark theme colors
  static const Color darkBackground = Color(0xFF101922);
  static const Color darkCard = Color(0xFF374151);
  static const Color darkCardHover = Color(0xFF4B5563);
  static const Color brightBlue = Color(0xFF3B82F6);
  static const Color darkText = Color(0xFFE5E7EB);
  static const Color darkTextSecondary = Color(0xFF9CA3AF);

  static ThemeData theme = ThemeData(
    useMaterial3: false,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: darkBackground,
    colorScheme: ColorScheme.dark(
      primary: brightBlue,
      secondary: mintGreen,
      surface: darkCard,
      onPrimary: white,
      onSecondary: white,
      onSurface: darkText,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: darkBackground,
      elevation: 0,
      iconTheme: IconThemeData(color: darkText),
      titleTextStyle: TextStyle(
        color: white,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    ),
    textTheme: GoogleFonts.poppinsTextTheme(
      TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: white,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: white,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: white,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: white,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: darkText,
        ),
        bodyLarge: TextStyle(fontSize: 16, color: darkText),
        bodyMedium: TextStyle(fontSize: 14, color: darkTextSecondary),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: brightBlue,
        foregroundColor: white,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    cardTheme: CardThemeData(
      color: darkCard,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: darkCard,
      selectedItemColor: brightBlue,
      unselectedItemColor: darkTextSecondary,
      type: BottomNavigationBarType.fixed,
    ),
  );
}
