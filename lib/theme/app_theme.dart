// THEME LOCK: light — source: domain signal (consumer productivity, student-facing)
// Scaffold.backgroundColor = AppTheme.backgroundLight — ALL screens

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Primary brand colors
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryContainer = Color(0xFFEAE8FF);
  static const Color secondary = Color(0xFFFF6584);
  static const Color secondaryContainer = Color(0xFFFFE8ED);
  static const Color tertiary = Color(0xFF43D9A2);
  static const Color tertiaryContainer = Color(0xFFDCFFF4);

  // Semantic colors
  static const Color success = Color(0xFF2D7A4F);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFB91C1C);

  // Category colors for tasks
  static const Color categoryStudy = Color(0xFF6C63FF);
  static const Color categoryWorkout = Color(0xFF43D9A2);
  static const Color categoryWork = Color(0xFFFF6584);
  static const Color categoryPersonal = Color(0xFFF59E0B);
  static const Color categoryOther = Color(0xFF64B5F6);

  // Task card accent colors (cycling)
  static const List<Color> taskAccentColors = [
    Color(0xFF6C63FF),
    Color(0xFFFF6584),
    Color(0xFF43D9A2),
    Color(0xFFF59E0B),
    Color(0xFF64B5F6),
    Color(0xFFBA68C8),
  ];

  // Light theme surfaces
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color backgroundLight = Color(0xFFF8F8FF);
  static const Color surfaceVariantLight = Color(0xFFF5F4FF);

  // Dark theme surfaces
  static const Color surfaceDark = Color(0xFF1E1B2E);
  static const Color backgroundDark = Color(0xFF13111F);
  static const Color surfaceVariantDark = Color(0xFF2A2640);

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      primary: primary,
      onPrimary: Colors.white,
      primaryContainer: primaryContainer,
      onPrimaryContainer: Color(0xFF1A1060),
      secondary: secondary,
      onSecondary: Colors.white,
      secondaryContainer: secondaryContainer,
      onSecondaryContainer: Color(0xFF4A0020),
      tertiary: tertiary,
      onTertiary: Colors.white,
      surface: surfaceLight,
      onSurface: Color(0xFF1A1A1A),
      surfaceContainerHighest: surfaceVariantLight,
      onSurfaceVariant: Color(0xFF5C5C7A),
      error: error,
      onError: Colors.white,
      outline: Color(0xFFD0CFF0),
      outlineVariant: Color(0xFFEEEDFF),
    ),
    scaffoldBackgroundColor: backgroundLight,
    textTheme: GoogleFonts.plusJakartaSansTextTheme(
      const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        headlineLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.1,
        ),
        titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
        ),
        titleMedium: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
        ),
        bodySmall: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.2,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.3,
        ),
      ),
    ),
    appBarTheme: AppBarThemeData(
      backgroundColor: backgroundLight,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.plusJakartaSans(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF1A1A1A),
      ),
      iconTheme: const IconThemeData(color: Color(0xFF1A1A1A), size: 22),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: surfaceLight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: EdgeInsets.zero,
    ),
    inputDecorationTheme: InputDecorationThemeData(
      filled: true,
      fillColor: surfaceVariantLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD0CFF0), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: error, width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      labelStyle: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        color: Color(0xFF5C5C7A),
      ),
      hintStyle: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        color: Color(0xFFAAAAAA),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.plusJakartaSans(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.plusJakartaSans(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: surfaceVariantLight,
      selectedColor: primaryContainer,
      labelStyle: GoogleFonts.plusJakartaSans(
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      side: const BorderSide(color: Color(0xFFD0CFF0)),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFFEEEDFF),
      thickness: 1,
      space: 0,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: surfaceLight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 8,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: const Color(0xFF1A1A1A),
      contentTextStyle: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        color: Colors.white,
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.dark(
      primary: primary,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFF3D3580),
      onPrimaryContainer: Color(0xFFE8E6FF),
      secondary: secondary,
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFF7A2035),
      onSecondaryContainer: Color(0xFFFFE8ED),
      surface: surfaceDark,
      onSurface: Color(0xFFE6E4F0),
      surfaceContainerHighest: surfaceVariantDark,
      onSurfaceVariant: Color(0xFFAAABC8),
      error: Color(0xFFCF6679),
      onError: Colors.white,
      outline: Color(0xFF3A3850),
      outlineVariant: Color(0xFF2A2840),
    ),
    scaffoldBackgroundColor: backgroundDark,
    textTheme: GoogleFonts.plusJakartaSansTextTheme(
      const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: Color(0xFFE6E4F0),
        ),
        headlineLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: Color(0xFFE6E4F0),
        ),
        titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFFE6E4F0),
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: Color(0xFFE6E4F0),
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Color(0xFFAAABC8),
        ),
      ),
    ),
    appBarTheme: AppBarThemeData(
      backgroundColor: backgroundDark,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: GoogleFonts.plusJakartaSans(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: const Color(0xFFE6E4F0),
      ),
      iconTheme: const IconThemeData(color: Color(0xFFE6E4F0), size: 22),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: surfaceDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: EdgeInsets.zero,
    ),
  );

  // Helper: get category color
  static Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'study':
        return categoryStudy;
      case 'workout':
        return categoryWorkout;
      case 'work':
        return categoryWork;
      case 'personal':
        return categoryPersonal;
      default:
        return categoryOther;
    }
  }

  // Helper: get task accent color by index
  static Color getTaskAccentColor(int index) {
    return taskAccentColors[index % taskAccentColors.length];
  }
}