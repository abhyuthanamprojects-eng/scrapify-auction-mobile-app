import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../models/auction.dart';
import '../../providers/seller_provider.dart';
import '../../widgets/shared/screen_header.dart';
import '../../widgets/shared/status_chip.dart';
import '../../widgets/shared/empty_state.dart';
import '../../widgets/shared/loading_skeleton.dart';

class SellerMyAuctionsScreen extends ConsumerStatefulWidget {
  const SellerMyAuctionsScreen({super.key});

  @override
  ConsumerState<SellerMyAuctionsScreen> createState() => _SellerMyAuctionsScreenState();
}

class _SellerMyAuctionsScreenState extends ConsumerState<SellerMyAuctionsScreen> {
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    final auctionsAsync = ref.watch(sellerAuctionsProvider);
    final filters = ['all', 'pending_approval', 'sent_back', 'published', 'live', 'closed'];
    final labels = {
      'all': 'All',
      'pending_approval': 'Pending',
      'sent_back': 'Sent Back',
      'published': 'Published',
      'live': 'Live',
      'closed': 'Closed',
    };

    return Scaffold(
      backgroundColor: AppColors.appBg,
      body: Column(
        children: [
          ScreenHeader(title: 'My Auctions', onBack: () => context.pop()),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPaddingH),
              itemCount: filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (_, i) {
                final f = filters[i];
                final isActive = _filter == f;
                return GestureDetector(
                  onTap: () => setState(() => _filter = f),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.navy : AppColors.navyWithOpacity(0.05),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      labels[f] ?? f,
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: isActive ? AppColors.white : AppColors.navyWithOpacity(0.6)),
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: auctionsAsync.when(
              data: (auctions) {
                final filtered = _filter == 'all'
                    ? auctions
                    : auctions.where((a) => a.status == AuctionStatus.fromString(_filter)).toList();
                if (filtered.isEmpty) {
                  return EmptyState(
                    icon: Icons.inventory_2,
                    title: 'No auctions here',
                    subtitle: 'Create your first auction to get started',
                    actionLabel: '+ New Auction',
                    onAction: () => context.push('/seller/create-auction'),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.screenPaddingH, 12, AppSpacing.screenPaddingH, AppSpacing.bottomNavPadding),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) => _auctionCard(filtered[i]),
                );
              },
              loading: () => const Padding(padding: EdgeInsets.all(20), child: ListSkeleton()),
              error: (e, _) => Center(child: Text('$e')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _auctionCard(Auction auction) {
    return Container(
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
            crossAxisAlignment: CrossAxisAlignment.start,
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
                        Expanded(child: Text('${auction.company} · ${auction.plant ?? auction.location ?? ''}', style: AppTextStyles.captionMuted, overflow: TextOverflow.ellipsis)),
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
          if (auction.status == AuctionStatus.sentBack && auction.reviewComment != null) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.destructive.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              ),
              child: Row(
                children: [
                  Icon(Icons.message, size: 12, color: AppColors.destructive),
                  const SizedBox(width: 6),
                  Expanded(child: Text(auction.reviewComment!, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.destructive), maxLines: 1, overflow: TextOverflow.ellipsis)),
                  Icon(Icons.chevron_right, size: 14, color: AppColors.destructive),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
