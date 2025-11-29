// lib/constants/color_constants.dart

import 'package:flutter/material.dart';

/// Your brand color palette
class AppColors {
  // Main colors
  static const Color primaryDark   = Color(0xFF1A0A2A);  // Headers, buttons, main dark background
  static const Color lightGray     = Color(0xFFF5F5F5);  // Light alternating sections

  // Accent colors
  static const Color yellow = Color(0xFFF0E68C);
  static const Color orange = Color(0xFFFF7F50);
  static const Color blue = Color(0xFF0065FF);
  static const Color green  = Color(0xFF00C49A);

  // Text colors
  static const Color textOnDark  = Colors.white;
  static const Color textOnLight = Color(0xFF1A0A2A);   // Same as primaryDark
  static const Color textMuted   = Color(0xFFAAAAAA);
}


const Color primaryColor = Color(0xFFEA6716);
const Color secondaryColor = Color(0xFFFF75BC);
const Color darkPurple = Color(0xFF2D1B69);
const Color lightPurple = Color(0xFF6C5CE7);
const Color backgroundColor = Color(0xFF1A0E3D);
const Color cardColor = Color(0xFF2A1B5C);
const Color textWhite = Color(0xFFFFFFFF);
const Color textGray = Color(0xFF8E8E93);
/// Dark theme (default for the whole app)
final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,

  // Core colors
  primaryColor: AppColors.primaryDark,
  scaffoldBackgroundColor: AppColors.primaryDark,

  // Color scheme
  colorScheme: ColorScheme.dark(
    primary: AppColors.primaryDark,
    onPrimary: AppColors.textOnDark,
    secondary: AppColors.orange,
    onSecondary: AppColors.textOnDark,
    surface: AppColors.primaryDark,
    onSurface: AppColors.textOnDark,
    background: AppColors.primaryDark,
    onBackground: AppColors.textOnDark,
  ),

  // AppBar
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.primaryDark,
    foregroundColor: AppColors.textOnDark,
    elevation: 0,
    centerTitle: true,
  ),

  // Buttons
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primaryDark,
      foregroundColor: AppColors.textOnDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  ),

  // Text theme – ensures all text is white by default on dark background
  textTheme: const TextTheme().apply(
    bodyColor: AppColors.textOnDark,
    displayColor: AppColors.textOnDark,
  ),
);

/// Light theme for cards / sections that need light background
final ThemeData lightSectionTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  scaffoldBackgroundColor: AppColors.lightGray,
  cardColor: AppColors.lightGray,
  textTheme: const TextTheme().apply(
    bodyColor: AppColors.textOnLight,
    displayColor: AppColors.textOnLight,
  ),
  colorScheme: ColorScheme.light(
    primary: AppColors.primaryDark,
    background: AppColors.lightGray,
    onBackground: AppColors.textOnLight,
  ),
);