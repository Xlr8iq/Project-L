import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color backgroundDark = Color(0xFF0F172A); // Deep slate
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color accentCyan = Color(0xFF06B6D4);
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);

  // Charting Colors
  static const Color toothNormal = Color(0xFFE2E8F0);
  static const Color chartRestoration = Color(0xFF3B82F6); // Blue
  static const Color chartExtraction = Color(0xFFEF4444);  // Red
  static const Color chartEndo = Color(0xFF10B981);        // Green
  static const Color chartImplant = Color(0xFF8B5CF6);     // Purple

  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: backgroundDark,
      primaryColor: accentCyan,
      colorScheme: const ColorScheme.dark().copyWith(
        primary: accentCyan,
        surface: surfaceDark,
        onSurface: textPrimary,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.outfit(color: textPrimary, fontWeight: FontWeight.bold),
        headlineMedium: GoogleFonts.outfit(color: textPrimary, fontWeight: FontWeight.w600),
        titleLarge: GoogleFonts.inter(color: textPrimary, fontWeight: FontWeight.w600),
        bodyLarge: GoogleFonts.inter(color: textPrimary),
        bodyMedium: GoogleFonts.inter(color: textSecondary),
      ),
      cardTheme: CardThemeData(
        color: surfaceDark,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundDark,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.outfit(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(color: accentCyan),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceDark,
        selectedItemColor: accentCyan,
        unselectedItemColor: textSecondary,
      ),
    );
  }
}
