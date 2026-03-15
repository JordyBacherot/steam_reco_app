import 'package:flutter/material.dart';

/// A centralized theme definition inspired by the Steam client's aesthetic.
///
/// Provides a consistent dark color palette, typography, and widget
/// styling across the entire application.
class AppTheme {
  /// The foundational dark blue/black background color.
  static const Color darkBlue = Color(0xFF171d24);
  
  /// A deeper dark blue used for backgrounds and navigation bars.
  static const Color darkerBlue = Color(0xFF0d121a);
  
  /// A lighter blue-gray used for secondary surfaces and containers.
  static const Color lightBlue = Color(0xFF1b2838);
  
  /// The primary brand color used for call-to-action buttons and accents.
  static const Color primaryBlue = Color(0xFF66c0f4);
  
  /// An alias for primaryBlue for compatibility.
  static const Color accentBlue = primaryBlue;

  /// A distinctive blue-green accent color.
  static const Color blueGreen = Color(0xFF4c6c8c);
  
  /// Pure white used for high-contrast text.
  static const Color textWhite = Color(0xFFFFFFFF);
  
  /// Standard grey color used for primary text descriptions.
  static const Color greyText = Color(0xFFb8bcbf);
  
  /// Lighter grey for less emphasized text.
  static const Color lightGreyText = Color(0xFF8f98a0);

  /// Color for card backgrounds.
  static const Color cardGrey = Color(0xFF1b2838);

  /// A gradient for header backgrounds.
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1b2838),
      Color(0xFF0d121a),
    ],
  );

  /// A more vibrant gradient for highlights.
  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.bottomLeft,
    end: Alignment.topRight,
    colors: [
      Color(0xFF171a21),
      Color(0xFF2a475e),
    ],
  );

  /// Generates the application's overall [ThemeData].
  static ThemeData get theme => darkTheme;

  /// Alias for theme to match codebase usage.
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBlue,
      primaryColor: primaryBlue,
      colorScheme: const ColorScheme.dark(
        primary: primaryBlue,
        secondary: blueGreen,
        surface: lightBlue,
        background: darkBlue,
      ),
      cardTheme: CardThemeData(
        color: cardGrey,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      
      // Configuration for text styles across the app.
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          color: textWhite,
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
        titleLarge: TextStyle(
          color: textWhite,
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
        bodyLarge: TextStyle(
          color: textWhite,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: greyText,
          fontSize: 14,
        ),
      ),

      // Consistent button styling.
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: darkBlue,
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),

      // Configuration for text input fields.
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2a3f5a),
        hintStyle: const TextStyle(color: greyText),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide.none,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: accentBlue,
          side: const BorderSide(color: accentBlue, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
