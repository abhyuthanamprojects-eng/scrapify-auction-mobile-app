import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/formatters.dart';
import '../../providers/bid_provider.dart';
import '../../models/my_bid.dart';
import '../../widgets/shared/status_chip.dart';
import '../../widgets/shared/empty_state.dart';
import '../../widgets/shared/loading_skeleton.dart';

class MyBidsScreen extends ConsumerStatefulWidget {
  const MyBidsScreen({super.key});

  @override
  ConsumerState<MyBidsScreen> createState() => _MyBidsScreenState();
}

class _MyBidsScreenState extends ConsumerState<MyBidsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBg,
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.screenPaddingH,
              MediaQuery.of(context).padding.top + 16,
              AppSpacing.screenPaddingH,
              8,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('My Bids', style: AppTextStyles.titleLarge),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPaddingH),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.navyWithOpacity(0.05),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: AppColors.white,
                unselectedLabelColor: AppColors.navyWithOpacity(0.6),
                labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                unselectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                indicator: BoxDecoration(
                  color: AppColors.navy,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerHeight: 0,
                tabs: const [Tab(text: 'Active'), Tab(text: 'Won'), Tab(text: 'Lost')],
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildBidList('active'),
                _buildBidList('won'),
                _buildBidList('lost'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBidList(String tab) {
    final bidsAsync = ref.watch(myBidsProvider);
    return bidsAsync.when(
      data: (data) {
        final List<MyBid> bids;
        switch (tab) {
          case 'active':
            bids = data.active;
          case 'won':
            bids = data.won;
          case 'lost':
            bids = data.lost;
          default:
            bids = [];
        }

        if (bids.isEmpty) {
          return EmptyState(
            icon: tab == 'won' ? Icons.emoji_events : (tab == 'lost' ? Icons.sentiment_neutral : Icons.gavel),
            title: 'No $tab bids',
            subtitle: 'Your $tab bids will appear here',
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenPaddingH, 12, AppSpacing.screenPaddingH, AppSpacing.bottomNavPadding,
          ),
          itemCount: bids.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) => _bidCard(bids[i]),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(AppSpacing.screenPaddingH),
        child: ListSkeleton(count: 2),
      ),
      error: (e, _) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Failed to load', style: AppTextStyles.caption),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => ref.invalidate(myBidsProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bidCard(MyBid bid) {
    return GestureDetector(
      onTap: () => context.push('/lot/${bid.auctionId}'),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          border: Border.all(color: AppColors.blackWithOpacity(0.05)),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.navyWithOpacity(0.05),
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              ),
              child: Center(
                child: Icon(
                  bid.isWinning ? Icons.emoji_events : Icons.gavel,
                  size: 24,
                  color: bid.isWinning ? AppColors.auction : AppColors.navyWithOpacity(0.3),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(bid.title, style: AppTextStyles.labelMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text('${bid.bidCount} bids · ${bid.status}', style: AppTextStyles.captionMuted),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text('Your bid: ${Formatters.formatINR(bid.myBidInr)}', style: AppTextStyles.labelSmall),
                      const Spacer(),
                      StatusChip.fromStatus(bid.result.toLowerCase()),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
