import 'package:flutter/material.dart';

abstract final class AppColors {
  // Primary palette (matching Lovable source of truth)
  static const navy = Color(0xFF0B1F3A);          // Deep navy
  static const noir2 = Color(0xFF13284A);         // Soft navy
  static const accentBlue = Color(0xFF1565C0);    // Action blue
  static const auction = Color(0xFFF97316);       // Orange primary
  static const gold = Color(0xFFF97316);          // Orange accent
  static const goldSoft = Color(0xFFFDBA74);      // Soft orange
  static const success = Color(0xFF22C55E);       // Green success
  static const destructive = Color(0xFFEF4444);   // Red error / outbid
  static const warning = Color(0xFFF59E0B);       // Amber / warning
  static const appBg = Color(0xFFF4F7FB);         // Cool ivory background
  static const white = Color(0xFFFFFFFF);
  static const black = Color(0xFF000000);
  static const cardBorder = Color(0xFFE2E8F0);
  static const inputBg = Color(0xFFF8FAFC);
  static const textSecondary = Color(0xFF64748B);

  // Extended tints & shades
  static const navyDark = Color(0xFF06132A);
  static const orangeDark = Color(0xFFC2410C);
  static const orangeLight = Color(0xFFFFEDD5);
  static const successLight = Color(0xFFDCFCE7);
  static const destructiveLight = Color(0xFFFEE2E2);
  static const blueLight = Color(0xFFDBEAFE);
  static const warningLight = Color(0xFFFEF3C7);
  static const purple = Color(0xFF8B5CF6);
  static const purpleLight = Color(0xFFEDE9FE);

  // Opacity helper methods
  static Color navyWithOpacity(double opacity) => navy.withValues(alpha: opacity);
  static Color auctionWithOpacity(double opacity) => auction.withValues(alpha: opacity);
  static Color whiteWithOpacity(double opacity) => white.withValues(alpha: opacity);
  static Color blackWithOpacity(double opacity) => black.withValues(alpha: opacity);
  static Color successWithOpacity(double opacity) => success.withValues(alpha: opacity);
  static Color destructiveWithOpacity(double opacity) => destructive.withValues(alpha: opacity);
  static Color accentBlueWithOpacity(double opacity) => accentBlue.withValues(alpha: opacity);
  static Color warningWithOpacity(double opacity) => warning.withValues(alpha: opacity);

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

  static const gradientNoirRadial = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF16325C), Color(0xFF0B1F3A), Color(0xFF06132A)],
  );

  static const gradientReverse = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0284C7), Color(0xFF0369A1), Color(0xFF075985)],
  );

  static const gradientEmerald = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF10B981), Color(0xFF059669), Color(0xFF047857)],
  );

  // Box Shadows
  static const List<BoxShadow> shadowSm = [
    BoxShadow(color: Color(0x0A000000), blurRadius: 4, offset: Offset(0, 1)),
  ];

  static const List<BoxShadow> shadowMd = [
    BoxShadow(color: Color(0x12000000), blurRadius: 10, offset: Offset(0, 3)),
  ];

  static const List<BoxShadow> shadowLg = [
    BoxShadow(color: Color(0x1A000000), blurRadius: 16, offset: Offset(0, 6)),
  ];

  static const List<BoxShadow> shadowGold = [
    BoxShadow(color: Color(0x66F97316), blurRadius: 18, offset: Offset(0, 6)),
    BoxShadow(color: Color(0x33F97316), blurRadius: 8, offset: Offset(0, 2)),
  ];

  static const List<BoxShadow> shadowNoir = [
    BoxShadow(color: Color(0x6606132A), blurRadius: 20, offset: Offset(0, 8)),
    BoxShadow(color: Color(0x3306132A), blurRadius: 10, offset: Offset(0, 3)),
  ];
}
