import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF006994);
  static const Color primaryLight = Color(0xFF00B4D8);
  static const Color primaryDark = Color(0xFF004E6E);
  static const Color accent = Color(0xFF48CAE4);
  static const Color background = Color(0xFFF0F8FF);
  static const Color cardBg = Colors.white;
  static const Color fresh = Color(0xFF2E7D32);
  static const Color freshLight = Color(0xFFE8F5E9);
  static const Color nonFresh = Color(0xFFC62828);
  static const Color nonFreshLight = Color(0xFFFFEBEE);
  static const Color warning = Color(0xFFF9A825);
  static const Color warningLight = Color(0xFFFFFDE7);
  static const Color textDark = Color(0xFF1A237E);
  static const Color textGrey = Color(0xFF607D8B);
  static const Color divider = Color(0xFFECEFF1);
}

class AppTheme {
  static ThemeData get theme => ThemeData(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.primaryLight,
          surface: AppColors.background,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.divider),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.divider),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 2,
          shadowColor: Colors.black12,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        useMaterial3: false,
      );
}