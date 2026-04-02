import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const bg = Color(0xFFF4F7F4);
  static const bg2 = Color(0xFFFFFFFF);
  static const bg3 = Color(0xFFF7FAF8);
  static const bg4 = Color(0xFFE8F3EC);

  static const card = Color(0xFFFFFFFF);
  static const cardSoft = Color(0xFFF7FBF8);
  static const cardStrong = Color(0xFF1F5E3E);

  static const border = Color(0xFFD5E5DB);
  static const borderSoft = Color(0xFFE7EFEA);

  static const green = Color(0xFF2ECC71);
  static const green2 = Color(0xFF245C3D);
  static const green3 = Color(0xFF328458);
  static const green4 = Color(0xFF59AA79);
  static const greenBg = Color(0xFFEAF7F0);

  static const red = Color(0xFFD64545);
  static const red2 = Color(0xFFB33434);
  static const redBg = Color(0xFFFDEEEE);

  static const blue = Color(0xFF2F7CF6);
  static const blue2 = Color(0xFF1F63C3);
  static const blueBg = Color(0xFFEAF2FF);

  static const orange = Color(0xFFF4A62A);
  static const orange2 = Color(0xFFE68E00);
  static const orangeBg = Color(0xFFFFF5E7);

  static const text = Color(0xFF16231C);
  static const text2 = Color(0xFF55695F);
  static const text3 = Color(0xFF8AA095);

  static const shadow = Color(0x14000000);
}

ThemeData buildTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      primary: AppColors.green2,
      secondary: AppColors.orange,
      surface: AppColors.bg2,
      error: AppColors.red,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.text,
    ),
  );

  final textTheme = GoogleFonts.cairoTextTheme(base.textTheme).copyWith(
    headlineSmall: GoogleFonts.cairo(
      fontSize: 28,
      fontWeight: FontWeight.w900,
      color: AppColors.text,
    ),
    titleLarge: GoogleFonts.cairo(
      fontSize: 22,
      fontWeight: FontWeight.w900,
      color: AppColors.text,
    ),
    titleMedium: GoogleFonts.cairo(
      fontSize: 17,
      fontWeight: FontWeight.w800,
      color: AppColors.text,
    ),
    bodyLarge: GoogleFonts.cairo(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      color: AppColors.text,
    ),
    bodyMedium: GoogleFonts.cairo(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AppColors.text2,
    ),
  );

  return base.copyWith(
    scaffoldBackgroundColor: AppColors.bg,
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.bg,
      foregroundColor: AppColors.text,
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      shadowColor: Colors.transparent,
      titleTextStyle: GoogleFonts.cairo(
        color: AppColors.text,
        fontWeight: FontWeight.w900,
        fontSize: 20,
      ),
    ),
    cardTheme: const CardThemeData(
      color: AppColors.card,
      elevation: 0,
      margin: EdgeInsets.zero,
    ),
    dividerColor: AppColors.border,
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.bg2,
      surfaceTintColor: Colors.transparent,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return TextStyle(
          fontFamily: GoogleFonts.cairo().fontFamily,
          fontSize: selected ? 13 : 12,
          fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
          color: selected ? AppColors.green2 : AppColors.text3,
        );
      }),
      indicatorColor: AppColors.greenBg,
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          color: selected ? AppColors.green2 : AppColors.text3,
          size: selected ? 28 : 24,
        );
      }),
      height: 82,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.bg3,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: const TextStyle(
        color: AppColors.text3,
        fontWeight: FontWeight.w600,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: AppColors.borderSoft),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: AppColors.green3, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: AppColors.red),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.green2,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(58),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        textStyle: GoogleFonts.cairo(
          fontSize: 16,
          fontWeight: FontWeight.w900,
        ),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.green2,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(18)),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.green2,
      contentTextStyle: GoogleFonts.cairo(
        color: Colors.white,
        fontWeight: FontWeight.w800,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}
