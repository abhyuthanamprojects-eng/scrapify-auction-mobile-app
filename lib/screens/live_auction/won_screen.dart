import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/formatters.dart';

class WonScreen extends StatelessWidget {
  final String lotTitle;
  final double winningBid;
  final String awardId;

  const WonScreen({
    super.key,
    this.lotTitle = '',
    this.winningBid = 0,
    this.awardId = '',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPaddingH),
          child: Column(
            children: [
              const Spacer(),
              // Winning Trophy Glow
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  gradient: AppColors.gradientGold,
                  shape: BoxShape.circle,
                  boxShadow: AppColors.shadowGold,
                ),
                child: const Center(
                  child: Icon(
                    Icons.emoji_events_rounded,
                    size: 48,
                    color: AppColors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                lotTitle.isEmpty
                    ? 'Award details unavailable'
                    : 'Winning Bid Confirmed!',
                style: AppTextStyles.heading(size: 24, weight: FontWeight.w900),
              ),
              const SizedBox(height: 6),
              Text(
                lotTitle.isEmpty
                    ? 'The award record could not be loaded from the API.'
                    : 'Congratulations! You have emerged as H1 winning bidder.',
                style: AppTextStyles.body(
                  size: 13,
                  color: AppColors.navyWithOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // Summary Box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppSpacing.radius2xl),
                  border: Border.all(color: AppColors.cardBorder),
                  boxShadow: AppColors.shadowSm,
                ),
                child: Column(
                  children: [
                    _infoRow('Event Title', lotTitle.isEmpty ? '—' : lotTitle),
                    _infoRow(
                      'Winning Amount',
                      winningBid > 0 ? Formatters.formatINR(winningBid) : '—',
                      isBold: true,
                    ),
                    _infoRow(
                      'Award Status',
                      lotTitle.isEmpty
                          ? 'Unavailable'
                          : 'Issued — Action Required',
                      color: lotTitle.isEmpty
                          ? AppColors.navy
                          : AppColors.auction,
                    ),
                    if (lotTitle.isNotEmpty)
                      _infoRow(
                        'Acceptance Window',
                        'See award record',
                        color: AppColors.destructive,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Step tracker
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'FULFILMENT ROADMAP',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _step(1, 'Accept Award & Contract Terms', true),
                    _step(2, 'Pay Balance Net Invoice (48h)', false),
                    _step(
                      3,
                      'Generate Dispatch Gate Pass & Truck Entry',
                      false,
                    ),
                    _step(4, 'Weighbridge Evidence & Lifting Closure', false),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: awardId.isEmpty
                      ? null
                      : () => context.push('/award/$awardId'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.auction,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Review & Accept Award',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => context.go('/home'),
                child: Text(
                  'Return to Dashboard',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.navyWithOpacity(0.6),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(
    String label,
    String value, {
    bool isBold = false,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w700,
              color: color ?? AppColors.navy,
            ),
          ),
        ],
      ),
    );
  }

  Widget _step(int num, String label, bool active) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: active
                  ? AppColors.auction
                  : AppColors.navyWithOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: active
                  ? const Icon(Icons.check, size: 12, color: AppColors.white)
                  : Text(
                      '$num',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF64748B),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              color: active ? AppColors.navy : const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}
