import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../models/auction.dart';
import '../../providers/seller_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/shared/status_chip.dart';
import '../../widgets/shared/loading_skeleton.dart';

class SellerHomeScreen extends ConsumerWidget {
  const SellerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final auctionsAsync = ref.watch(sellerAuctionsProvider);

    return Scaffold(
      backgroundColor: AppColors.appBg,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/seller/create-auction'),
        backgroundColor: AppColors.auction,
        icon: const Icon(Icons.add, color: AppColors.white),
        label: const Text('New Auction', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w700)),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(gradient: AppColors.gradientNoir),
              padding: EdgeInsets.fromLTRB(
                AppSpacing.screenPaddingH,
                MediaQuery.of(context).padding.top + 16,
                AppSpacing.screenPaddingH,
                20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, ${(user?.name ?? "Seller").split(" ").first}',
                    style: AppTextStyles.heading(size: 22, weight: FontWeight.w800, color: AppColors.white),
                  ),
                  const SizedBox(height: 4),
                  Text('Seller Dashboard', style: AppTextStyles.body(size: 13, color: AppColors.whiteWithOpacity(0.6))),
                  const SizedBox(height: 16),
                  _earningsCard(),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(child: _statsGrid(auctionsAsync)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.screenPaddingH, 16, AppSpacing.screenPaddingH, 8),
              child: Text('Active Auctions', style: AppTextStyles.titleSmall),
            ),
          ),
          auctionsAsync.when(
            data: (auctions) {
              final active = auctions.where((a) => a.status == AuctionStatus.live || a.status == AuctionStatus.published).toList();
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => _auctionCard(context, active[i]),
                  childCount: active.length,
                ),
              );
            },
            loading: () => const SliverToBoxAdapter(child: Padding(padding: EdgeInsets.all(20), child: ListSkeleton(count: 2))),
            error: (e, _) => SliverToBoxAdapter(child: Center(child: Text('$e'))),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _earningsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.gradientGold,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total Earnings', style: AppTextStyles.body(size: 11, color: AppColors.whiteWithOpacity(0.8), weight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text('—', style: AppTextStyles.heading(size: 24, weight: FontWeight.w800, color: AppColors.white)),
              ],
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: AppColors.whiteWithOpacity(0.2), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.trending_up, color: AppColors.white),
          ),
        ],
      ),
    );
  }

  Widget _statsGrid(AsyncValue<List<Auction>> auctionsAsync) {
    final auctions = auctionsAsync.valueOrNull ?? [];
    final total = auctions.length;
    final live = auctions.where((a) => a.isLive).length;
    final closed = auctions.where((a) => a.status == AuctionStatus.closed).length;

    final stats = [
      ('$total', 'Total Auctions'),
      ('$live', 'Live'),
      ('$closed', 'Completed'),
      ('—', 'Revenue'),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.screenPaddingH, 16, AppSpacing.screenPaddingH, 0),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 2.2,
        children: stats.map((s) => Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(color: AppColors.blackWithOpacity(0.05)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(s.$1, style: AppTextStyles.heading(size: 20, weight: FontWeight.w800)),
              Text(s.$2, style: AppTextStyles.captionMuted),
            ],
          ),
        )).toList(),
      ),
    );
  }

  Widget _auctionCard(BuildContext context, Auction auction) {
    return GestureDetector(
      onTap: () => context.push('/seller/auctions'),
      child: Container(
        margin: const EdgeInsets.fromLTRB(AppSpacing.screenPaddingH, 0, AppSpacing.screenPaddingH, 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          border: Border.all(color: AppColors.blackWithOpacity(0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(auction.code, style: AppTextStyles.mono),
                      Text(auction.materialType ?? auction.category ?? auction.title, style: AppTextStyles.labelMedium),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 10, color: AppColors.navyWithOpacity(0.5)),
                          const SizedBox(width: 2),
                          Text('${auction.company} · ${auction.plant ?? auction.location ?? ''}', style: AppTextStyles.captionMuted),
                        ],
                      ),
                    ],
                  ),
                ),
                StatusChip.fromStatus(auction.status.apiValue),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.inventory_2_outlined, size: 12, color: AppColors.navyWithOpacity(0.5)),
                const SizedBox(width: 4),
                Text(
                  auction.isLotWise ? '${auction.subLots.length} sub-lots' : '${auction.quantity ?? '-'} ${auction.uom ?? ''}',
                  style: AppTextStyles.captionMuted,
                ),
                const Spacer(),
                Icon(Icons.access_time, size: 12, color: AppColors.navyWithOpacity(0.5)),
                const SizedBox(width: 4),
                Text(auction.scheduleStart ?? '—', style: AppTextStyles.captionMuted),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
