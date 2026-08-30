import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/formatters.dart';
import '../../models/auction.dart';
import '../shared/status_chip.dart';

class AuctionCard extends StatelessWidget {
  final Auction auction;
  final VoidCallback onTap;
  final VoidCallback? onFavorite;
  final bool isFavorited;
  final bool compact;

  const AuctionCard({
    super.key,
    required this.auction,
    required this.onTap,
    this.onFavorite,
    this.isFavorited = false,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final isReverse = auction.direction.toLowerCase() == 'reverse';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radius2xl),
          border: Border.all(color: AppColors.cardBorder),
          boxShadow: AppColors.shadowSm,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImage(isReverse),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTagsRow(),
                  const SizedBox(height: 6),
                  Text(
                    auction.title,
                    style: AppTextStyles.heading(size: 15, weight: FontWeight.w700),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.business_outlined, size: 12, color: AppColors.navyWithOpacity(0.5)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          auction.company,
                          style: AppTextStyles.caption,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (auction.location != null) ...[
                        const SizedBox(width: 6),
                        Icon(Icons.location_on_outlined, size: 12, color: AppColors.navyWithOpacity(0.4)),
                        const SizedBox(width: 2),
                        Text(auction.location!, style: AppTextStyles.captionMuted),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildPriceAndStatusRow(isReverse),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(bool isReverse) {
    return Stack(
      children: [
        Container(
          height: compact ? 130 : 155,
          width: double.infinity,
          color: AppColors.navyWithOpacity(0.06),
          child: auction.photos.isNotEmpty
              ? Image.network(
                  auction.photos.first,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _imagePlaceholder(),
                )
              : _imagePlaceholder(),
        ),
        // Gradient overlay at top for contrast
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 50,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.blackWithOpacity(0.4), Colors.transparent],
              ),
            ),
          ),
        ),
        Positioned(
          top: 10,
          left: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
            decoration: BoxDecoration(
              color: AppColors.whiteWithOpacity(0.95),
              borderRadius: BorderRadius.circular(999),
              boxShadow: AppColors.shadowSm,
            ),
            child: Text(auction.code, style: AppTextStyles.mono),
          ),
        ),
        Positioned(
          top: 10,
          right: 10,
          child: auction.isLive
              ? StatusChip.live()
              : StatusChip.fromStatus(auction.status.name),
        ),
        if (auction.emdAmountInr > 0)
          Positioned(
            bottom: 10,
            left: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
              decoration: BoxDecoration(
                color: AppColors.navyDark.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.shield_outlined, size: 10, color: AppColors.goldSoft),
                  const SizedBox(width: 3.5),
                  Text(
                    'EMD: ${Formatters.formatINR(auction.emdAmountInr)}',
                    style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: AppColors.white),
                  ),
                ],
              ),
            ),
          ),
        if (onFavorite != null)
          Positioned(
            bottom: 10,
            right: 10,
            child: GestureDetector(
              onTap: onFavorite,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.95),
                  shape: BoxShape.circle,
                  boxShadow: AppColors.shadowSm,
                ),
                child: Icon(
                  isFavorited ? Icons.favorite : Icons.favorite_border,
                  size: 15,
                  color: isFavorited ? AppColors.destructive : AppColors.navy,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _imagePlaceholder() {
    return Center(
      child: Icon(Icons.gavel_rounded, size: 44, color: AppColors.navyWithOpacity(0.18)),
    );
  }

  Widget _buildTagsRow() {
    return Row(
      children: [
        AuctionTypeChip(direction: auction.direction, compact: true),
        if (auction.category != null) ...[
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.navy.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              auction.category!,
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                color: AppColors.navyWithOpacity(0.7),
              ),
            ),
          ),
        ],
        if (auction.isLotWise) ...[
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.auction.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              'Multi-Lot',
              style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: AppColors.auction),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPriceAndStatusRow(bool isReverse) {
    final secs = auction.secondsRemaining;
    final priceLabel = isReverse ? 'Current L1 Offer' : (auction.isLive ? 'Current Highest Bid' : 'Starting Price');
    final priceValue = auction.currentHighestInr > 0 ? auction.currentHighestInr : auction.startingPriceInr;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.appBg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                priceLabel,
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 1),
              Text(
                Formatters.formatINR(priceValue),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: isReverse ? AppColors.accentBlue : AppColors.navy,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.people_alt_outlined, size: 11, color: AppColors.navyWithOpacity(0.5)),
                  const SizedBox(width: 3),
                  Text('${auction.bidders} bids', style: AppTextStyles.captionMuted),
                ],
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.schedule, size: 11, color: secs < 600 ? AppColors.destructive : AppColors.auction),
                  const SizedBox(width: 3),
                  Text(
                    Formatters.formatCountdown(secs),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: secs < 600 ? AppColors.destructive : AppColors.auction,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

