import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/formatters.dart';
import '../../core/constants/app_constants.dart';
import '../../models/auction.dart';
import '../../models/award.dart';
import '../../providers/auction_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../providers/domain_providers.dart';
import '../../widgets/cards/auction_card.dart';
import '../../widgets/shared/status_chip.dart';
import '../../widgets/shared/loading_skeleton.dart';
import '../../widgets/shared/empty_state.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final liveAsync = ref.watch(liveAuctionsProvider);
    final upcomingAsync = ref.watch(upcomingAuctionsProvider);
    final walletAsync = ref.watch(walletBalanceProvider);
    final awards = ref.watch(awardsProvider);

    final pendingAwardCount = awards.where((a) => a.status == AwardStatus.offered || a.status == AwardStatus.fallbackOffered).length;
    final featuredAuction = liveAsync.valueOrNull?.where((a) => a.isLotWise).firstOrNull ??
        liveAsync.valueOrNull?.firstOrNull ??
        upcomingAsync.valueOrNull?.firstOrNull;

    return Scaffold(
      backgroundColor: AppColors.appBg,
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(authProvider.notifier).refreshUser();
          ref.invalidate(liveAuctionsProvider);
          ref.invalidate(upcomingAuctionsProvider);
          ref.invalidate(walletBalanceProvider);
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            _buildTopHero(
              context,
              name: user?.name ?? 'Rahul Sharma',
              company: user?.companyName ?? 'Devzign Solutions Pvt Ltd',
              balance: walletAsync.valueOrNull?.balanceInr ?? 42850,
              kycVerified: user?.kycVerified ?? true,
            ),
            if (user?.isKycPending == true)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                  child: _buildKycPendingBanner(context),
                ),
              ),
            if (user?.isKycRejected == true)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                  child: _buildKycRejectedBanner(context, user?.rejectionReason),
                ),
              ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: _buildSearchBar(context),
              ),
            ),
            if (pendingAwardCount > 0)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                  child: _buildActionRequiredBanner(context, pendingAwardCount),
                ),
              ),
            if (featuredAuction != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: _buildFeaturedMultiLotCard(context, featuredAuction),
                ),
              ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 18),
                child: _buildCategoryTabs(),
              ),
            ),
            SliverToBoxAdapter(
              child: _buildSectionHeader(
                title: 'Live Auctions',
                badge: StatusChip.live(),
                onSeeAll: () => context.push('/auctions'),
              ),
            ),
            liveAsync.when(
              data: (auctions) {
                final filtered = _selectedCategory == null
                    ? auctions
                    : auctions.where((a) => a.category == _selectedCategory).toList();
                if (filtered.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: EmptyState(
                        icon: Icons.gavel_rounded,
                        title: 'No live auctions right now',
                        subtitle: 'Check back in a few minutes or browse upcoming events',
                      ),
                    ),
                  );
                }
                return SliverToBoxAdapter(
                  child: _buildHorizontalLiveCarousel(context, filtered),
                );
              },
              loading: () => const SliverToBoxAdapter(
                child: Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: CardSkeleton()),
              ),
              error: (_, __) => const SliverToBoxAdapter(child: SizedBox.shrink()),
            ),
            SliverToBoxAdapter(
              child: _buildSectionHeader(
                title: 'Upcoming & Invited Events',
                onSeeAll: () => context.push('/auctions'),
              ),
            ),
            upcomingAsync.when(
              data: (auctions) {
                final filtered = _selectedCategory == null
                    ? auctions
                    : auctions.where((a) => a.category == _selectedCategory).toList();
                if (filtered.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: EmptyState(
                        icon: Icons.calendar_today_outlined,
                        title: 'No upcoming events',
                        subtitle: 'You are all caught up with scheduled auctions',
                      ),
                    ),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: AuctionCard(
                          auction: filtered[i],
                          onTap: () => context.push(
                            filtered[i].direction == 'reverse'
                                ? '/live-reverse/${filtered[i].code}'
                                : '/lot/${filtered[i].code}',
                          ),
                        ),
                      ),
                      childCount: filtered.length,
                    ),
                  ),
                );
              },
              loading: () => const SliverToBoxAdapter(
                child: Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: ListSkeleton(count: 2)),
              ),
              error: (_, __) => const SliverToBoxAdapter(child: SizedBox.shrink()),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildTopHero(
    BuildContext context, {
    required String name,
    required String company,
    required double balance,
    required bool kycVerified,
  }) {
    return SliverToBoxAdapter(
      child: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.gradientNoir,
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
        ),
        padding: EdgeInsets.fromLTRB(
          20,
          MediaQuery.of(context).padding.top + 14,
          20,
          24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'GOOD MORNING',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.goldSoft.withValues(alpha: 0.8),
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      name,
                      style: AppTextStyles.heading(size: 21, weight: FontWeight.w800, color: AppColors.white),
                    ),
                    Text(
                      company,
                      style: TextStyle(fontSize: 11.5, color: AppColors.white.withValues(alpha: 0.65)),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => context.push('/notifications'),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                      border: Border.all(color: AppColors.white.withValues(alpha: 0.12)),
                    ),
                    child: Stack(
                      children: [
                        const Center(
                          child: Icon(Icons.notifications_outlined, color: AppColors.white, size: 22),
                        ),
                        Positioned(
                          top: 10,
                          right: 10,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.auction,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => context.push('/reg-status'),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: kycVerified
                      ? AppColors.success.withValues(alpha: 0.15)
                      : AppColors.auction.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: kycVerified
                        ? AppColors.success.withValues(alpha: 0.35)
                        : AppColors.auction.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      kycVerified ? Icons.verified : Icons.hourglass_top,
                      size: 13,
                      color: kycVerified ? AppColors.success : AppColors.goldSoft,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      kycVerified ? 'KYC — Verified (4/4 Docs)' : 'KYC — Verification Pending',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: kycVerified ? AppColors.success : AppColors.goldSoft,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: AppColors.gradientGold,
                borderRadius: BorderRadius.circular(AppSpacing.radius2xl),
                boxShadow: AppColors.shadowGold,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.account_balance_wallet_outlined, size: 14, color: AppColors.white),
                            const SizedBox(width: 5),
                            Text(
                              'EMD WALLET BALANCE',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.white.withValues(alpha: 0.85),
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          Formatters.formatINR(balance),
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: AppColors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Security available for 4 live auctions',
                          style: TextStyle(fontSize: 10.5, color: AppColors.white.withValues(alpha: 0.8)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () => context.push('/wallet'),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add Money'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.navy,
                      foregroundColor: AppColors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/auctions'),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          border: Border.all(color: AppColors.cardBorder),
          boxShadow: AppColors.shadowSm,
        ),
        child: Row(
          children: [
            const Icon(Icons.search, size: 20, color: Color(0xFF64748B)),
            const SizedBox(width: 10),
            Text(
              'Search auctions, lots, categories, cities...',
              style: TextStyle(fontSize: 13.5, color: AppColors.navyWithOpacity(0.45)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionRequiredBanner(BuildContext context, int pendingCount) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.warningLight,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.gavel_rounded, color: AppColors.warning, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Action Required: Award Acceptance',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.navy),
                ),
                Text(
                  'You have $pendingCount winning award(s) awaiting acceptance.',
                  style: TextStyle(fontSize: 11, color: AppColors.navy.withValues(alpha: 0.7)),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => context.push('/awards'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.navy,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
            ),
            child: const Text('Review', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedMultiLotCard(BuildContext context, Auction auction) {
    final isMultiLot = auction.isLotWise;
    final highest = auction.currentHighestInr > 0 ? auction.currentHighestInr : auction.startingPriceInr;
    final leadText = auction.currentHighestInr > 0 ? 'Lead: ${Formatters.formatINR(highest)}' : 'Starts: ${Formatters.formatINR(highest)}';

    return GestureDetector(
      onTap: () => context.push(
        auction.direction == 'reverse'
            ? '/live-reverse/${auction.code}'
            : (auction.isLive ? '/live/${auction.code}' : '/lot/${auction.code}'),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F2648), Color(0xFF06132A)],
          ),
          borderRadius: BorderRadius.circular(AppSpacing.radius2xl),
          boxShadow: AppColors.shadowSm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.auction.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    isMultiLot ? 'FEATURED • MULTI-LOT' : 'FEATURED AUCTION',
                    style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: AppColors.goldSoft),
                  ),
                ),
                auction.isLive ? StatusChip.live() : StatusChip.fromStatus(auction.status.name),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              auction.company.isNotEmpty ? '${auction.company} • ${auction.title}' : auction.title,
              style: AppTextStyles.heading(size: 15, weight: FontWeight.w800, color: AppColors.white),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              isMultiLot
                  ? 'Bid on individual sub-lots or complete lot bundle'
                  : (auction.category ?? 'High-value industrial materials'),
              style: TextStyle(fontSize: 11.5, color: AppColors.white.withValues(alpha: 0.7)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$leadText  •  ${auction.bidders} Bids',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.goldSoft),
                ),
                Row(
                  children: [
                    Text(
                      auction.isLive ? 'Enter Live' : 'View Details',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.white.withValues(alpha: 0.9)),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_forward, size: 14, color: AppColors.white),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: AppConstants.categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (ctx, i) {
          final cat = AppConstants.categories[i];
          final isAll = cat == 'All Categories';
          final isSelected = isAll ? _selectedCategory == null : _selectedCategory == cat;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = isAll ? null : cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.navy : AppColors.white,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: isSelected ? AppColors.navy : AppColors.cardBorder),
                boxShadow: isSelected ? AppColors.shadowSm : null,
              ),
              child: Center(
                child: Text(
                  cat,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected ? AppColors.white : AppColors.navy,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    Widget? badge,
    required VoidCallback onSeeAll,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(title, style: AppTextStyles.heading(size: 16, weight: FontWeight.w800)),
              if (badge != null) ...[
                const SizedBox(width: 8),
                badge,
              ],
            ],
          ),
          GestureDetector(
            onTap: onSeeAll,
            child: Text(
              'See all',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: AppColors.accentBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalLiveCarousel(BuildContext context, List<Auction> auctions) {
    return SizedBox(
      height: 320,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: auctions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (ctx, i) {
          final a = auctions[i];
          return SizedBox(
            width: 275,
            child: AuctionCard(
              auction: a,
              compact: true,
              onTap: () => context.push(
                a.direction == 'reverse'
                    ? '/live-reverse/${a.code}'
                    : '/live/${a.code}',
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildKycPendingBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.auction.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(color: AppColors.auction.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.auction.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.hourglass_top_rounded, color: AppColors.auction, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Verification Pending',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.navy),
                ),
                const SizedBox(height: 3),
                Text(
                  'Your KYC and submitted documents are currently under review by our verification team (usually 24–48 hours). Once verified, full auction bidding is activated.',
                  style: TextStyle(fontSize: 12, color: AppColors.navy.withValues(alpha: 0.75), height: 1.35),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => context.push('/reg-status'),
                  child: const Text(
                    'Track Verification Status →',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.auction),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKycRejectedBanner(BuildContext context, String? reason) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.destructive.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(color: AppColors.destructive.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.destructive.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.warning_amber_rounded, color: AppColors.destructive, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Verification Requires Changes',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.destructive),
                ),
                const SizedBox(height: 3),
                Text(
                  reason != null && reason.isNotEmpty
                      ? 'Compliance Remarks: $reason'
                      : 'Your KYC application was not approved. Please review the remarks and resubmit.',
                  style: TextStyle(fontSize: 12, color: AppColors.navy.withValues(alpha: 0.75), height: 1.35),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => context.push('/vendor-onboarding'),
                  child: const Text(
                    'Edit & Resubmit KYC →',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.destructive),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
