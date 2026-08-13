import 'package:flutter/material.dart';

abstract final class AppColors {
  // Primary palette
  static const navy = Color(0xFF0B1F3A);
  static const noir2 = Color(0xFF13284A);
  static const accentBlue = Color(0xFF1565C0);
  static const auction = Color(0xFFF97316);
  static const gold = Color(0xFFF97316);
  static const goldSoft = Color(0xFFFDBA74);
  static const success = Color(0xFF22C55E);
  static const destructive = Color(0xFFEF4444);
  static const appBg = Color(0xFFF4F7FB);
  static const white = Color(0xFFFFFFFF);
  static const black = Color(0xFF000000);

  // Extended
  static const navyDark = Color(0xFF06132A);
  static const orangeDark = Color(0xFFC2410C);
  static const orangeLight = Color(0xFFFFEDD5);
  static const successLight = Color(0xFFDCFCE7);
  static const destructiveLight = Color(0xFFFEE2E2);
  static const blueLight = Color(0xFFDBEAFE);

  // Opacity helpers
  static Color navyWithOpacity(double opacity) => navy.withValues(alpha: opacity);
  static Color auctionWithOpacity(double opacity) => auction.withValues(alpha: opacity);
  static Color whiteWithOpacity(double opacity) => white.withValues(alpha: opacity);
  static Color blackWithOpacity(double opacity) => black.withValues(alpha: opacity);
  static Color successWithOpacity(double opacity) => success.withValues(alpha: opacity);
  static Color destructiveWithOpacity(double opacity) => destructive.withValues(alpha: opacity);
  static Color accentBlueWithOpacity(double opacity) => accentBlue.withValues(alpha: opacity);

  // Gradients
  static const gradientGold = LinearGradient(
    begin: Alignment(-1, -1),
    end: Alignment(1, 1),
    colors: [goldSoft, auction, orangeDark],
  );

  static const gradientGoldSoft = LinearGradient(
    begin: Alignment(-1, -1),
    end: Alignment(1, 1),
    colors: [orangeLight, goldSoft, auction],
  );

  static const gradientNoir = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [noir2, navy, navyDark],
  );
}
