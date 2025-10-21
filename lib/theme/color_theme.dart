// lib/theme/color_theme.dart
import 'package:flutter/material.dart';

/// Color theme class yang sesuai dengan desain web CSS global
class AppColorTheme {
  // Private constructor
  AppColorTheme._();

  // Base Colors (from CSS variables)
  static const Color background = Color(0xFFFFFFFF); // --background: 0 0% 100%
  static const Color foreground = Color(
    0xFF0F172A,
  ); // --foreground: 222.2 84% 4.9%
  static const Color card = Color(0xFFFFFFFF); // --card: 0 0% 100%
  static const Color cardForeground = Color(
    0xFF0F172A,
  ); // --card-foreground: 222.2 84% 4.9%
  static const Color popover = Color(0xFFFFFFFF); // --popover: 0 0% 100%
  static const Color popoverForeground = Color(
    0xFF0F172A,
  ); // --popover-foreground: 222.2 84% 4.9%

  // Primary Colors
  static const Color primary = Color(0xFF3B82F6); // --primary: 217 91% 60%
  static const Color primaryForeground = Color(
    0xFFFAFAFC,
  ); // --primary-foreground: 210 40% 98%

  // Secondary Colors
  static const Color secondary = Color(0xFFF1F5F9); // --secondary: 210 40% 96%
  static const Color secondaryForeground = Color(
    0xFF0F172A,
  ); // --secondary-foreground: 222.2 84% 4.9%

  // Muted Colors
  static const Color muted = Color(0xFFF1F5F9); // --muted: 210 40% 96%
  static const Color mutedForeground = Color(
    0xFF64748B,
  ); // --muted-foreground: 215.4 16.3% 46.9%

  // Accent Colors
  static const Color accent = Color(0xFFF0F9FF); // --accent: 217 100% 97%
  static const Color accentForeground = Color(
    0xFF3B82F6,
  ); // --accent-foreground: 217 91% 60%

  // Destructive Colors
  static const Color destructive = Color(
    0xFFEF4444,
  ); // --destructive: 0 84.2% 60.2%
  static const Color destructiveForeground = Color(
    0xFFFAFAFC,
  ); // --destructive-foreground: 210 40% 98%

  // Border & Input Colors
  static const Color border = Color(0xFFE2E8F0); // --border: 214.3 31.8% 91.4%
  static const Color input = Color(0xFFE2E8F0); // --input: 214.3 31.8% 91.4%
  static const Color ring = Color(0xFF3B82F6); // --ring: 217 91% 60%

  // Blue Color Palette (sesuai dengan CSS variables)
  static const Map<int, Color> blueColors = {
    50: Color(0xFFF0F9FF), // --blue-50: 239 100% 97%
    100: Color(0xFFE0F2FE), // --blue-100: 219 100% 95%
    200: Color(0xFFBAE6FD), // --blue-200: 213 97% 87%
    300: Color(0xFF7DD3FC), // --blue-300: 212 96% 78%
    400: Color(0xFF38BDF8), // --blue-400: 213 94% 68%
    500: Color(0xFF3B82F6), // --blue-500: 217 91% 60%
    600: Color(0xFF2563EB), // --blue-600: 221 83% 53%
    700: Color(0xFF1D4ED8), // --blue-700: 224 76% 48%
    800: Color(0xFF1E40AF), // --blue-800: 226 71% 40%
    900: Color(0xFF1E3A8A), // --blue-900: 224 64% 33%
  };

  // Purple Color Palette (sesuai dengan CSS variables)
  static const Map<int, Color> purpleColors = {
    50: Color(0xFFFAF5FF), // --purple-50: 250 100% 98%
    100: Color(0xFFF3E8FF), // --purple-100: 243 100% 96%
    200: Color(0xFFE9D5FF), // --purple-200: 239 84% 92%
    300: Color(0xFFD8B4FE), // --purple-300: 237 79% 85%
    400: Color(0xFFC084FC), // --purple-400: 236 72% 75%
    500: Color(0xFFA855F7), // --purple-500: 236 72% 64%
    600: Color(0xFF9333EA), // --purple-600: 237 74% 54%
    700: Color(0xFF7C3AED), // --purple-700: 238 77% 46%
    800: Color(0xFF6B21A8), // --purple-800: 239 77% 38%
    900: Color(0xFF581C87), // --purple-900: 240 75% 31%
  };

  // Gradient Colors untuk background (sesuai dengan CSS gradient classes)
  static const List<Color> primaryGradient = [
    Color(0xFFF0F9FF), // blue-50
    Color(0xFFE0F2FE), // blue-100
    Color(0xFFFAF5FF), // purple-50
    Color(0xFFFFFFFF), // white dengan opacity
    Color(0xFFFAF5FF), // purple-50
    Color(0xFFE0F2FE), // blue-100
    Color(0xFFF0F9FF), // blue-50
  ];

  static const List<Color> reverseGradient = [
    Color(0xFFF0F9FF), // blue-50 (reverse order)
    Color(0xFFE0F2FE), // blue-100
    Color(0xFFFAF5FF), // purple-50
    Color(0xFFFFFFFF), // white
    Color(0xFFFAF5FF), // purple-50
    Color(0xFFE0F2FE), // blue-100
    Color(0xFFF0F9FF), // blue-50
  ];

  static const List<Color> altGradient = [
    Color(0xFFFAF5FF), // purple-50
    Color(0xFFF0F9FF), // blue-50
    Color(0xFFFFFFFF), // white
    Color(0xFFE0F2FE), // blue-100
    Color(0xFFF3E8FF), // purple-100
    Color(0xFFFAF5FF), // purple-50
  ];

  // Hero text gradient colors
  static const List<Color> heroTextGradient = [
    Color(0xFF2563EB), // blue-600
    Color(0xFF3B82F6), // blue-500
    Color(0xFFA855F7), // purple-500
    Color(0xFF38BDF8), // blue-400
  ];

  // Glassmorphism effect colors
  static const Color glassBackground = Color(
    0xCCFFFFFF,
  ); // rgba(255, 255, 255, 0.8)
  static const Color glassBorder = Color(
    0x4DD1D5DB,
  ); // rgba(209, 213, 219, 0.3)

  // Shadow colors untuk elevated components
  static const Color blueShadow = Color(
    0x4D3B82F6,
  ); // blue-500 dengan opacity 0.3
  static const Color purpleShadow = Color(
    0x4DA855F7,
  ); // purple-500 dengan opacity 0.3

  // Button specific colors
  static const List<Color> primaryButtonGradient = [
    Color(0xFF3B82F6), // blue-500
    Color(0xFF2563EB), // blue-600
  ];

  static const Color secondaryButtonBackground = Color(
    0xB3FFFFFF,
  ); // rgba(255, 255, 255, 0.7)
  static const Color secondaryButtonBorder = Color(0xFFBAE6FD); // blue-200
  static const Color secondaryButtonText = Color(0xFF1D4ED8); // blue-700
  static const Color secondaryButtonHover = Color(0xFFF0F9FF); // blue-50

  // Input field colors
  static const Color inputBackground = Color(
    0xCCFFFFFF,
  ); // rgba(255, 255, 255, 0.8)
  static const Color inputFocusBackground = Color(
    0xF2FFFFFF,
  ); // rgba(255, 255, 255, 0.95)
  static const Color inputFocusBorder = Color(0xFF3B82F6); // blue-500
  static const Color inputPlaceholder = Color(0xFF64748B); // muted-foreground

  // Card colors dengan glassmorphism effect
  static const Color cardBackground = Color(
    0xD9FFFFFF,
  ); // rgba(255, 255, 255, 0.85)
  static const Color cardHoverBackground = Color(
    0xF2FFFFFF,
  ); // rgba(255, 255, 255, 0.95)

  // Status colors
  static const Color success = Color(0xFF10B981); // emerald-500
  static const Color warning = Color(0xFFF59E0B); // amber-500
  static const Color error = Color(0xFFEF4444); // red-500
  static const Color info = Color(0xFF3B82F6); // blue-500

  // Helper methods untuk membuat gradients
  static LinearGradient get primaryLinearGradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: primaryButtonGradient,
  );

  static LinearGradient get heroTextLinearGradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: heroTextGradient,
  );

  static LinearGradient get backgroundLinearGradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: primaryGradient,
    stops: [0.0, 0.15, 0.35, 0.5, 0.65, 0.85, 1.0],
  );

  static LinearGradient get reverseBackgroundLinearGradient =>
      const LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: reverseGradient,
        stops: [0.0, 0.15, 0.35, 0.5, 0.65, 0.85, 1.0],
      );

  static RadialGradient get glowEffect => RadialGradient(
    colors: [blueColors[500]!.withOpacity(0.15), Colors.transparent],
    radius: 0.5,
  );

  // Method untuk mendapatkan warna berdasarkan brightness (tidak diperlukan karena light theme only)
  // Bisa digunakan untuk konsistensi API jika nanti butuh adaptasi
  static Color getColor(Color color) => color;

  // Method untuk membuat theme data Flutter (light theme only)
  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: primary,
      onPrimary: primaryForeground,
      secondary: secondary,
      onSecondary: secondaryForeground,
      surface: background,
      onSurface: foreground,
      error: destructive,
      onError: destructiveForeground,
      outline: border,
    ),
    scaffoldBackgroundColor: background,
    cardColor: card,
    dividerColor: border,
    fontFamily: 'Inter',
  );
}
