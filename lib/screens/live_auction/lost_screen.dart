import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';

class LostScreen extends StatelessWidget {
  const LostScreen({super.key});

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
                  color: AppColors.navyWithOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.sentiment_neutral, size: 40, color: AppColors.navyWithOpacity(0.4)),
              ),
              const SizedBox(height: 20),
              Text('Better luck next time', style: AppTextStyles.displayMedium),
              const SizedBox(height: 8),
              Text('You were outbid on this lot', style: AppTextStyles.caption),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, size: 16, color: AppColors.success),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Your EMD has been released back to your wallet',
                        style: AppTextStyles.caption.copyWith(color: AppColors.success),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: AppSpacing.buttonXl,
                child: ElevatedButton(
                  onPressed: () => context.go('/home'),
                  child: const Text('Browse More Auctions'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
