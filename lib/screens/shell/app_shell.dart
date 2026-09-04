import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/shared/bottom_tab_bar.dart';
import '../home/home_screen.dart';
import '../auctions/auctions_screen.dart';
import '../my_bids/my_bids_screen.dart';
import '../orders/orders_screen.dart';
import '../profile/profile_screen.dart';

final tabIndexProvider = StateProvider<int>((ref) => 0);

class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabIndex = ref.watch(tabIndexProvider);
    final authData = ref.watch(authProvider);
    final isAuthenticated = authData.isAuthenticated;
    final isSeller = authData.isSeller;
    final kycVerified = authData.user?.kycVerified ?? false;
    final isPendingKyc = isAuthenticated && !kycVerified;

    const screens = [
      HomeScreen(),
      AuctionsScreen(),
      MyBidsScreen(),
      OrdersScreen(),
      ProfileScreen(),
    ];

    return Scaffold(
      body: Column(
        children: [
          if (isPendingKyc)
            Material(
              color: AppColors.auction.withValues(alpha: 0.1),
              child: SafeArea(
                bottom: false,
                child: InkWell(
                  onTap: () => context.push('/reg-status'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.auction.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.access_time, size: 18, color: AppColors.auction),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Profile under review',
                                style: AppTextStyles.heading(size: 13, weight: FontWeight.w800, color: AppColors.navy),
                              ),
                              const SizedBox(height: 1),
                              Text(
                                'Bidding & orders are disabled until admin verifies your KYC.',
                                style: TextStyle(fontSize: 11, color: AppColors.navyWithOpacity(0.6)),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right, size: 18, color: AppColors.navyWithOpacity(0.4)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          Expanded(
            child: IndexedStack(
              index: tabIndex,
              children: screens,
            ),
          ),
        ],
      ),
      bottomNavigationBar: isAuthenticated
          ? BottomTabBar(
              currentIndex: tabIndex,
              isSeller: isSeller,
              onTap: (i) {
                if (isPendingKyc && (i == 2 || i == 3)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('This feature is available after KYC verification.'),
                      backgroundColor: AppColors.auction,
                    ),
                  );
                  return;
                }
                ref.read(tabIndexProvider.notifier).state = i;
              },
            )
          : null,
    );
  }
}
