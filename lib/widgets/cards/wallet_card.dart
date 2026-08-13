import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/formatters.dart';

class WalletCard extends StatelessWidget {
  final double balance;
  final VoidCallback? onTap;
  final bool compact;

  const WalletCard({
    super.key,
    required this.balance,
    this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(compact ? 12 : 16),
        decoration: BoxDecoration(
          gradient: AppColors.gradientGold,
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          boxShadow: [
            BoxShadow(
              color: AppColors.auction.withValues(alpha: 0.5),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Wallet Balance',
                    style: AppTextStyles.body(
                      size: compact ? 10 : 11,
                      color: AppColors.whiteWithOpacity(0.8),
                      weight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    Formatters.formatINR(balance),
                    style: AppTextStyles.heading(
                      size: compact ? 18 : 24,
                      weight: FontWeight.w800,
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: compact ? 32 : 40,
              height: compact ? 32 : 40,
              decoration: BoxDecoration(
                color: AppColors.whiteWithOpacity(0.2),
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              ),
              child: Icon(
                Icons.account_balance_wallet,
                color: AppColors.white,
                size: compact ? 18 : 22,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
