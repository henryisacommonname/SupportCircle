import 'package:flutter/material.dart';

/// ============================================================================
/// APP THEMES CONFIGURATION
/// ============================================================================
/// This is the centralized location for all theme definitions in SupportCircle.
///
/// TO ADD A NEW THEME:
/// 1. Create a new AppThemeConfig instance in the `allThemes` list below
/// 2. Define your colors (primary, secondary, tertiary, etc.)
/// 3. Set unlock requirements (hoursRequired, or null for always available)
/// 4. The theme will automatically appear in the theme selector
///
/// TO MODIFY EXISTING THEME COLORS:
/// Simply update the color values in the corresponding AppThemeConfig below.
/// ============================================================================

/// Configuration for a single app theme
class AppThemeConfig {
  /// Unique identifier for this theme (stored in Firestore)
  final String id;

  /// Display name shown to users
  final String name;

  /// Short description of the theme
  final String description;

  /// Icon to represent this theme in the selector
  final IconData icon;

  /// Whether this is a dark theme
  final bool isDark;

  /// Hours required to unlock (null = always available)
  final int? hoursRequired;

  // ---- Core Colors ----
  final Color primary;
  final Color secondary;
  final Color tertiary;

  // ---- Surface Colors ----
  final Color surface;
  final Color card;

  // ---- Semantic Colors (optional overrides) ----
  final Color? success;
  final Color? warning;
  final Color? error;
  final Color? info;

  const AppThemeConfig({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.isDark,
    this.hoursRequired,
    required this.primary,
    required this.secondary,
    required this.tertiary,
    required this.surface,
    required this.card,
    this.success,
    this.warning,
    this.error,
    this.info,
  });

  /// Check if this theme is unlocked for a given number of hours
  bool isUnlocked(double totalHours) {
    if (hoursRequired == null) return true;
    return totalHours >= hoursRequired!;
  }
}

/// ============================================================================
/// THEME DEFINITIONS
/// ============================================================================
/// Add, remove, or modify themes here. Each theme needs a unique [id].
/// ============================================================================

class AppThemes {
  AppThemes._();

  // --------------------------------------------------------------------------
  // LIGHT THEME (Default)
  // --------------------------------------------------------------------------
  static const light = AppThemeConfig(
    id: 'light',
    name: 'Light',
    description: 'Clean and bright default theme',
    icon: Icons.light_mode,
    isDark: false,
    hoursRequired: null, // Always available
    primary: Color(0xFF4169E1),   // Royal Blue
    secondary: Color(0xFF7C4DFF), // Purple accent
    tertiary: Color(0xFF536DFE),  // Indigo accent
    surface: Color(0xFFF8F9FC),
    card: Colors.white,
  );

  // --------------------------------------------------------------------------
  // DARK THEME
  // --------------------------------------------------------------------------
  static const dark = AppThemeConfig(
    id: 'dark',
    name: 'Dark',
    description: 'Easy on the eyes in low light',
    icon: Icons.dark_mode,
    isDark: true,
    hoursRequired: null, // Always available
    primary: Color(0xFF4169E1),   // Royal Blue
    secondary: Color(0xFF7C4DFF), // Purple accent
    tertiary: Color(0xFF536DFE),  // Indigo accent
    surface: Color(0xFF0D1117),
    card: Color(0xFF161B22),
  );

  // --------------------------------------------------------------------------
  // RETROWAVE THEME (Unlockable)
  // --------------------------------------------------------------------------
  static const retrowave = AppThemeConfig(
    id: 'retrowave',
    name: 'Retrowave',
    description: 'Neon synthwave vibes',
    icon: Icons.auto_awesome,
    isDark: true,
    hoursRequired: null, // Set to e.g., 25 to require 25 hours to unlock
    primary: Color(0xFFFF006E),   // Hot pink
    secondary: Color(0xFF00F5D4), // Cyan
    tertiary: Color(0xFFB388FF),  // Lavender
    surface: Color(0xFF0A0A1A),   // Deep dark blue
    card: Color(0xFF1A1A2E),      // Dark purple-blue
    success: Color(0xFF00F5D4),   // Cyan
    warning: Color(0xFFFFBE0B),   // Bright yellow
    error: Color(0xFFFF006E),     // Hot pink
    info: Color(0xFF8338EC),      // Purple
  );

  // --------------------------------------------------------------------------
  // ADD NEW THEMES HERE
  // --------------------------------------------------------------------------
  // Example:
  // static const ocean = AppThemeConfig(
  //   id: 'ocean',
  //   name: 'Ocean',
  //   description: 'Calm and serene aquatic theme',
  //   icon: Icons.water,
  //   isDark: false,
  //   hoursRequired: 50,
  //   primary: Color(0xFF0077B6),
  //   secondary: Color(0xFF00B4D8),
  //   tertiary: Color(0xFF90E0EF),
  //   surface: Color(0xFFF0F8FF),
  //   card: Colors.white,
  // );

  /// All available themes in the app
  /// Add new themes to this list to make them available
  static const List<AppThemeConfig> allThemes = [
    light,
    dark,
    retrowave,
    // Add new themes here:
    // ocean,
    // forest,
    // sunset,
  ];

  /// Get a theme by its ID
  static AppThemeConfig? getById(String id) {
    try {
      return allThemes.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Get all themes unlocked for a given number of hours
  static List<AppThemeConfig> getUnlockedThemes(double totalHours) {
    return allThemes.where((t) => t.isUnlocked(totalHours)).toList();
  }

  /// Default theme ID
  static const String defaultThemeId = 'light';

  // --------------------------------------------------------------------------
  // SHARED SEMANTIC COLORS
  // --------------------------------------------------------------------------
  // These are used across all themes unless overridden in AppThemeConfig
  static const Color defaultSuccess = Color(0xFF4CAF50);
  static const Color defaultWarning = Color(0xFFFF9800);
  static const Color defaultError = Color(0xFFF44336);
  static const Color defaultInfo = Color(0xFF2196F3);

  // --------------------------------------------------------------------------
  // STATUS BADGE COLORS (for training modules, etc.)
  // --------------------------------------------------------------------------
  static const Color statusNotStarted = Color(0xFF9E9E9E);
  static const Color statusInProgress = Color(0xFFFF9800);
  static const Color statusCompleted = Color(0xFF4CAF50);
}

/// ============================================================================
/// THEME DATA BUILDER
/// ============================================================================
/// Converts an AppThemeConfig into a Flutter ThemeData object.
/// ============================================================================

class AppThemeBuilder {
  AppThemeBuilder._();

  /// Build a ThemeData from an AppThemeConfig
  static ThemeData build(AppThemeConfig config) {
    final isDark = config.isDark;
    final brightness = isDark ? Brightness.dark : Brightness.light;

    // Semantic colors (use theme overrides or defaults)
    final success = config.success ?? AppThemes.defaultSuccess;
    final warning = config.warning ?? AppThemes.defaultWarning;
    final error = config.error ?? AppThemes.defaultError;

    // Grey shades based on brightness
    final greyLight = isDark ? Colors.grey.shade800 : Colors.grey.shade200;
    final greyMedium = isDark ? Colors.grey.shade700 : Colors.grey.shade300;
    final greyDark = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final inputFill = isDark ? Colors.grey.shade900 : Colors.grey.shade100;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: config.primary,
        brightness: brightness,
        secondary: config.secondary,
        tertiary: config.tertiary,
        surface: config.surface,
        error: error,
      ),
      scaffoldBackgroundColor: config.surface,
      cardTheme: CardThemeData(
        elevation: 0,
        color: config.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: greyLight),
        ),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : Colors.black87,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        elevation: 8,
        backgroundColor: config.card,
        selectedItemColor: config.primary,
        unselectedItemColor: greyDark,
        type: BottomNavigationBarType.fixed,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: config.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
        selectedColor: config.primary.withAlpha(isDark ? 77 : 51),
        labelStyle: const TextStyle(fontSize: 12),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: greyLight,
        thickness: 1,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.25,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(fontSize: 16),
        bodyMedium: TextStyle(fontSize: 14),
        bodySmall: TextStyle(fontSize: 12),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
