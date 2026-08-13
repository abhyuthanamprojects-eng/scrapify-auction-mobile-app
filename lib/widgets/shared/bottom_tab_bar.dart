import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

class BottomTabBar extends StatelessWidget {
  final int currentIndex;
  final bool isSeller;
  final ValueChanged<int> onTap;

  const BottomTabBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.isSeller = false,
  });

  List<_TabItem> get _items => isSeller
      ? [
          _TabItem(Icons.home_rounded, 'Home'),
          _TabItem(Icons.gavel_rounded, 'Auctions'),
          _TabItem(Icons.account_balance_wallet_rounded, 'Wallet'),
          _TabItem(Icons.monitor_rounded, 'Monitor'),
          _TabItem(Icons.person_rounded, 'Profile'),
        ]
      : [
          _TabItem(Icons.home_rounded, 'Home'),
          _TabItem(Icons.gavel_rounded, 'Auctions'),
          _TabItem(Icons.account_balance_wallet_rounded, 'Wallet'),
          _TabItem(Icons.receipt_long_rounded, 'My Bids'),
          _TabItem(Icons.person_rounded, 'Profile'),
        ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        gradient: AppColors.gradientNoir,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXxl),
        boxShadow: [
          BoxShadow(
            color: AppColors.navyDark.withValues(alpha: 0.55),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_items.length, (i) {
          final isCenter = i == 2;
          final isActive = currentIndex == i;
          if (isCenter) {
            return _buildWalletButton(isActive);
          }
          return _buildTab(_items[i], isActive, i);
        }),
      ),
    );
  }

  Widget _buildTab(_TabItem item, bool isActive, int index) {
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 56,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              item.icon,
              size: 22,
              color: isActive ? AppColors.auction : AppColors.whiteWithOpacity(0.5),
            ),
            const SizedBox(height: 2),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? AppColors.auction : AppColors.whiteWithOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletButton(bool isActive) {
    return GestureDetector(
      onTap: () => onTap(2),
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          gradient: isActive ? AppColors.gradientGold : null,
          color: isActive ? null : AppColors.whiteWithOpacity(0.1),
          shape: BoxShape.circle,
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppColors.auction.withValues(alpha: 0.5),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ]
              : null,
        ),
        child: Icon(
          Icons.account_balance_wallet_rounded,
          size: 24,
          color: isActive ? AppColors.white : AppColors.whiteWithOpacity(0.5),
        ),
      ),
    );
  }
}

class _TabItem {
  final IconData icon;
  final String label;
  const _TabItem(this.icon, this.label);
}
