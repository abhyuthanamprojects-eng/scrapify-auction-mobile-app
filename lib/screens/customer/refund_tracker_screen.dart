import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/formatters.dart';
import '../../widgets/shared/screen_header.dart';

class RefundEntry {
  final String auctionId;
  final String auctionTitle;
  final double emdAmount;
  final String stage; // 'initiated' | 'processed' | 'credited'

  const RefundEntry({
    required this.auctionId,
    required this.auctionTitle,
    required this.emdAmount,
    this.stage = 'initiated',
  });
}

class RefundTrackerScreen extends StatelessWidget {
  final List<RefundEntry> refunds;
  final VoidCallback onBack;

  const RefundTrackerScreen({
    super.key,
    required this.refunds,
    required this.onBack,
  });

  static const _stages = ['initiated', 'processed', 'credited'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBg,
      body: Column(
        children: [
          ScreenHeader(
            title: 'EMD refunds',
            subtitle: 'Initiated -> Processed -> Credited',
            onBack: onBack,
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
                if (refunds.isEmpty)
                  _emptyState()
                else
                  ...refunds.map((r) => _refundCard(r)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
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
        children: [
          Icon(Icons.refresh, size: 28, color: AppColors.navyWithOpacity(0.3)),
          const SizedBox(height: 8),
          Text(
            'No refunds in progress',
            style: AppTextStyles.body(size: 14, weight: FontWeight.w700, color: AppColors.navy),
          ),
          const SizedBox(height: 4),
          Text(
            'EMD is released automatically when you don\'t win a lot.',
            style: AppTextStyles.body(size: 12, color: AppColors.navyWithOpacity(0.55)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _refundCard(RefundEntry r) {
    final currentIdx = _stages.indexOf(r.stage);

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
          children: [
            // Title row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(r.auctionId, style: AppTextStyles.mono),
                      Text(
                        r.auctionTitle,
                        style: AppTextStyles.body(size: 14, weight: FontWeight.w700, color: AppColors.navy),
                      ),
                    ],
                  ),
                ),
                Text(
                  Formatters.formatINR(r.emdAmount),
                  style: AppTextStyles.body(size: 14, weight: FontWeight.w800, color: AppColors.success),
                ),
              ],
            ),

            // Progress stepper
            const SizedBox(height: 16),
            Row(
              children: List.generate(_stages.length * 2 - 1, (i) {
                if (i.isOdd) {
                  // Connector line
                  final lineIdx = i ~/ 2;
                  return Expanded(
                    child: Container(
                      height: 2,
                      color: lineIdx < currentIdx
                          ? AppColors.success
                          : AppColors.navyWithOpacity(0.1),
                    ),
                  );
                }
                final stageIdx = i ~/ 2;
                final done = stageIdx <= currentIdx;
                return Column(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: done ? AppColors.success : AppColors.navyWithOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: done
                            ? const Icon(Icons.check, size: 12, color: AppColors.white)
                            : Text(
                                '${stageIdx + 1}',
                                style: AppTextStyles.body(
                                  size: 10,
                                  weight: FontWeight.w700,
                                  color: AppColors.navyWithOpacity(0.4),
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _stages[stageIdx][0].toUpperCase() + _stages[stageIdx].substring(1),
                      style: AppTextStyles.body(
                        size: 10,
                        weight: FontWeight.w600,
                        color: AppColors.navyWithOpacity(0.6),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
