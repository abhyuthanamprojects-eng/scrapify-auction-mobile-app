import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../providers/auction_provider.dart';
import '../../widgets/cards/auction_card.dart';
import '../../widgets/shared/screen_header.dart';
import '../../widgets/shared/loading_skeleton.dart';
import '../../widgets/shared/empty_state.dart';

class AuctionsScreen extends ConsumerStatefulWidget {
  const AuctionsScreen({super.key});

  @override
  ConsumerState<AuctionsScreen> createState() => _AuctionsScreenState();
}

class _AuctionsScreenState extends ConsumerState<AuctionsScreen>
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
          ScreenHeader(
            title: 'Auctions',
            trailing: GestureDetector(
              onTap: () => _showFilterSheet(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.navyWithOpacity(0.05),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.tune, size: 16, color: AppColors.navy),
                    const SizedBox(width: 4),
                    Text('Filter', style: AppTextStyles.labelSmall),
                  ],
                ),
              ),
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
                tabs: const [Tab(text: 'Live'), Tab(text: 'Upcoming'), Tab(text: 'Ended')],
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAuctionList(segment: 'live'),
                _buildAuctionList(segment: 'upcoming'),
                _buildAuctionList(segment: 'closed'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuctionList({required String segment}) {
    final provider = auctionsProvider(AuctionFilter(segment: segment));
    final auctionsAsync = ref.watch(provider);

    return auctionsAsync.when(
      data: (auctions) {
        if (auctions.isEmpty) {
          return EmptyState(
            icon: Icons.gavel,
            title: 'No $segment auctions',
            subtitle: 'Check back later for new listings',
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenPaddingH, 16, AppSpacing.screenPaddingH, AppSpacing.bottomNavPadding,
          ),
          itemCount: auctions.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, i) {
            final auction = auctions[i];
            return AuctionCard(
              auction: auction,
              onTap: () => context.push('/lot/${auction.code}'),
              onFavorite: () => ref.read(watchlistProvider.notifier).toggle(auction.code),
              isFavorited: ref.watch(watchlistProvider).contains(auction.code),
            );
          },
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(AppSpacing.screenPaddingH),
        child: ListSkeleton(),
      ),
      error: (e, _) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Failed to load', style: AppTextStyles.caption),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => ref.invalidate(provider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _FilterSheet(),
    );
  }
}

class _FilterSheet extends StatelessWidget {
  const _FilterSheet();

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      expand: false,
      builder: (_, scrollController) => Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPaddingH),
        child: ListView(
          controller: scrollController,
          children: [
            Text('Filters', style: AppTextStyles.titleMedium),
            const SizedBox(height: 20),
            Text('Category', style: AppTextStyles.labelMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                'All', 'IT Assets', 'Mobiles', 'PCBs', 'Cables', 'Batteries', 'Appliances',
              ].map((c) => _chip(c, c == 'All')).toList(),
            ),
            const SizedBox(height: 24),
            Text('Condition', style: AppTextStyles.labelMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ['Working', 'Scrap', 'Mixed']
                  .map((c) => _chip(c, false))
                  .toList(),
            ),
            const SizedBox(height: 24),
            _sliderSection('Price Range', '₹10,000', '₹10,00,000'),
            const SizedBox(height: 16),
            _sliderSection('Weight', '0.1 MT', '50 MT'),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Reset'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Show Results'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, bool selected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? AppColors.navy : AppColors.navyWithOpacity(0.05),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: selected ? AppColors.white : AppColors.navy,
        ),
      ),
    );
  }

  Widget _sliderSection(String label, String min, String max) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelMedium),
        Slider(
          value: 0.5,
          onChanged: (_) {},
          activeColor: AppColors.auction,
          inactiveColor: AppColors.navyWithOpacity(0.1),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(min, style: AppTextStyles.captionMuted),
            Text(max, style: AppTextStyles.captionMuted),
          ],
        ),
      ],
    );
  }
}
