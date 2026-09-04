import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/formatters.dart';
import '../../providers/domain_providers.dart';

class PerformanceScreen extends ConsumerWidget {
  const PerformanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final perfAsync = ref.watch(performanceProvider);

    return Scaffold(
      backgroundColor: AppColors.appBg,
      appBar: AppBar(
        title: const Text('Vendor Scorecard & Tier'),
        backgroundColor: AppColors.navy,
        foregroundColor: AppColors.white,
        elevation: 0,
      ),
      body: perfAsync.when(
        data: (perf) => SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
            // Master Platinum Tier Badge Banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.gradientGold,
                borderRadius: BorderRadius.circular(28),
                boxShadow: AppColors.shadowGold,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.navy,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '${perf.tier.toUpperCase()} TIER',
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.white),
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: AppColors.white, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${perf.overallScore} / 5.0',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Icon(Icons.verified_user_rounded, color: AppColors.white, size: 48),
                  const SizedBox(height: 8),
                  Text('Devzign Solutions Pvt Ltd', style: AppTextStyles.heading(size: 18, weight: FontWeight.w900, color: AppColors.white)),
                  const SizedBox(height: 2),
                  Text('Corporate GSTIN: 20AABCT1332F1ZT', style: TextStyle(fontSize: 11.5, color: AppColors.white.withValues(alpha: 0.85))),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Performance Metrics Grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.35,
              children: [
                _metricCard('On-Time Lifting', '${perf.onTimeDeliveryPct}%', Icons.local_shipping_outlined, AppColors.success),
                _metricCard('Payment Compliance', '${perf.paymentCompliancePct}%', Icons.account_balance_wallet_outlined, AppColors.accentBlue),
                _metricCard('Dispute / Claim Rate', '${perf.disputeRatePct}%', Icons.shield_outlined, AppColors.success),
                _metricCard('Completed Orders', '${perf.totalOrdersCompleted}', Icons.task_alt, AppColors.purple),
              ],
            ),
            const SizedBox(height: 20),

            // Lifetime Volume Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppSpacing.radius2xl),
                border: Border.all(color: AppColors.cardBorder),
                boxShadow: AppColors.shadowSm,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('TOTAL LIFETIME TRADED VALUE',
                          style: TextStyle(fontFamily: 'monospace', fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF64748B))),
                      const SizedBox(height: 4),
                      Text(Formatters.formatINR(perf.totalTradedValueInr),
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.navy)),
                    ],
                  ),
                  const Icon(Icons.show_chart, color: AppColors.success, size: 36),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Platinum Tier Benefits
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppSpacing.radius2xl),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('PLATINUM TIER PRIVILEGES',
                      style: TextStyle(fontFamily: 'monospace', fontSize: 10.5, fontWeight: FontWeight.w800, color: AppColors.navy)),
                  const SizedBox(height: 12),
                  _benefit('50% EMD Waiver on forward auctions up to ₹25 Lakhs'),
                  _benefit('Priority gate pass issuance with express security lane'),
                  _benefit('Dedicated Corporate Key Account Manager support'),
                  _benefit('Fast-track 12-hour commercial dispute resolution window'),
                ],
              ),
            ),
          ],
        ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _metricCard(String title, String val, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radius2xl),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: AppColors.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, size: 22, color: color),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(val, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.navy)),
              Text(title, style: AppTextStyles.captionMuted),
            ],
          ),
        ],
      ),
    );
  }

  Widget _benefit(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, size: 16, color: AppColors.success),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.navy))),
        ],
      ),
    );
  }
}
