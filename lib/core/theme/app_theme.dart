import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);
    final textTheme = GoogleFonts.beVietnamProTextTheme(base.textTheme).copyWith(
      displayLarge: GoogleFonts.beVietnamPro(
        fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.textDark,
      ),
      displayMedium: GoogleFonts.beVietnamPro(
        fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.textDark,
      ),
      headlineMedium: GoogleFonts.beVietnamPro(
        fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textDark,
      ),
      titleLarge: GoogleFonts.beVietnamPro(
        fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textDark,
      ),
      titleMedium: GoogleFonts.beVietnamPro(
        fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textDark,
      ),
      bodyLarge: GoogleFonts.beVietnamPro(
        fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.textDark,
      ),
      bodyMedium: GoogleFonts.beVietnamPro(
        fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textMuted,
      ),
      labelLarge: GoogleFonts.beVietnamPro(
        fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.white,
      ),
    );

    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        onPrimary: AppColors.white,
        surface: AppColors.bg,
        onSurface: AppColors.textDark,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: AppColors.bg,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.beVietnamPro(
          fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark,
        ),
        iconTheme: const IconThemeData(color: AppColors.textDark),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.beVietnamPro(
            fontSize: 16, fontWeight: FontWeight.w600,
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          side: const BorderSide(color: AppColors.primary, width: 2),
          textStyle: GoogleFonts.beVietnamPro(
            fontSize: 16, fontWeight: FontWeight.w600,
          ),
        ),
      ),
      cardTheme: CardTheme(
        color: AppColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cream,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
      ),
    );
  }
}
