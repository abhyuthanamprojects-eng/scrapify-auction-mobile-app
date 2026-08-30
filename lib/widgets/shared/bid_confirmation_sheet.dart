import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/formatters.dart';

class BidConfirmationSheet extends StatefulWidget {
  final String auctionTitle;
  final String auctionCode;
  final double bidAmount;
  final double currentAmount;
  final double increment;
  final bool isReverse;
  final VoidCallback onConfirm;

  const BidConfirmationSheet({
    super.key,
    required this.auctionTitle,
    required this.auctionCode,
    required this.bidAmount,
    required this.currentAmount,
    required this.increment,
    this.isReverse = false,
    required this.onConfirm,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String auctionTitle,
    required String auctionCode,
    required double bidAmount,
    required double currentAmount,
    required double increment,
    bool isReverse = false,
    required VoidCallback onConfirm,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BidConfirmationSheet(
        auctionTitle: auctionTitle,
        auctionCode: auctionCode,
        bidAmount: bidAmount,
        currentAmount: currentAmount,
        increment: increment,
        isReverse: isReverse,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  State<BidConfirmationSheet> createState() => _BidConfirmationSheetState();
}

class _BidConfirmationSheetState extends State<BidConfirmationSheet> {
  bool _agreed = true;
  bool _submitting = false;

  bool get _isHighValue => widget.bidAmount >= 1000000; // Above 10 Lakhs INR

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        14,
        20,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.navyWithOpacity(0.15),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Header
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: (widget.isReverse ? AppColors.accentBlue : AppColors.auction).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  ),
                  child: Icon(
                    widget.isReverse ? Icons.trending_down : Icons.gavel_rounded,
                    size: 20,
                    color: widget.isReverse ? AppColors.accentBlue : AppColors.auction,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.isReverse ? 'Confirm Your Offer' : 'Confirm Your Bid',
                        style: AppTextStyles.heading(size: 17, weight: FontWeight.w800),
                      ),
                      Text(
                        '${widget.auctionCode} • ${widget.auctionTitle}',
                        style: AppTextStyles.captionMuted,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            // Amount Highlight Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: widget.isReverse ? AppColors.gradientReverse : AppColors.gradientNoir,
                borderRadius: BorderRadius.circular(AppSpacing.radius2xl),
                boxShadow: AppColors.shadowNoir,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.isReverse ? 'OFFER AMOUNT TO SUBMIT' : 'YOUR NEW BID AMOUNT',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.white.withValues(alpha: 0.7),
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    Formatters.formatINR(widget.bidAmount),
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: AppColors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.isReverse ? 'Current Lowest L1:' : 'Previous Highest:',
                          style: TextStyle(fontSize: 11, color: AppColors.white.withValues(alpha: 0.8)),
                        ),
                        Text(
                          Formatters.formatINR(widget.currentAmount),
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (_isHighValue) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warningLight,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.shield_outlined, color: AppColors.warning, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'High Value Event Verification',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.navy),
                          ),
                          Text(
                            'Bids above ₹10,00,000 are legally binding upon auction closure.',
                            style: TextStyle(fontSize: 10.5, color: AppColors.navy.withValues(alpha: 0.7)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 14),
            Row(
              children: [
                Checkbox.adaptive(
                  value: _agreed,
                  activeColor: AppColors.auction,
                  onChanged: (v) => setState(() => _agreed = v ?? false),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _agreed = !_agreed),
                    child: Text(
                      'I agree to the auction terms and acknowledge this bid is final.',
                      style: AppTextStyles.body(size: 11.5, weight: FontWeight.w500),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppColors.cardBorder),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                      ),
                    ),
                    child: Text('Cancel', style: AppTextStyles.labelLarge.copyWith(color: AppColors.navy)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: (!_agreed || _submitting)
                        ? null
                        : () async {
                            setState(() => _submitting = true);
                            widget.onConfirm();
                            Navigator.of(context).pop(true);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.isReverse ? AppColors.accentBlue : AppColors.auction,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                      ),
                      elevation: 0,
                    ),
                    child: _submitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2),
                          )
                        : Text(
                            widget.isReverse
                                ? 'Submit Offer ${Formatters.formatINR(widget.bidAmount)}'
                                : 'Confirm Bid ${Formatters.formatINR(widget.bidAmount)}',
                            style: AppTextStyles.heading(size: 13.5, weight: FontWeight.w800, color: AppColors.white),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
