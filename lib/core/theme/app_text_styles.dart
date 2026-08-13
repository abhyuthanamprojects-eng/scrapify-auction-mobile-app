import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

abstract final class AppTextStyles {
  static String? _manrope;
  static String? _sora;

  static String get _manropeFamily =>
      _manrope ??= GoogleFonts.manrope().fontFamily!;
  static String get _soraFamily => _sora ??= GoogleFonts.sora().fontFamily!;

  // Body text (Manrope)
  static TextStyle body({
    double size = 14,
    FontWeight weight = FontWeight.w400,
    Color color = AppColors.navy,
    double? height,
  }) =>
      TextStyle(
        fontFamily: _manropeFamily,
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
      );

  // Heading text (Sora)
  static TextStyle heading({
    double size = 18,
    FontWeight weight = FontWeight.w700,
    Color color = AppColors.navy,
    double letterSpacing = -0.15,
  }) =>
      TextStyle(
        fontFamily: _soraFamily,
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: letterSpacing,
      );

  // Common presets
  static TextStyle get displayLarge =>
      heading(size: 28, weight: FontWeight.w900);
  static TextStyle get displayMedium =>
      heading(size: 24, weight: FontWeight.w800);
  static TextStyle get titleLarge => heading(size: 20, weight: FontWeight.w700);
  static TextStyle get titleMedium =>
      heading(size: 18, weight: FontWeight.w700);
  static TextStyle get titleSmall => heading(size: 16, weight: FontWeight.w700);

  static TextStyle get bodyLarge =>
      body(size: 16, weight: FontWeight.w400);
  static TextStyle get bodyMedium =>
      body(size: 14, weight: FontWeight.w400);
  static TextStyle get bodySmall =>
      body(size: 12, weight: FontWeight.w400);

  static TextStyle get labelLarge =>
      body(size: 14, weight: FontWeight.w700);
  static TextStyle get labelMedium =>
      body(size: 12, weight: FontWeight.w700);
  static TextStyle get labelSmall =>
      body(size: 11, weight: FontWeight.w700);
  static TextStyle get labelTiny =>
      body(size: 10, weight: FontWeight.w700);

  static TextStyle get caption =>
      body(size: 11, weight: FontWeight.w400, color: AppColors.navyWithOpacity(0.6));
  static TextStyle get captionMuted =>
      body(size: 10, weight: FontWeight.w400, color: AppColors.navyWithOpacity(0.5));

  // Price / amount styles
  static TextStyle get priceLarge =>
      body(size: 20, weight: FontWeight.w900, color: AppColors.navy);
  static TextStyle get priceMedium =>
      body(size: 16, weight: FontWeight.w800, color: AppColors.navy);
  static TextStyle get priceSmall =>
      body(size: 14, weight: FontWeight.w800, color: AppColors.navy);

  // Mono style for IDs
  static TextStyle get mono => TextStyle(
        fontFamily: 'monospace',
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: AppColors.navyWithOpacity(0.5),
      );
}
