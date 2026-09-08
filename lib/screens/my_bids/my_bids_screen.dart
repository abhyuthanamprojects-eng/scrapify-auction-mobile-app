import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../models/my_bid.dart';
import '../../providers/bid_provider.dart';
import '../../widgets/shared/empty_state.dart';

class MyBidsScreen extends ConsumerStatefulWidget {
  const MyBidsScreen({super.key});

  @override
  ConsumerState<MyBidsScreen> createState() => _MyBidsScreenState();
}

class _MyBidsScreenState extends ConsumerState<MyBidsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bids = ref.watch(myBidsProvider);

    return Scaffold(
      backgroundColor: AppColors.appBg,
      appBar: AppBar(
        title: const Text('My Bids & Live Submissions'),
        backgroundColor: AppColors.navy,
        foregroundColor: AppColors.white,
        elevation: 0,
        bottom: bids.when(
          loading: () => _tabs(),
          error: (_, __) => _tabs(),
          data: (data) => TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: AppColors.auction,
            unselectedLabelColor: AppColors.white.withValues(alpha: 0.7),
            indicatorColor: AppColors.auction,
            indicatorWeight: 3,
            tabs: [
              Tab(text: 'All Bids (${data.active.length + data.won.length + data.lost.length})'),
              Tab(text: 'Leading (${data.active.where((b) => b.isWinning).length})'),
              Tab(text: 'Outbid (${data.active.where((b) => !b.isWinning).length})'),
              Tab(text: 'Won / Awarded (${data.won.length})'),
            ],
          ),
        ),
      ),
      body: bids.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorState(
          message: error.toString(),
          onRetry: () => ref.invalidate(myBidsProvider),
        ),
        data: (data) {
          final all = [...data.active, ...data.won, ...data.lost];
          return TabBarView(
            controller: _tabController,
            children: [
              _buildBidList(all),
              _buildBidList(data.active.where((b) => b.isWinning).toList()),
              _buildBidList(data.active.where((b) => !b.isWinning).toList()),
              _buildBidList(data.won),
            ],
          );
        },
      ),
    );
  }

  TabBar _tabs() => const TabBar(
        tabs: [
          Tab(text: 'All Bids'),
          Tab(text: 'Leading'),
          Tab(text: 'Outbid'),
          Tab(text: 'Won / Awarded'),
        ],
      );

  Widget _buildBidList(List<MyBid> bids) {
    if (bids.isEmpty) {
      return const Center(
        child: EmptyState(
          icon: Icons.gavel_rounded,
          title: 'No bids found',
          subtitle: 'Participate in an eligible auction to track your bids here.',
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      itemCount: bids.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _bidCard(context, bids[index]),
    );
  }

  Widget _bidCard(BuildContext context, MyBid bid) {
    final live = bid.status.toLowerCase() == 'live';
    final winning = bid.isWinning;
    final statusColor = winning ? AppColors.success : AppColors.auction;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radius2xl),
        border: Border.all(
          color: winning ? AppColors.success.withValues(alpha: 0.5) : AppColors.cardBorder,
        ),
        boxShadow: AppColors.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(bid.status.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: statusColor)),
              Text(bid.result, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: statusColor)),
            ],
          ),
          const SizedBox(height: 10),
          Text(bid.title, style: AppTextStyles.heading(size: 14.5, weight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text('${bid.auctionId} • ${bid.bidCount} bid${bid.bidCount == 1 ? '' : 's'}', style: AppTextStyles.captionMuted),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.appBg, borderRadius: BorderRadius.circular(AppSpacing.radiusLg)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _price('YOUR LAST BID', bid.myBidInr),
                _price('CURRENT PRICE', bid.currentInr, alignEnd: true, color: statusColor),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.push(live ? '/live/${bid.auctionId}' : '/auctions'),
              style: ElevatedButton.styleFrom(
                backgroundColor: live ? statusColor : AppColors.navy,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusLg)),
              ),
              child: Text(live ? 'Open Auction' : 'View Auction', style: const TextStyle(fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _price(String label, double value, {bool alignEnd = false, Color? color}) {
    return Column(
      crossAxisAlignment: alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontFamily: 'monospace', fontSize: 9.5, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
        Text(Formatters.formatINR(value), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: color ?? AppColors.navy)),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 42, color: AppColors.destructive),
            const SizedBox(height: 12),
            const Text('Unable to load your bids', style: TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text(message, textAlign: TextAlign.center, style: AppTextStyles.captionMuted),
            const SizedBox(height: 14),
            OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
