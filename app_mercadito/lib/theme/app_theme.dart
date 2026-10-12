import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/sound_service.dart';

class AppTheme {
  // ==========================================
  // TOKENS MODO DÍA (según Modo dia y noche.md)
  // ==========================================
  static const Color lightBackground = Color(0xFFF7F9F8);
  static const Color lightSecondaryBackground = Color(0xFFEEF5F1);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightCardElevated = Color(0xFFFFFFFF);
  static const Color lightPrimary = Color(0xFF016042);
  static const Color lightPrimaryCta = Color(0xFF016042);
  static const Color lightPrimaryLight = Color(0xFFE5F0EB);
  static const Color lightTextPrimary = Color(0xFF20262B);
  static const Color lightTextSecondary = Color(0xFF697177);
  static const Color lightTextTertiary = Color(0xFF9AA2A7);
  static const Color lightBorder = Color(0xFFE2E7E4);
  static const Color lightInput = Color(0xFFE8F2ED);
  static const Color lightIcon = Color(0xFF52615B);
  static const Color lightWhite = Color(0xFFFFFFFF);

  // ==========================================
  // TOKENS MODO NOCHE (según Modo dia y noche.md)
  // ==========================================
  static const Color darkBackground = Color(0xFF101815);
  static const Color darkSecondaryBackground = Color(0xFF17221E);
  static const Color darkCard = Color(0xFF1C2924);
  static const Color darkCardElevated = Color(0xFF22332C);
  static const Color darkPrimary = Color(0xFF67C83B);
  static const Color darkPrimaryCta = Color(0xFF2F7D59);
  static const Color darkPrimaryLight = Color(0xFF203D31);
  static const Color darkTextPrimary = Color(0xFFF1F5F3);
  static const Color darkTextSecondary = Color(0xFFAAB8B1);
  static const Color darkTextTertiary = Color(0xFF718078);
  static const Color darkBorder = Color(0xFF2B3A34);
  static const Color darkInput = Color(0xFF1C3028);
  static const Color darkIcon = Color(0xFFA7B8B0);
  static const Color darkWhite = Color(0xFFF1F5F3);

  // ==========================================
  // COLORES FUNCIONALES (Modo Noche adaptados)
  // ==========================================
  static const Color functionalSuccess = Color(0xFF67C83B);
  static const Color functionalOffer = Color(0xFFF5A623);
  static const Color functionalDiscount = Color(0xFFFFB340);
  static const Color functionalError = Color(0xFFFF6B6B);
  static const Color functionalInfo = Color(0xFF58A6FF);
  static const Color functionalFavorite = Color(0xFFFF6B81);

  // ==========================================
  // BRAND & LEGACY SLATE COLORS (compatibilidad)
  // ==========================================
  static const Color primary = Color(0xFF016042);
  static const Color primaryLight = Color(0xFF1E8262);
  static const Color backgroundLight = Color(0xFFF7F9F8);
  static const Color backgroundDark = Color(0xFF101815);
  static const Color slate50 = Color(0xFFF8FAFC);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate900 = Color(0xFF0F172A);

  // ==========================================
  // HELPERS DINÁMICOS SEGÚN EL TEMA
  // ==========================================
  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color getBackgroundColor(BuildContext context) =>
      isDark(context) ? darkBackground : lightBackground;

  static Color getSecondaryBackgroundColor(BuildContext context) =>
      isDark(context) ? darkSecondaryBackground : lightSecondaryBackground;

  static Color getCardColor(BuildContext context) =>
      isDark(context) ? darkCard : lightCard;

  static Color getElevatedCardColor(BuildContext context) =>
      isDark(context) ? darkCardElevated : lightCardElevated;

  static Color getPrimaryColor(BuildContext context) =>
      isDark(context) ? darkPrimary : lightPrimary;

  static Color getPrimaryCtaColor(BuildContext context) =>
      isDark(context) ? darkPrimaryCta : lightPrimaryCta;

  static Color getTextColor(BuildContext context) =>
      isDark(context) ? darkTextPrimary : lightTextPrimary;

  static Color getSecondaryTextColor(BuildContext context) =>
      isDark(context) ? darkTextSecondary : lightTextSecondary;

  static Color getTertiaryTextColor(BuildContext context) =>
      isDark(context) ? darkTextTertiary : lightTextTertiary;

  static Color getBorderColor(BuildContext context) =>
      isDark(context) ? darkBorder : lightBorder;

  static Color getInputColor(BuildContext context) =>
      isDark(context) ? darkInput : lightInput;

  static Color getIconColor(BuildContext context) =>
      isDark(context) ? darkIcon : lightIcon;

  // ==========================================
  // LIGHT THEME CONFIGURATION
  // ==========================================
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      splashFactory: const SoundFeedbackSplashFactory(),
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: lightPrimary,
        onPrimary: Colors.white,
        primaryContainer: lightPrimaryLight,
        onPrimaryContainer: lightPrimary,
        secondary: lightPrimaryCta,
        onSecondary: Colors.white,
        surface: lightCard,
        onSurface: lightTextPrimary,
        surfaceContainerHighest: lightCardElevated,
        outline: lightBorder,
        error: Color(0xFFDC2626),
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: lightBackground,
      cardColor: lightCard,
      cardTheme: const CardThemeData(
        color: lightCard,
        elevation: 0,
        margin: EdgeInsets.zero,
      ),
      dividerColor: lightBorder,
      dividerTheme: const DividerThemeData(
        color: lightBorder,
        thickness: 1,
      ),
      iconTheme: const IconThemeData(
        color: lightIcon,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: lightBackground,
        foregroundColor: lightTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: lightPrimary,
        unselectedItemColor: lightTextTertiary,
      ),
      textTheme: GoogleFonts.plusJakartaSansTextTheme().copyWith(
        displayLarge: GoogleFonts.plusJakartaSans(color: lightTextPrimary, fontWeight: FontWeight.bold),
        titleLarge: GoogleFonts.plusJakartaSans(color: lightTextPrimary, fontWeight: FontWeight.bold),
        titleMedium: GoogleFonts.plusJakartaSans(color: lightTextPrimary, fontWeight: FontWeight.w600),
        bodyLarge: GoogleFonts.plusJakartaSans(color: lightTextPrimary),
        bodyMedium: GoogleFonts.plusJakartaSans(color: lightTextSecondary),
        bodySmall: GoogleFonts.plusJakartaSans(color: lightTextTertiary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightInput,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: lightPrimary, width: 2),
        ),
        labelStyle: const TextStyle(color: lightTextSecondary, fontWeight: FontWeight.w600),
        hintStyle: const TextStyle(color: lightTextTertiary),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: lightPrimaryCta,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          elevation: 2,
          shadowColor: lightPrimary.withValues(alpha: 0.3),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: lightTextPrimary,
          backgroundColor: Colors.white,
          side: const BorderSide(color: lightBorder),
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: Colors.white,
        headerBackgroundColor: lightPrimary,
        headerForegroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        dividerColor: lightBorder,
        dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return lightPrimary;
          }
          return null;
        }),
        dayForegroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          if (states.contains(WidgetState.disabled)) {
            return lightTextTertiary.withValues(alpha: 0.5);
          }
          return lightTextPrimary;
        }),
        todayForegroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          return lightPrimary;
        }),
        todayBorder: const BorderSide(color: lightPrimary, width: 1.5),
        yearForegroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          return lightTextPrimary;
        }),
        cancelButtonStyle: TextButton.styleFrom(
          foregroundColor: lightPrimary,
          textStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
        ),
        confirmButtonStyle: TextButton.styleFrom(
          foregroundColor: lightPrimary,
          textStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // ==========================================
  // DARK THEME CONFIGURATION
  // ==========================================
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      splashFactory: const SoundFeedbackSplashFactory(),
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: darkPrimary,
        onPrimary: Colors.white,
        primaryContainer: darkPrimaryLight,
        onPrimaryContainer: darkTextPrimary,
        secondary: darkPrimaryCta,
        onSecondary: Colors.white,
        surface: darkCard,
        onSurface: darkTextPrimary,
        surfaceContainerHighest: darkCardElevated,
        outline: darkBorder,
        error: functionalError,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: darkBackground,
      cardColor: darkCard,
      cardTheme: const CardThemeData(
        color: darkCard,
        elevation: 0,
        margin: EdgeInsets.zero,
      ),
      dividerColor: darkBorder,
      dividerTheme: const DividerThemeData(
        color: darkBorder,
        thickness: 1,
      ),
      iconTheme: const IconThemeData(
        color: darkIcon,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBackground,
        foregroundColor: darkTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: darkCardElevated,
        selectedItemColor: darkPrimary,
        unselectedItemColor: darkTextTertiary,
      ),
      textTheme: GoogleFonts.plusJakartaSansTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.plusJakartaSans(color: darkTextPrimary, fontWeight: FontWeight.bold),
        titleLarge: GoogleFonts.plusJakartaSans(color: darkTextPrimary, fontWeight: FontWeight.bold),
        titleMedium: GoogleFonts.plusJakartaSans(color: darkTextPrimary, fontWeight: FontWeight.w600),
        bodyLarge: GoogleFonts.plusJakartaSans(color: darkTextPrimary),
        bodyMedium: GoogleFonts.plusJakartaSans(color: darkTextSecondary),
        bodySmall: GoogleFonts.plusJakartaSans(color: darkTextTertiary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkInput,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: darkPrimary, width: 2),
        ),
        labelStyle: const TextStyle(color: darkTextSecondary, fontWeight: FontWeight.w600),
        hintStyle: const TextStyle(color: darkTextTertiary),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkPrimaryCta,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          elevation: 2,
          shadowColor: Colors.black.withValues(alpha: 0.3),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: darkTextPrimary,
          backgroundColor: darkCard,
          side: const BorderSide(color: darkBorder),
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: darkCard,
        headerBackgroundColor: darkSecondaryBackground,
        headerForegroundColor: darkPrimary,
        surfaceTintColor: Colors.transparent,
        dividerColor: darkBorder,
        dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return darkPrimary;
          }
          return null;
        }),
        dayForegroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const Color(0xFF0F1C18);
          }
          if (states.contains(WidgetState.disabled)) {
            return darkTextTertiary.withValues(alpha: 0.5);
          }
          return darkTextPrimary;
        }),
        todayForegroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const Color(0xFF0F1C18);
          }
          return darkPrimary;
        }),
        todayBorder: const BorderSide(color: darkPrimary, width: 1.5),
        yearForegroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const Color(0xFF0F1C18);
          }
          return darkTextPrimary;
        }),
        cancelButtonStyle: TextButton.styleFrom(
          foregroundColor: darkPrimary,
          textStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
        ),
        confirmButtonStyle: TextButton.styleFrom(
          foregroundColor: darkPrimary,
          textStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
