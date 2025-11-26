import 'package:flutter/material.dart';

class AppColors {
  static const Color richBlack = Color(0xFF0B1521);
  static const Color saltWhite = Color(0xFFF7FAFC);
  static const Color electricIndigo = Color(0xFF6931F4);
  static const Color ionGreen = Color(0xFF00FF00);
  static const Color skyBlue = Color(0xFF87CEEB);
  static const Color quantumPink = Color(0xFFFF1493);
  static const Color helioYellow = Color(0xFFF3CF25);
  static const Color emberOrange = Color(0xFFF46A1E);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Strawford',
      colorScheme: ColorScheme.light(
        primary: AppColors.electricIndigo,
        secondary: AppColors.ionGreen,
        // surface: AppColors.saltWhite,
        surface: Colors.white70,
        error: AppColors.quantumPink,
      ),
      scaffoldBackgroundColor: AppColors.saltWhite,
      appBarTheme: const AppBarTheme(
        // backgroundColor: AppColors.richBlack,
        backgroundColor: Colors.white70,
        foregroundColor: AppColors.emberOrange,
        titleTextStyle: TextStyle(
          fontFamily: 'Strawford',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.emberOrange,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.richBlack,
        selectedItemColor: AppColors.helioYellow,
        unselectedItemColor: AppColors.saltWhite,
        selectedLabelStyle: TextStyle(
          fontFamily: 'Strawford',
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: 'Strawford',
          fontWeight: FontWeight.w400,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.electricIndigo,
        foregroundColor: AppColors.saltWhite,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontFamily: 'Strawford', fontWeight: FontWeight.w300),
        displayMedium: TextStyle(fontFamily: 'Strawford', fontWeight: FontWeight.w400),
        displaySmall: TextStyle(fontFamily: 'Strawford', fontWeight: FontWeight.w400),
        headlineLarge: TextStyle(fontFamily: 'Strawford', fontWeight: FontWeight.w700),
        headlineMedium: TextStyle(fontFamily: 'Strawford', fontWeight: FontWeight.w600),
        headlineSmall: TextStyle(fontFamily: 'Strawford', fontWeight: FontWeight.w500),
        titleLarge: TextStyle(fontFamily: 'Strawford', fontWeight: FontWeight.w600),
        titleMedium: TextStyle(fontFamily: 'Strawford', fontWeight: FontWeight.w500),
        titleSmall: TextStyle(fontFamily: 'Strawford', fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(fontFamily: 'Strawford', fontWeight: FontWeight.w400),
        bodyMedium: TextStyle(fontFamily: 'Strawford', fontWeight: FontWeight.w400),
        bodySmall: TextStyle(fontFamily: 'Strawford', fontWeight: FontWeight.w400),
        labelLarge: TextStyle(fontFamily: 'Strawford', fontWeight: FontWeight.w500),
        labelMedium: TextStyle(fontFamily: 'Strawford', fontWeight: FontWeight.w500),
        labelSmall: TextStyle(fontFamily: 'Strawford', fontWeight: FontWeight.w400),
      ),
    );
  }
} 