import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_study_planner/theme/app_colors.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    colorScheme: const ColorScheme.light(
      primary: AppColors.primaryOlive,
      secondary: AppColors.secondaryYellow,
      tertiary: AppColors.accentOrange,
      surface: AppColors.softSurface,
      onPrimary: AppColors.deepBrown,
      onSecondary: AppColors.deepBrown,
      onSurface: AppColors.deepBrown,
    ),
    scaffoldBackgroundColor: AppColors.creamBackground,
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: <TargetPlatform, PageTransitionsBuilder>{
        TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
    textTheme: GoogleFonts.poppinsTextTheme().apply(
      bodyColor: AppColors.deepBrown,
      displayColor: AppColors.deepBrown,
    ),
    iconTheme: const IconThemeData(color: AppColors.deepBrown),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.creamBackground,
      foregroundColor: AppColors.deepBrown,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.poppins(
        color: AppColors.deepBrown,
        fontWeight: FontWeight.w700,
        fontSize: 20,
      ),
    ),
    useMaterial3: true,
    cardTheme: CardThemeData(
      color: AppColors.softSurface,
      elevation: 2,
      shadowColor: AppColors.deepBrown.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.softSurface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      labelStyle: const TextStyle(color: AppColors.deepBrown),
      hintStyle: TextStyle(color: AppColors.deepBrown.withValues(alpha: 0.65)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: AppColors.primaryOlive, width: 1.5),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0.5,
        backgroundColor: AppColors.secondaryYellow,
        foregroundColor: AppColors.deepBrown,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.deepBrown,
        side: const BorderSide(color: AppColors.primaryOlive),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: AppColors.deepBrown),
    ),
  );
}
