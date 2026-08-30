import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/formatters.dart';
import '../../models/award.dart';
import '../../providers/domain_providers.dart';
import '../../widgets/shared/empty_state.dart';

class AwardsScreen extends ConsumerWidget {
  const AwardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final awards = ref.watch(awardsProvider);

    return Scaffold(
      backgroundColor: AppColors.appBg,
      appBar: AppBar(
        title: const Text('My Awards & Offers'),
        backgroundColor: AppColors.navy,
        foregroundColor: AppColors.white,
        elevation: 0,
      ),
      body: awards.isEmpty
          ? Center(
              child: EmptyState(
                icon: Icons.emoji_events_outlined,
                title: 'No awards yet',
                subtitle: 'Winning auctions and fallback offers will appear here for your acceptance.',
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 90),
              itemCount: awards.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (ctx, i) {
                final a = awards[i];
                return _buildAwardCard(context, a);
              },
            ),
    );
  }

  Widget _buildAwardCard(BuildContext context, Award a) {
    final isPending = a.status == AwardStatus.offered || a.status == AwardStatus.fallbackOffered;
    final isFallback = a.status == AwardStatus.fallbackOffered;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radius2xl),
        border: Border.all(
          color: isFallback ? AppColors.purple.withValues(alpha: 0.4) : AppColors.cardBorder,
        ),
        boxShadow: AppColors.shadowSm,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header strip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: isFallback ? AppColors.purple.withValues(alpha: 0.08) : const Color(0xFFF8FAFC),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      isFallback ? Icons.volunteer_activism : Icons.emoji_events,
                      size: 16,
                      color: isFallback ? AppColors.purple : AppColors.auction,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isFallback ? 'FALLBACK OFFER (H2 OPPORTUNITY)' : 'WINNING AWARD (H1)',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: isFallback ? AppColors.purple : AppColors.auction,
                      ),
                    ),
                  ],
                ),
                _statusChip(a.status),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(a.auctionTitle, style: AppTextStyles.heading(size: 15, weight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text('Seller: ${a.sellerCompany} • Lot: ${a.auctionCode}', style: AppTextStyles.captionMuted),
                const SizedBox(height: 14),

                // Amount breakdown
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
                          const Text('FINAL AWARD AMOUNT', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: Color(0xFF64748B))),
                          const SizedBox(height: 2),
                          Text(Formatters.formatINR(a.amountInr), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.navy)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('BALANCE DUE', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: Color(0xFF64748B))),
                          const SizedBox(height: 2),
                          Text(Formatters.formatINR(a.balanceDueInr), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.destructive)),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),
                // Action row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (isPending)
                      Row(
                        children: [
                          const Icon(Icons.timer_outlined, size: 14, color: AppColors.destructive),
                          const SizedBox(width: 4),
                          Text('Expires: ${a.acceptanceDeadline}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.destructive)),
                        ],
                      )
                    else
                      Text('Accepted on ${a.issuedDate}', style: AppTextStyles.captionMuted),

                    ElevatedButton(
                      onPressed: () => context.push(isFallback ? '/fallback-offer/${a.id}' : '/award/${a.id}'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isPending ? AppColors.navy : AppColors.white,
                        foregroundColor: isPending ? AppColors.white : AppColors.navy,
                        side: isPending ? null : const BorderSide(color: AppColors.cardBorder),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
                      ),
                      child: Text(
                        isPending ? 'Review & Accept' : 'View Contract',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(AwardStatus status) {
    Color bg;
    Color fg;
    String label;

    switch (status) {
      case AwardStatus.offered:
        bg = AppColors.auction.withValues(alpha: 0.12);
        fg = AppColors.auction;
        label = 'Acceptance Pending';
        break;
      case AwardStatus.fallbackOffered:
        bg = AppColors.purple.withValues(alpha: 0.12);
        fg = AppColors.purple;
        label = 'Fallback Offered';
        break;
      case AwardStatus.accepted:
        bg = AppColors.success.withValues(alpha: 0.12);
        fg = AppColors.success;
        label = 'Accepted';
        break;
      case AwardStatus.declined:
        bg = AppColors.destructive.withValues(alpha: 0.12);
        fg = AppColors.destructive;
        label = 'Declined';
        break;
      case AwardStatus.expired:
      default:
        bg = const Color(0xFFE2E8F0);
        fg = const Color(0xFF64748B);
        label = status.label;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: fg)),
    );
  }
}
