import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/formatters.dart';
import '../../widgets/shared/screen_header.dart';

class EmdLedgerEntry {
  final String auctionId;
  final String auctionTitle;
  final double emdAmount;
  final String status; // 'confirmed' | 'pending' | 'refunded' | etc.

  const EmdLedgerEntry({
    required this.auctionId,
    required this.auctionTitle,
    required this.emdAmount,
    required this.status,
  });
}

class EmdLedgerScreen extends StatelessWidget {
  final List<EmdLedgerEntry> entries;
  final VoidCallback onBack;
  final void Function(String document)? onDownloadDocument;

  const EmdLedgerScreen({
    super.key,
    required this.entries,
    required this.onBack,
    this.onDownloadDocument,
  });

  static const _statusLabels = {
    'not_paid': 'EMD not paid',
    'pending': 'EMD pending',
    'confirmed': 'EMD confirmed',
    'refund_initiated': 'Refund initiated',
    'refunded': 'Refunded',
  };

  @override
  Widget build(BuildContext context) {
    final blocked = entries
        .where((e) => e.status == 'confirmed')
        .fold<double>(0, (sum, e) => sum + e.emdAmount);
    final confirmedCount = entries.where((e) => e.status == 'confirmed').length;

    final documents = <String>[];

    return Scaffold(
      backgroundColor: AppColors.appBg,
      body: Column(
        children: [
          ScreenHeader(
            title: 'EMD ledger',
            subtitle: 'Blocked deposits & statements',
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
                // Navy summary card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.navy,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusXxl),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total EMD blocked',
                        style: AppTextStyles.body(
                          size: 11,
                          color: AppColors.whiteWithOpacity(0.6),
                        ),
                      ),
                      Text(
                        Formatters.formatINR(blocked),
                        style: AppTextStyles.heading(
                          size: 30,
                          weight: FontWeight.w800,
                          color: AppColors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Across $confirmedCount live auction(s)',
                        style: AppTextStyles.body(
                          size: 11,
                          color: AppColors.whiteWithOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),

                // Per auction breakdown
                const SizedBox(height: 16),
                _card(
                  child: Column(
                    children: [
                      _sectionHeader('Per auction'),
                      ...entries.map(
                        (e) => Column(
                          children: [
                            Divider(
                              height: 1,
                              thickness: 1,
                              color: AppColors.blackWithOpacity(0.05),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: AppColors.navyWithOpacity(0.05),
                                      borderRadius: BorderRadius.circular(
                                        AppSpacing.radiusLg,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.currency_rupee,
                                      size: 16,
                                      color: AppColors.navy,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          e.auctionTitle,
                                          style: AppTextStyles.body(
                                            size: 13,
                                            weight: FontWeight.w700,
                                            color: AppColors.navy,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          e.auctionId,
                                          style: AppTextStyles.mono,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        Formatters.formatINR(e.emdAmount),
                                        style: AppTextStyles.body(
                                          size: 13,
                                          weight: FontWeight.w800,
                                          color: AppColors.navy,
                                        ),
                                      ),
                                      Text(
                                        _statusLabels[e.status] ?? e.status,
                                        style: AppTextStyles.body(
                                          size: 10,
                                          weight: FontWeight.w700,
                                          color: AppColors.navyWithOpacity(0.5),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Documents
                const SizedBox(height: 16),
                _card(
                  child: Column(
                    children: [
                      _sectionHeader('Documents'),
                      if (documents.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'No statements or invoices are available.',
                              style: AppTextStyles.body(
                                size: 12,
                                color: AppColors.navyWithOpacity(0.55),
                              ),
                            ),
                          ),
                        ),
                      ...documents.map(
                        (d) => Column(
                          children: [
                            Divider(
                              height: 1,
                              thickness: 1,
                              color: AppColors.blackWithOpacity(0.05),
                            ),
                            GestureDetector(
                              onTap: () => onDownloadDocument?.call(d),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.description,
                                      size: 16,
                                      color: AppColors.navy,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        d,
                                        style: AppTextStyles.body(
                                          size: 13,
                                          weight: FontWeight.w600,
                                          color: AppColors.navy,
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      Icons.download,
                                      size: 15,
                                      color: AppColors.accentBlue,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
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
      child: child,
    );
  }

  Widget _sectionHeader(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          label.toUpperCase(),
          style: AppTextStyles.body(
            size: 10,
            weight: FontWeight.w700,
            color: AppColors.navyWithOpacity(0.5),
          ).copyWith(letterSpacing: 1.0),
        ),
      ),
    );
  }
}
