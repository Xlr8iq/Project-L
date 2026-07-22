import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Clinical Light Color Palette (Matching Chart)
  static const Color backgroundLight = Color(0xFFF8FAFC); // Clean off-white
  static const Color surfaceLight = Color(0xFFFFFFFF);    // Pure white
  static const Color primaryBlue = Color(0xFF1565C0);     // Clinical Blue
  static const Color primaryDarkBlue = Color(0xFF0D47A1); // Deep Clinical Blue
  static const Color textPrimary = Color(0xFF1E293B);     // High contrast dark slate
  static const Color textSecondary = Color(0xFF64748B);   // Muted slate
  static const Color borderLight = Color(0xFFE2E8F0);      // Subtle border divider

  // Legacy alias constants for backwards compatibility
  static const Color backgroundDark = Color(0xFFF8FAFC);
  static const Color surfaceDark = Color(0xFFFFFFFF);
  static const Color accentCyan = Color(0xFF1565C0);

  // Charting Colors
  static const Color toothNormal = Color(0xFFE2E8F0);
  static const Color chartRestoration = Color(0xFF3B82F6); // Blue
  static const Color chartExtraction = Color(0xFFEF4444);  // Red
  static const Color chartEndo = Color(0xFF10B981);        // Green
  static const Color chartImplant = Color(0xFF8B5CF6);     // Purple
  static const Color chartCrown = Color(0xFFF59E0B);       // Amber/Gold
  static const Color chartVeneer = Color(0xFFEC4899);      // Pink
  static const Color chartBridge = Color(0xFF14B8A6);      // Teal

  // Palmer Chart
  static const Color chartBlueAccent = Color(0xFF1565C0);  // Professional blue

  static ThemeData get lightTheme {
    return ThemeData.light().copyWith(
      scaffoldBackgroundColor: backgroundLight,
      primaryColor: primaryBlue,
      colorScheme: const ColorScheme.light().copyWith(
        primary: primaryBlue,
        secondary: primaryDarkBlue,
        surface: surfaceLight,
        onSurface: textPrimary,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme).copyWith(
        displayLarge: GoogleFonts.outfit(color: textPrimary, fontWeight: FontWeight.bold),
        headlineMedium: GoogleFonts.outfit(color: textPrimary, fontWeight: FontWeight.w600),
        headlineSmall: GoogleFonts.outfit(color: primaryBlue, fontWeight: FontWeight.w600),
        titleLarge: GoogleFonts.inter(color: textPrimary, fontWeight: FontWeight.w600),
        bodyLarge: GoogleFonts.inter(color: textPrimary),
        bodyMedium: GoogleFonts.inter(color: textSecondary),
      ),
      cardTheme: CardThemeData(
        color: surfaceLight,
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: borderLight, width: 1),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        titleTextStyle: GoogleFonts.outfit(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryBlue,
          side: const BorderSide(color: primaryBlue),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryBlue, width: 1.5),
        ),
        labelStyle: const TextStyle(color: textSecondary),
      ),
      navigationRailTheme: const NavigationRailThemeData(
        backgroundColor: Colors.white,
        selectedIconTheme: IconThemeData(color: primaryBlue),
        unselectedIconTheme: IconThemeData(color: textSecondary),
        selectedLabelTextStyle: TextStyle(color: primaryBlue, fontWeight: FontWeight.w600),
        unselectedLabelTextStyle: TextStyle(color: textSecondary),
        indicatorColor: Color(0x1F1565C0),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryBlue,
        unselectedItemColor: textSecondary,
      ),
    );
  }

  // Keep darkTheme alias pointing to lightTheme so entire app uses lightTheme
  static ThemeData get darkTheme => lightTheme;
}
