import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/formatters.dart';
import '../../core/constants/asset_paths.dart';
import '../../models/auction.dart';
import '../../providers/auction_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../widgets/cards/wallet_card.dart';
import '../../widgets/shared/loading_skeleton.dart';
import '../../widgets/shared/empty_state.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final liveAsync = ref.watch(liveAuctionsProvider);
    final upcomingAsync = ref.watch(upcomingAuctionsProvider);
    final walletAsync = ref.watch(walletBalanceProvider);

    return Scaffold(
      backgroundColor: AppColors.appBg,
      body: CustomScrollView(
        slivers: [
          _buildHeader(
            context,
            user?.name ?? 'Guest',
            walletAsync.valueOrNull?.balanceInr ?? 0,
            user?.kycVerified ?? false,
          ),
          SliverToBoxAdapter(child: _buildSearchBar(context)),
          SliverToBoxAdapter(child: _sectionTitle('Live Auctions')),
          liveAsync.when(
            data: (auctions) => auctions.isEmpty
                ? SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: EmptyState(
                        icon: Icons.live_tv,
                        title: 'No live auctions',
                        subtitle: 'Check back soon for live auctions',
                      ),
                    ),
                  )
                : SliverToBoxAdapter(child: _buildHorizontalAuctions(context, auctions)),
            loading: () => const SliverToBoxAdapter(
              child: Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: CardSkeleton()),
            ),
            error: (e, _) => SliverToBoxAdapter(
              child: _errorWidget(e, () => ref.invalidate(liveAuctionsProvider)),
            ),
          ),
          SliverToBoxAdapter(child: _sectionTitle('Upcoming')),
          upcomingAsync.when(
            data: (auctions) => auctions.isEmpty
                ? SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: EmptyState(
                        icon: Icons.upcoming,
                        title: 'No upcoming auctions',
                        subtitle: 'New auctions will appear here',
                      ),
                    ),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => _buildListCard(context, auctions[i]),
                      childCount: auctions.length,
                    ),
                  ),
            loading: () => const SliverToBoxAdapter(child: ListSkeleton(count: 2)),
            error: (e, _) => SliverToBoxAdapter(
              child: _errorWidget(e, () => ref.invalidate(upcomingAuctionsProvider)),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.bottomNavPadding)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String name, double balance, bool kycVerified) {
    return SliverToBoxAdapter(
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
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello, ${name.split(' ').first}',
                        style: AppTextStyles.heading(size: 22, weight: FontWeight.w800, color: AppColors.white),
                      ),
                      const SizedBox(height: 2),
                      if (kycVerified)
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.success.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset(AssetPaths.iconVerified, width: 12, height: 12,
                                      errorBuilder: (_, __, ___) => Icon(Icons.verified, size: 10, color: AppColors.success)),
                                  const SizedBox(width: 4),
                                  Text('KYC Verified', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.success)),
                                ],
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => context.push('/notifications'),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.whiteWithOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    ),
                    child: const Icon(Icons.notifications_outlined, color: AppColors.white, size: 20),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            WalletCard(balance: balance, compact: true),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.screenPaddingH, 16, AppSpacing.screenPaddingH, 0),
      child: GestureDetector(
        onTap: () => context.push('/auctions'),
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(color: AppColors.blackWithOpacity(0.05)),
          ),
          child: Row(
            children: [
              Icon(Icons.search, size: 18, color: AppColors.navyWithOpacity(0.4)),
              const SizedBox(width: 8),
              Text('Search auctions, categories...', style: AppTextStyles.body(size: 14, color: AppColors.navyWithOpacity(0.4))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.screenPaddingH, 20, AppSpacing.screenPaddingH, 8),
      child: Text(title, style: AppTextStyles.titleSmall),
    );
  }

  Widget _buildHorizontalAuctions(BuildContext context, List<Auction> auctions) {
    return SizedBox(
      height: 220,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPaddingH),
        itemCount: auctions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) => _buildLiveCard(context, auctions[i]),
      ),
    );
  }

  Widget _buildLiveCard(BuildContext context, Auction auction) {
    return GestureDetector(
      onTap: () => context.push('/lot/${auction.code}'),
      child: Container(
        width: 240,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          border: Border.all(color: AppColors.blackWithOpacity(0.05)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 110,
                  width: double.infinity,
                  color: AppColors.navyWithOpacity(0.05),
                  child: auction.photos.isNotEmpty
                      ? Image.network(auction.photos.first, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _placeholder())
                      : _placeholder(),
                ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.destructive,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(width: 5, height: 5, decoration: const BoxDecoration(color: AppColors.white, shape: BoxShape.circle)),
                        const SizedBox(width: 3),
                        const Text('LIVE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.white)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(auction.title, style: AppTextStyles.labelMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text('${auction.category ?? ''} · ${auction.location ?? ''}', style: AppTextStyles.captionMuted),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(Formatters.formatINR(auction.currentHighestInr), style: AppTextStyles.priceSmall),
                      Text(
                        Formatters.formatCountdown(auction.secondsRemaining),
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.auction),
                      ),
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

  Widget _placeholder() {
    return Center(child: Icon(Icons.image, size: 32, color: AppColors.navyWithOpacity(0.15)));
  }

  Widget _buildListCard(BuildContext context, Auction auction) {
    return GestureDetector(
      onTap: () => context.push('/lot/${auction.code}'),
      child: Container(
        margin: const EdgeInsets.fromLTRB(AppSpacing.screenPaddingH, 0, AppSpacing.screenPaddingH, 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          border: Border.all(color: AppColors.blackWithOpacity(0.05)),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              child: Container(
                width: 56,
                height: 56,
                color: AppColors.navyWithOpacity(0.05),
                child: auction.photos.isNotEmpty
                    ? Image.network(auction.photos.first, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _placeholder())
                    : _placeholder(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(auction.title, style: AppTextStyles.labelMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text('${auction.category ?? ''} · ${auction.location ?? ''}', style: AppTextStyles.captionMuted),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(Formatters.formatINR(auction.currentHighestInr), style: AppTextStyles.priceSmall),
                const SizedBox(height: 2),
                Text(auction.scheduleStart ?? '', style: AppTextStyles.captionMuted),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _errorWidget(Object error, VoidCallback onRetry) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text('Failed to load', style: AppTextStyles.caption),
          const SizedBox(height: 8),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
