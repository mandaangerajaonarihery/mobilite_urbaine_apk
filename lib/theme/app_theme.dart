import 'package:flutter/material.dart';
import 'colors.dart';

class AppTheme {
  /// 🌞 Thème clair
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.backgroundLight,
    primaryColor: AppColors.successLight, // 🌱 vert prioritaire

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryLight,
      ),
      iconTheme: IconThemeData(color: AppColors.successLight),
    ),

    textTheme: const TextTheme(
      displayLarge: TextStyle( // H1
        fontFamily: 'Manrope',
        fontSize: 32,
        fontWeight: FontWeight.w800, // ExtraBold
        color: AppColors.textPrimaryLight,
      ),
      headlineMedium: TextStyle( // H2
        fontFamily: 'Manrope',
        fontSize: 24,
        fontWeight: FontWeight.w800,
        color: AppColors.textSecondaryLight,
      ),
      bodyLarge: TextStyle( // Paragraphe principal
        fontFamily: 'Manrope',
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimaryLight,
      ),
      bodyMedium: TextStyle( // Paragraphe secondaire
        fontFamily: 'Manrope',
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.paragraphLight,
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.buttonNormal, // bouton vert
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontFamily: 'Manrope',
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),

    colorScheme: ColorScheme.light(
      primary: AppColors.successLight,
      secondary: AppColors.accentOrange,
      error: AppColors.errorLight,
      surface: AppColors.cardLight,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onError: Colors.white,
      onSurface: AppColors.textPrimaryLight,
    ),
  );

  /// 🌙 Thème sombre
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.backgroundDark,
    primaryColor: AppColors.successDark, // 🌱 vert prioritaire aussi en sombre

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      iconTheme: IconThemeData(color: AppColors.successDark),
    ),

    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontFamily: 'Manrope',
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimaryDark,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'Manrope',
        fontSize: 24,
        fontWeight: FontWeight.w800,
        color: AppColors.textSecondaryDark,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'Manrope',
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimaryDark,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Manrope',
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.successDark,
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.successDark,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontFamily: 'Manrope',
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),

    colorScheme: ColorScheme.dark(
      primary: AppColors.successDark,
      secondary: AppColors.accentOrange,
      error: AppColors.errorDark,
      surface: AppColors.cardDark,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onError: Colors.white,
      onSurface: AppColors.textPrimaryDark,
    ),
  );
}
