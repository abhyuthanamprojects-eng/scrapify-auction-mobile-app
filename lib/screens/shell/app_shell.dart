import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    final isSeller = ref.watch(authProvider).isSeller;

    const screens = [
      HomeScreen(),
      AuctionsScreen(),
      MyBidsScreen(),
      OrdersScreen(),
      ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: tabIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomTabBar(
        currentIndex: tabIndex,
        isSeller: isSeller,
        onTap: (i) => ref.read(tabIndexProvider.notifier).state = i,
      ),
    );
  }
}
