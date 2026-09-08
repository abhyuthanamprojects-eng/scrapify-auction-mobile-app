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
      ? const [
          _TabItem(Icons.home_rounded, 'Home'),
          _TabItem(Icons.gavel_rounded, 'My Auctions'),
          _TabItem(Icons.storefront_rounded, 'Market'),
          _TabItem(Icons.notifications_none_rounded, 'Notices'),
          _TabItem(Icons.person_rounded, 'Profile'),
        ]
      : const [
          _TabItem(Icons.home_rounded, 'Home'),
          _TabItem(Icons.gavel_rounded, 'Events'),
          _TabItem(Icons.receipt_long_rounded, 'Bids'),
          _TabItem(Icons.local_shipping_rounded, 'Orders'),
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
          final isActive = currentIndex == i;
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
              color: isActive
                  ? AppColors.auction
                  : AppColors.whiteWithOpacity(0.5),
            ),
            const SizedBox(height: 2),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
                color: isActive
                    ? AppColors.auction
                    : AppColors.whiteWithOpacity(0.5),
              ),
            ),
          ],
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
