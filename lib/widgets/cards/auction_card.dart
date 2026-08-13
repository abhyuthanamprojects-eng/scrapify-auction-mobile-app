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

  const AuctionCard({
    super.key,
    required this.auction,
    required this.onTap,
    this.onFavorite,
    this.isFavorited = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          border: Border.all(color: AppColors.blackWithOpacity(0.05)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImage(),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.cardPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCategoryRow(),
                  const SizedBox(height: 4),
                  Text(
                    auction.title,
                    style: AppTextStyles.labelLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${auction.company} · ${auction.materialType ?? auction.category ?? ''}',
                    style: AppTextStyles.caption,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  _buildBottomRow(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    return Stack(
      children: [
        Container(
          height: 160,
          width: double.infinity,
          color: AppColors.navyWithOpacity(0.05),
          child: auction.photos.isNotEmpty
              ? Image.network(
                  auction.photos.first,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _imagePlaceholder(),
                )
              : _imagePlaceholder(),
        ),
        Positioned(
          top: 8,
          left: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.whiteWithOpacity(0.95),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(auction.code, style: AppTextStyles.labelTiny),
          ),
        ),
        if (auction.isLive)
          Positioned(
            top: 8,
            right: 8,
            child: StatusChip.live(),
          ),
        if (onFavorite != null)
          Positioned(
            bottom: 8,
            right: 8,
            child: GestureDetector(
              onTap: onFavorite,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.whiteWithOpacity(0.95),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isFavorited ? Icons.favorite : Icons.favorite_border,
                  size: 16,
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
      child: Icon(Icons.image, size: 40, color: AppColors.navyWithOpacity(0.2)),
    );
  }

  Widget _buildCategoryRow() {
    return Row(
      children: [
        if (auction.category != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.accentBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              auction.category!,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.accentBlue,
              ),
            ),
          ),
        const SizedBox(width: 6),
        Text(
          auction.location ?? '',
          style: AppTextStyles.captionMuted,
        ),
      ],
    );
  }

  Widget _buildBottomRow() {
    final secs = auction.secondsRemaining;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Current bid', style: AppTextStyles.captionMuted),
            Text(
              Formatters.formatINR(auction.currentHighestInr),
              style: AppTextStyles.priceMedium,
            ),
          ],
        ),
        Row(
          children: [
            Icon(Icons.people_outline, size: 12, color: AppColors.navyWithOpacity(0.5)),
            const SizedBox(width: 4),
            Text(
              '${auction.bidders}',
              style: AppTextStyles.captionMuted,
            ),
            const SizedBox(width: 12),
            Icon(Icons.access_time, size: 12, color: AppColors.navyWithOpacity(0.5)),
            const SizedBox(width: 4),
            Text(
              Formatters.formatCountdown(secs),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: secs < 300 ? AppColors.destructive : AppColors.auction,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
