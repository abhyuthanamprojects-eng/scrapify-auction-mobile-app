import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';

class PriceDisplay extends StatelessWidget {
  final double amount;
  final String? label;
  final double? originalAmount;
  final bool isReverse;
  final bool isLarge;
  final Color? color;

  const PriceDisplay({
    super.key,
    required this.amount,
    this.label,
    this.originalAmount,
    this.isReverse = false,
    this.isLarge = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? (isReverse ? AppColors.accentBlue : AppColors.navy);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 2),
        ],
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              Formatters.formatINR(amount),
              style: TextStyle(
                fontSize: isLarge ? 26 : 17,
                fontWeight: FontWeight.w900,
                color: effectiveColor,
                letterSpacing: -0.3,
              ),
            ),
            if (originalAmount != null && originalAmount! > 0 && originalAmount != amount) ...[
              const SizedBox(width: 8),
              Text(
                Formatters.formatINR(originalAmount!),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF94A3B8),
                  decoration: TextDecoration.lineThrough,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
