import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // ---- light screens ----
  static const deep = Color(0xFF312E81);
  static const primary = Color(0xFF4F46E5);
  static const soft = Color(0xFFEEF0FF);
  static const bg = Color(0xFFF6F7FB);
  static const border = Color(0xFFE3E6F0);

  // ---- dark landing ----
  static const ink = Color(0xFF0B1030);
  static const ink2 = Color(0xFF1B1747);
  static const ink3 = Color(0xFF2E1A5C);

  // ---- rangeen accents ----
  static const accentIndigo = Color(0xFF6366F1);
  static const accentViolet = Color(0xFF8B5CF6);
  static const accentPink = Color(0xFFEC4899);
  static const accentCyan = Color(0xFF22D3EE);
  static const accentAmber = Color(0xFFF59E0B);
  static const accentGreen = Color(0xFF10B981);

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

/// Dark gradient background, pink aur cyan glow ke saath
class DarkBackdrop extends StatelessWidget {
  final Widget child;
  const DarkBackdrop({super.key, required this.child});

  Widget _glow(Color c, double size) => IgnorePointer(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [c.withOpacity(0.28), c.withOpacity(0)],
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.ink, AppColors.ink2, AppColors.ink3],
        ),
      ),
      child: Stack(
        children: [
          Positioned(top: -140, right: -120, child: _glow(AppColors.accentPink, 420)),
          Positioned(bottom: -160, left: -140, child: _glow(AppColors.accentCyan, 460)),
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}

/// QRush ka logo (gradient square + QR icon)
class BrandMark extends StatelessWidget {
  final double size;
  const BrandMark({super.key, this.size = 36});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.3),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.accentIndigo, AppColors.accentPink],
        ),
      ),
      child: Icon(Icons.qr_code_2, color: Colors.white, size: size * 0.62),
    );
  }
}