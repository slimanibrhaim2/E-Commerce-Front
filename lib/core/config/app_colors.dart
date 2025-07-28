import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF7C3AED); // Deep Purple
  static const Color primaryLight = Color(0xFF9F67FF); // Light Purple
  static const Color primaryDark = Color(0xFF6025C9); // Dark Purple
  
  // Price Section Colors
  static const Color priceGradientStart = Color(0xFF9F7AEA); // Light purple for price
  static const Color priceGradientEnd = Color(0xFFB794F6); // Even lighter purple for price

  // Secondary Colors
  static const Color secondary = Color(0xFF10B981); // Green for success/positive actions
  static const Color secondaryLight = Color(0xFF34D399);
  static const Color secondaryDark = Color(0xFF059669);

  // Accent Colors
  static const Color accent = Color(0xFFF59E0B); // Amber for highlights/warnings
  static const Color accentLight = Color(0xFFFBBF24);
  static const Color accentDark = Color(0xFFD97706);

  // Neutral Colors
  static const Color background = Colors.white;
  static const Color surface = Color(0xFFF9FAFB);
  static const Color border = Color(0xFFE5E7EB);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textDisabled = Color(0xFF9CA3AF);

  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // Navigation Bar Colors
  static const Color navBarBackground = Colors.white;
  static const Color navBarSelected = primary;
  static const Color navBarUnselected = Color(0xFF6B7280);

  // Get color scheme for MaterialApp
  static ColorScheme get colorScheme => const ColorScheme(
    primary: primary,
    primaryContainer: primaryDark,
    secondary: secondary,
    secondaryContainer: secondaryDark,
    surface: surface,
    background: background,
    error: error,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: textPrimary,
    onBackground: textPrimary,
    onError: Colors.white,
    brightness: Brightness.light,
  );
} 