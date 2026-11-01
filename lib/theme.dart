import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // ---- 3 main colours ----
  static const deep = Color(0xFF312E81);
  static const primary = Color(0xFF4F46E5);
  static const soft = Color(0xFFEEF0FF);

  // ---- neutrals ----
  static const bg = Color(0xFFF6F7FB);
  static const border = Color(0xFFE3E6F0);

  // ---- purane naam (baaki screens abhi inhe use karti hain) ----
  static const navy = Color(0xFF1E1B4B);
  static const violet = primary;
  static const pink = Color(0xFF4338CA);
  static const yellow = Color(0xFF6366F1);
  static const mint = Color(0xFF818CF8);
}

ThemeData buildTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
    ),
    scaffoldBackgroundColor: AppColors.bg,
  );
  return base.copyWith(
    textTheme: GoogleFonts.interTextTheme(base.textTheme),
  );
}