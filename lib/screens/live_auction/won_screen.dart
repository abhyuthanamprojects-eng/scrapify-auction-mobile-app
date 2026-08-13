import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/formatters.dart';

class WonScreen extends StatelessWidget {
  final String lotTitle;
  final double winningBid;

  const WonScreen({
    super.key,
    this.lotTitle = 'Mixed IT Assets - Dell Laptops',
    this.winningBid = 195000,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPaddingH),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.emoji_events, size: 40, color: AppColors.success),
              ),
              const SizedBox(height: 20),
              Text('Congratulations!', style: AppTextStyles.displayMedium),
              const SizedBox(height: 8),
              Text('You won the auction', style: AppTextStyles.caption),
              const SizedBox(height: 32),
              _infoRow('Lot', lotTitle),
              _infoRow('Winning Bid', Formatters.formatINR(winningBid)),
              _infoRow('Status', 'Pending Payment'),
              const SizedBox(height: 24),
              Text('Next Steps', style: AppTextStyles.titleSmall),
              const SizedBox(height: 12),
              _step(1, 'Pay balance amount', true),
              _step(2, 'Schedule pickup', false),
              _step(3, 'Weighbridge verification', false),
              _step(4, 'Material handover', false),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: AppSpacing.buttonXl,
                child: ElevatedButton(
                  onPressed: () => context.go('/home'),
                  child: const Text('Pay Balance'),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => context.go('/home'),
                child: Text('Back to Home', style: AppTextStyles.bodySmall.copyWith(color: AppColors.navyWithOpacity(0.6))),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.caption),
          Text(value, style: AppTextStyles.labelMedium),
        ],
      ),
    );
  }

  Widget _step(int num, String label, bool active) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: active ? AppColors.auction : AppColors.navyWithOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: active
                  ? const Icon(Icons.check, size: 14, color: AppColors.white)
                  : Text('$num', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.navyWithOpacity(0.4))),
            ),
          ),
          const SizedBox(width: 10),
          Text(label, style: active ? AppTextStyles.labelMedium : AppTextStyles.caption),
        ],
      ),
    );
  }
}
