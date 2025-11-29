/// App Theme
/// 
/// Defines the visual styling for the SignBridge application.
/// Includes color schemes, typography, and component themes.

import 'package:flutter/material.dart';

/// App color scheme
class AppColors {
  // Primary colors
  static const Color primary = Color(0xFF2196F3); // Blue
  static const Color primaryDark = Color(0xFF1976D2);
  static const Color primaryLight = Color(0xFF64B5F6);
  
  // Secondary colors
  static const Color secondary = Color(0xFF4CAF50); // Green
  static const Color secondaryDark = Color(0xFF388E3C);
  static const Color secondaryLight = Color(0xFF81C784);
  
  // Accent colors
  static const Color accent = Color(0xFFFF9800); // Orange
  static const Color accentDark = Color(0xFFF57C00);
  static const Color accentLight = Color(0xFFFFB74D);
  
  // Neutral colors
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF424242);
  
  // Text colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFF9E9E9E);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  
  // Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  
  // Confidence indicator colors
  static const Color confidenceVeryHigh = Color(0xFF4CAF50); // Green
  static const Color confidenceHigh = Color(0xFF8BC34A); // Light green
  static const Color confidenceMedium = Color(0xFFFF9800); // Orange
  static const Color confidenceLow = Color(0xFFFF5722); // Deep orange
  static const Color confidenceVeryLow = Color(0xFFF44336); // Red
  
  // Processing source colors
  static const Color localProcessing = Color(0xFF4CAF50); // Green
  static const Color cloudProcessing = Color(0xFF2196F3); // Blue
  static const Color fallbackProcessing = Color(0xFFFF9800); // Orange
}

/// App theme
class AppTheme {
  /// Light theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      // Color scheme
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        primaryContainer: AppColors.primaryLight,
        secondary: AppColors.secondary,
        secondaryContainer: AppColors.secondaryLight,
        surface: AppColors.surface,
        background: AppColors.background,
        error: AppColors.error,
        onPrimary: AppColors.textOnPrimary,
        onSecondary: AppColors.textOnPrimary,
        onSurface: AppColors.textPrimary,
        onBackground: AppColors.textPrimary,
        onError: AppColors.textOnPrimary,
      ),
      
      // App bar theme
      appBarTheme: AppBarTheme(
        elevation: 2,
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textOnPrimary,
        ),
      ),
      
      // Card theme
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: EdgeInsets.all(8),
      ),
      
      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Floating action button theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 4,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
      ),
      
      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.textHint),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.textHint),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.error),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      
      // Text theme
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: 96,
          fontWeight: FontWeight.w300,
          color: AppColors.textPrimary,
        ),
        displayMedium: TextStyle(
          fontSize: 60,
          fontWeight: FontWeight.w300,
          color: AppColors.textPrimary,
        ),
        displaySmall: TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
        ),
        headlineLarge: TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
        ),
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
        ),
      ),
      
      // Icon theme
      iconTheme: IconThemeData(
        color: AppColors.textPrimary,
        size: 24,
      ),
      
      // Divider theme
      dividerTheme: DividerThemeData(
        color: AppColors.textHint,
        thickness: 1,
        space: 16,
      ),
    );
  }
  
  /// Dark theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      
      // Color scheme
      colorScheme: ColorScheme.dark(
        primary: AppColors.primaryLight,
        primaryContainer: AppColors.primaryDark,
        secondary: AppColors.secondaryLight,
        secondaryContainer: AppColors.secondaryDark,
        surface: AppColors.surfaceDark,
        background: Color(0xFF121212),
        error: AppColors.error,
        onPrimary: AppColors.textPrimary,
        onSecondary: AppColors.textPrimary,
        onSurface: AppColors.textOnPrimary,
        onBackground: AppColors.textOnPrimary,
        onError: AppColors.textOnPrimary,
      ),
      
      // App bar theme
      appBarTheme: AppBarTheme(
        elevation: 2,
        centerTitle: true,
        backgroundColor: AppColors.surfaceDark,
        foregroundColor: AppColors.textOnPrimary,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textOnPrimary,
        ),
      ),
      
      // Card theme
      cardTheme: CardTheme(
        elevation: 2,
        color: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: EdgeInsets.all(8),
      ),
      
      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Floating action button theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 4,
        backgroundColor: AppColors.primaryLight,
        foregroundColor: AppColors.textPrimary,
      ),
      
      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.textHint),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.textHint),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primaryLight, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.error),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      
      // Icon theme
      iconTheme: IconThemeData(
        color: AppColors.textOnPrimary,
        size: 24,
      ),
      
      // Divider theme
      dividerTheme: DividerThemeData(
        color: AppColors.textHint,
        thickness: 1,
        space: 16,
      ),
    );
  }
  
  /// Get confidence color based on value
  static Color getConfidenceColor(double confidence) {
    if (confidence >= 0.85) {
      return AppColors.confidenceVeryHigh;
    } else if (confidence >= 0.75) {
      return AppColors.confidenceHigh;
    } else if (confidence >= 0.60) {
      return AppColors.confidenceMedium;
    } else if (confidence >= 0.45) {
      return AppColors.confidenceLow;
    } else {
      return AppColors.confidenceVeryLow;
    }
  }
  
  /// Get processing source color
  static Color getProcessingSourceColor(ProcessingSource source) {
    switch (source) {
      case ProcessingSource.local:
        return AppColors.localProcessing;
      case ProcessingSource.cloud:
        return AppColors.cloudProcessing;
      case ProcessingSource.localFallback:
        return AppColors.fallbackProcessing;
    }
  }
}

/// Processing source enum (for color mapping)
enum ProcessingSource {
  local,
  cloud,
  localFallback,
}