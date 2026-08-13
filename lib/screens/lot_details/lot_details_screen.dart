import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/formatters.dart';
import '../../providers/auction_provider.dart';
import '../../providers/bid_provider.dart';
import '../../models/auction.dart';
import '../../widgets/shared/status_chip.dart';
import '../../widgets/shared/countdown_timer.dart';
import '../../widgets/shared/loading_skeleton.dart';

class LotDetailsScreen extends ConsumerWidget {
  final String lotId;
  const LotDetailsScreen({super.key, required this.lotId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auctionAsync = ref.watch(auctionDetailProvider(lotId));

    return auctionAsync.when(
      data: (auction) => _AuctionDetailsBody(auction: auction),
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.auction)),
      ),
      error: (e, _) => Scaffold(
        body: Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _AuctionDetailsBody extends ConsumerWidget {
  final Auction auction;
  const _AuctionDetailsBody({required this.auction});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bidsAsync = ref.watch(bidHistoryProvider(auction.code));

    return Scaffold(
      backgroundColor: AppColors.appBg,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildImageHeader(context),
              SliverToBoxAdapter(child: _buildInfo()),
              if (auction.isLive) SliverToBoxAdapter(child: _buildLiveBidCard()),
              SliverToBoxAdapter(child: _buildFactsGrid()),
              SliverToBoxAdapter(child: _buildBidHistory(bidsAsync)),
              SliverToBoxAdapter(child: _buildEmdNotice()),
              if (auction.contact != null) SliverToBoxAdapter(child: _buildContactInfo()),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
          if (auction.isLive) _buildStickyBottom(context),
        ],
      ),
    );
  }

  Widget _buildImageHeader(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 240,
      pinned: true,
      backgroundColor: AppColors.navy,
      leading: GestureDetector(
        onTap: () => context.pop(),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.whiteWithOpacity(0.95),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back, size: 18, color: AppColors.navy),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.whiteWithOpacity(0.95),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(auction.code, style: AppTextStyles.labelTiny),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          color: AppColors.navyWithOpacity(0.1),
          child: auction.photos.isNotEmpty
              ? PageView.builder(
                  itemCount: auction.photos.length,
                  itemBuilder: (_, i) => Image.network(
                    auction.photos[i],
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        Center(child: Icon(Icons.image, size: 48, color: AppColors.navyWithOpacity(0.2))),
                  ),
                )
              : Center(child: Icon(Icons.image, size: 48, color: AppColors.navyWithOpacity(0.2))),
        ),
      ),
    );
  }

  Widget _buildInfo() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.screenPaddingH),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (auction.category != null) _categoryChip(auction.category!),
              if (auction.materialType != null) ...[
                const SizedBox(width: 6),
                _categoryChip(auction.materialType!),
              ],
              const Spacer(),
              if (auction.isLive) StatusChip.live(),
            ],
          ),
          const SizedBox(height: 8),
          Text(auction.title, style: AppTextStyles.titleLarge),
          const SizedBox(height: 4),
          Text(
            '${auction.company} · ${auction.location ?? ''}',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.navyWithOpacity(0.7), height: 1.5,
            ),
          ),
          if (auction.terms != null) ...[
            const SizedBox(height: 8),
            Text(auction.terms!, style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.navyWithOpacity(0.6), height: 1.4,
            )),
          ],
        ],
      ),
    );
  }

  Widget _categoryChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.accentBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.accentBlue),
      ),
    );
  }

  Widget _buildLiveBidCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPaddingH),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(color: AppColors.auction.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('CURRENT BID', style: AppTextStyles.labelTiny.copyWith(
                    color: AppColors.navyWithOpacity(0.5),
                  )),
                  const SizedBox(height: 2),
                  Text(Formatters.formatINR(auction.currentHighestInr), style: AppTextStyles.priceLarge),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('ENDS IN', style: AppTextStyles.labelTiny.copyWith(
                    color: AppColors.navyWithOpacity(0.5),
                  )),
                  const SizedBox(height: 2),
                  CountdownTimer(initialSeconds: auction.secondsRemaining),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.people_outline, size: 12, color: AppColors.navyWithOpacity(0.5)),
              const SizedBox(width: 4),
              Text('${auction.bidders} bidders', style: AppTextStyles.captionMuted),
              const Spacer(),
              Text(
                auction.isForward ? 'Forward Auction' : 'Reverse Auction',
                style: AppTextStyles.labelTiny.copyWith(color: AppColors.accentBlue),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFactsGrid() {
    final facts = [
      ('Quantity', auction.quantity ?? '-', Icons.scale),
      ('Location', auction.location ?? '-', Icons.location_on_outlined),
      ('Material', auction.materialType ?? '-', Icons.info_outline),
      ('EMD', Formatters.formatINR(auction.emdAmountInr), Icons.account_balance_wallet_outlined),
    ];
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.screenPaddingH),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 2.5,
        children: facts.map((f) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.navyWithOpacity(0.03),
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
          child: Row(
            children: [
              Icon(f.$3, size: 16, color: AppColors.navyWithOpacity(0.4)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(f.$1, style: AppTextStyles.captionMuted),
                    Text(f.$2, style: AppTextStyles.labelMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildBidHistory(AsyncValue bidsAsync) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPaddingH),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Bid History', style: AppTextStyles.titleSmall),
          const SizedBox(height: 8),
          bidsAsync.when(
            data: (bids) => Column(
              children: (bids as List).take(5).map((b) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.navyWithOpacity(0.05),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          b.vendorName.isNotEmpty ? b.vendorName[0] : '?',
                          style: AppTextStyles.labelMedium,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(b.vendorName, style: AppTextStyles.labelSmall),
                          Text(Formatters.timeAgo(b.at), style: AppTextStyles.captionMuted),
                        ],
                      ),
                    ),
                    Text(
                      Formatters.formatINR(b.amountInr),
                      style: AppTextStyles.priceSmall,
                    ),
                  ],
                ),
              )).toList(),
            ),
            loading: () => const LoadingSkeleton(height: 100),
            error: (_, __) => const Text('Failed to load bids'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmdNotice() {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.screenPaddingH),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.auction.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.auction.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 16, color: AppColors.auction),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'EMD of ${Formatters.formatINR(auction.emdAmountInr)} required to place a bid',
              style: AppTextStyles.caption.copyWith(color: AppColors.auction),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo() {
    final c = auction.contact!;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPaddingH),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(color: AppColors.blackWithOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.navyWithOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Center(child: Text(c.name?[0] ?? 'C', style: AppTextStyles.labelLarge)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.name ?? 'Contact', style: AppTextStyles.labelMedium),
                if (c.phone != null || c.email != null)
                  Text(c.phone ?? c.email ?? '', style: AppTextStyles.captionMuted),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStickyBottom(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.screenPaddingH,
          12,
          AppSpacing.screenPaddingH,
          MediaQuery.of(context).padding.bottom + 12,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border(top: BorderSide(color: AppColors.blackWithOpacity(0.05))),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Current Bid', style: AppTextStyles.captionMuted),
                  Text(Formatters.formatINR(auction.currentHighestInr), style: AppTextStyles.priceMedium),
                ],
              ),
            ),
            SizedBox(
              height: AppSpacing.buttonXl,
              child: ElevatedButton.icon(
                onPressed: () => context.push('/live/${auction.code}'),
                icon: const Icon(Icons.gavel, size: 18),
                label: const Text('Place Bid'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
