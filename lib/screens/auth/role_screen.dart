import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/constants/asset_paths.dart';

class RoleScreen extends ConsumerStatefulWidget {
  const RoleScreen({super.key});

  @override
  ConsumerState<RoleScreen> createState() => _RoleScreenState();
}

class _RoleScreenState extends ConsumerState<RoleScreen> {
  String? _selected;

  void _continue() {
    if (_selected != null) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPaddingH),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.asset(AssetPaths.appIcon, width: 48, height: 48, fit: BoxFit.cover),
              ),
              const SizedBox(height: 16),
              Text('How will you use Scrapify?', style: AppTextStyles.displayMedium),
              const SizedBox(height: 8),
              Text(
                'You can always switch roles later',
                style: AppTextStyles.caption,
              ),
              const SizedBox(height: 32),
              _roleCard(
                'buyer',
                'Buyer',
                'Browse auctions, place bids, and win industrial scrap lots',
                Icons.shopping_bag_rounded,
              ),
              const SizedBox(height: 12),
              _roleCard(
                'seller',
                'Seller',
                'List your scrap materials for auction and manage sales',
                Icons.storefront_rounded,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: AppSpacing.buttonXl,
                child: ElevatedButton(
                  onPressed: _selected != null ? _continue : null,
                  child: const Text('Continue'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _roleCard(String value, String title, String desc, IconData icon) {
    final isSelected = _selected == value;
    return GestureDetector(
      onTap: () => setState(() => _selected = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.auction.withValues(alpha: 0.05) : AppColors.appBg,
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          border: Border.all(
            color: isSelected ? AppColors.auction : AppColors.blackWithOpacity(0.05),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.auction.withValues(alpha: 0.1)
                    : AppColors.navyWithOpacity(0.05),
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.auction : AppColors.navyWithOpacity(0.5),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.labelLarge),
                  const SizedBox(height: 2),
                  Text(desc, style: AppTextStyles.caption),
                ],
              ),
            ),
            if (isSelected)
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: AppColors.auction,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, size: 14, color: AppColors.white),
              ),
          ],
        ),
      ),
    );
  }
}
