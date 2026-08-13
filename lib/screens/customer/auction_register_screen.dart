import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/formatters.dart';
import '../../widgets/shared/screen_header.dart';
import 'emd_pay_sheet.dart';

class AuctionParticipation {
  final String auctionId;
  final String auctionTitle;
  final String company;
  final String plant;
  final String auctionStatus; // 'scheduled' | 'live' | 'closed'
  final double emdAmount;
  final double? reservePrice;
  final String emdStatus; // 'not_registered' | 'not_paid' | 'pending' | 'confirmed'
  final String? reference;
  final String? paidAt;

  const AuctionParticipation({
    required this.auctionId,
    required this.auctionTitle,
    required this.company,
    required this.plant,
    required this.auctionStatus,
    required this.emdAmount,
    this.reservePrice,
    this.emdStatus = 'not_registered',
    this.reference,
    this.paidAt,
  });

  double get emdPercent {
    if (reservePrice != null && reservePrice! > 0) {
      final pct = (emdAmount / reservePrice!) * 100;
      return pct < 1 ? 1 : (pct * 10).round() / 10;
    }
    return 10;
  }
}

class AuctionRegisterScreen extends StatefulWidget {
  final List<AuctionParticipation> auctions;
  final bool isApproved;
  final VoidCallback onBack;
  final void Function(String auctionId)? onRegister;
  final void Function(String auctionId)? onEnterLive;
  final void Function(String auctionId, String mode, String reference)? onEmdPaid;

  const AuctionRegisterScreen({
    super.key,
    required this.auctions,
    required this.isApproved,
    required this.onBack,
    this.onRegister,
    this.onEnterLive,
    this.onEmdPaid,
  });

  @override
  State<AuctionRegisterScreen> createState() => _AuctionRegisterScreenState();
}

class _AuctionRegisterScreenState extends State<AuctionRegisterScreen> {
  static const _statusLabels = {
    'scheduled': 'Scheduled',
    'live': 'Live',
    'closed': 'Closed',
  };

  static const _emdLabels = {
    'not_registered': 'Not registered',
    'not_paid': 'EMD not paid',
    'pending': 'EMD pending',
    'confirmed': 'EMD confirmed',
  };

  void _showPaySheet(AuctionParticipation auction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EmdPaySheet(
        auctionTitle: auction.auctionTitle,
        emdAmount: auction.emdAmount,
        emdPercent: auction.emdPercent,
        onPay: (mode, reference) {
          widget.onEmdPaid?.call(auction.auctionId, mode, reference);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBg,
      body: Column(
        children: [
          ScreenHeader(
            title: 'Auction participation',
            subtitle: 'Register & pay EMD',
            onBack: widget.onBack,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPaddingH,
                0,
                AppSpacing.screenPaddingH,
                AppSpacing.bottomNavPadding,
              ),
              children: [
                if (!widget.isApproved) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.auctionWithOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                      border: Border.all(color: AppColors.auctionWithOpacity(0.25)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.lock, size: 15, color: AppColors.auction),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Only approved vendors can register for auctions.',
                            style: AppTextStyles.body(
                              size: 12,
                              weight: FontWeight.w600,
                              color: AppColors.auction,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                ...widget.auctions.map((a) => _buildAuctionCard(a)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuctionCard(AuctionParticipation a) {
    final emdStatusColor = a.emdStatus == 'confirmed'
        ? AppColors.success
        : a.emdStatus == 'pending'
            ? AppColors.auction
            : AppColors.navyWithOpacity(0.6);
    final emdStatusBg = a.emdStatus == 'confirmed'
        ? AppColors.successWithOpacity(0.1)
        : a.emdStatus == 'pending'
            ? AppColors.auctionWithOpacity(0.1)
            : AppColors.navyWithOpacity(0.05);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          border: Border.all(color: AppColors.blackWithOpacity(0.05)),
          boxShadow: [
            BoxShadow(
              color: AppColors.blackWithOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(a.auctionId, style: AppTextStyles.mono),
                      Text(
                        a.auctionTitle,
                        style: AppTextStyles.body(size: 14, weight: FontWeight.w700, color: AppColors.navy),
                      ),
                      Text(
                        '${a.company} • ${a.plant}',
                        style: AppTextStyles.body(
                          size: 11,
                          color: AppColors.navyWithOpacity(0.55),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.navyWithOpacity(0.05),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  ),
                  child: Text(
                    _statusLabels[a.auctionStatus] ?? a.auctionStatus,
                    style: AppTextStyles.body(size: 10, weight: FontWeight.w700, color: AppColors.navy),
                  ),
                ),
              ],
            ),

            // EMD required
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.appBg,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'EMD REQUIRED',
                        style: AppTextStyles.body(
                          size: 10,
                          color: AppColors.navyWithOpacity(0.5),
                        ).copyWith(letterSpacing: 0.5),
                      ),
                      Text(
                        Formatters.formatINR(a.emdAmount),
                        style: AppTextStyles.body(size: 16, weight: FontWeight.w800, color: AppColors.navy),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accentBlueWithOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                    ),
                    child: Text(
                      '${a.emdPercent}% of reserve',
                      style: AppTextStyles.body(
                        size: 11,
                        weight: FontWeight.w700,
                        color: AppColors.accentBlue,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // EMD status + action
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: emdStatusBg,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  ),
                  child: Text(
                    _emdLabels[a.emdStatus] ?? a.emdStatus,
                    style: AppTextStyles.body(size: 11, weight: FontWeight.w700, color: emdStatusColor),
                  ),
                ),
                const Spacer(),
                if (a.emdStatus == 'not_registered')
                  _actionButton(
                    label: 'Register for this auction',
                    color: AppColors.navy,
                    textColor: AppColors.white,
                    enabled: widget.isApproved,
                    onTap: () => widget.onRegister?.call(a.auctionId),
                  ),
                if (a.emdStatus == 'not_paid')
                  _actionButton(
                    label: 'Pay EMD',
                    color: AppColors.auction,
                    textColor: AppColors.white,
                    onTap: () => _showPaySheet(a),
                  ),
                if (a.emdStatus == 'confirmed' && a.auctionStatus == 'live')
                  _actionButton(
                    label: 'Enter live room',
                    color: AppColors.success,
                    textColor: AppColors.white,
                    onTap: () => widget.onEnterLive?.call(a.auctionId),
                  ),
              ],
            ),

            // Reference
            if (a.reference != null) ...[
              const SizedBox(height: 8),
              Text(
                'Ref ${a.reference} • ${a.paidAt ?? ''}',
                style: AppTextStyles.mono,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required Color color,
    required Color textColor,
    bool enabled = true,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.4,
        child: Container(
          height: AppSpacing.buttonMd,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTextStyles.body(size: 12, weight: FontWeight.w700, color: textColor),
          ),
        ),
      ),
    );
  }
}
