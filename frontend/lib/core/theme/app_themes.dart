// Temas de la aplicación FlexiDrive
// Define colores y estilos para modo claro y oscuro
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Clase que contiene todos los temas de la aplicación
// Define la paleta de colores y estilos tipográficos
class AppThemes {
  // ── Brand ──────────────────────────────────────────────────────
  // Colores principales de la marca
  static const Color primaryIndigo = Color(0xFF4F46E5);
  static const Color primaryPurple = Color(0xFF7C3AED);
  static const Color accentGreen = Color(0xFF10B981);
  static const Color accentRed = Color(0xFFEF4444);
  static const Color accentAmber = Color(0xFFF59E0B);

  // ── Light ──────────────────────────────────────────────────────
  static const Color lightBg = Color(0xFFF8F9FA);
  static const Color lightSurface = Colors.white;
  static const Color lightText = Color(0xFF1A1A1A);
  static const Color lightTextSub = Color(0xFF6B7280);
  static const Color lightBorder = Color(0xFFE5E7EB);

  // ── Dark ───────────────────────────────────────────────────────
  static const Color darkBg = Color(0xFF0D0F1A); // deep navy-black
  static const Color darkSurface = Color(0xFF161827); // card bg
  static const Color darkSurfaceEl = Color(0xFF1F2235); // elevated card
  static const Color darkSurfaceHi = Color(0xFF272B40); // input / hover
  static const Color darkText = Color(0xFFF1F3FF);
  static const Color darkTextSub = Color(0xFF8B93B8);
  static const Color darkBorder = Color(0xFF2E3355);
  static const Color darkDivider = Color(0xFF252942);

  // ── Helpers ────────────────────────────────────────────────────
  static TextTheme _textTheme(Color body) =>
      GoogleFonts.poppinsTextTheme().apply(bodyColor: body, displayColor: body);

  static InputDecorationTheme _inputTheme(Color fill, Color border) =>
      InputDecorationTheme(
        filled: true,
        fillColor: fill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryIndigo, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      );

  // ── LIGHT THEME ────────────────────────────────────────────────
  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: lightBg,
        colorScheme: const ColorScheme.light(
          primary: primaryIndigo,
          secondary: primaryPurple,
          surface: lightSurface,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: lightText,
        ),
        textTheme: _textTheme(lightText),
        appBarTheme: AppBarTheme(
          backgroundColor: lightSurface,
          foregroundColor: lightText,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: lightText,
          ),
        ),
        cardTheme: CardThemeData(
          color: lightSurface,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        inputDecorationTheme: _inputTheme(lightSurface, lightBorder),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryIndigo,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle:
                GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ),
        iconTheme: const IconThemeData(color: lightTextSub),
        dividerTheme: const DividerThemeData(color: lightBorder, thickness: 1),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((s) => Colors.white),
          trackColor: WidgetStateProperty.resolveWith((s) =>
              s.contains(WidgetState.selected) ? primaryIndigo : lightBorder),
        ),
      );

  // ── DARK THEME ─────────────────────────────────────────────────
  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: darkBg,
        colorScheme: ColorScheme.dark(
          primary: primaryIndigo,
          secondary: primaryPurple,
          surface: darkSurface,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: darkText,
          outline: darkBorder,
          surfaceContainerHighest: darkSurfaceEl,
        ),
        textTheme: _textTheme(darkText),
        appBarTheme: AppBarTheme(
          backgroundColor: darkSurface,
          foregroundColor: darkText,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: darkText,
          ),
        ),
        cardTheme: CardThemeData(
          color: darkSurface,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        inputDecorationTheme: _inputTheme(darkSurfaceHi, darkBorder).copyWith(
          hintStyle: GoogleFonts.inter(color: darkTextSub, fontSize: 14),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryIndigo,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle:
                GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ),
        iconTheme: const IconThemeData(color: darkTextSub),
        dividerTheme: const DividerThemeData(color: darkDivider, thickness: 1),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((s) => Colors.white),
          trackColor: WidgetStateProperty.resolveWith((s) =>
              s.contains(WidgetState.selected) ? primaryIndigo : darkBorder),
        ),
        // Popupmenus, dialogs, bottom sheets
        dialogTheme: DialogThemeData(
          backgroundColor: darkSurface,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: darkSurface,
          modalBackgroundColor: darkSurface,
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: darkSurfaceEl,
          contentTextStyle:
              GoogleFonts.inter(color: darkText, fontWeight: FontWeight.w500),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          behavior: SnackBarBehavior.floating,
        ),
      );
}
