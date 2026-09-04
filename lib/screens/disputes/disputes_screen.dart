import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/formatters.dart';
import '../../models/dispute.dart';
import '../../providers/domain_providers.dart';
import '../../widgets/shared/empty_state.dart';

class DisputesScreen extends ConsumerWidget {
  const DisputesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final disputes = ref.watch(disputesProvider);

    return Scaffold(
      backgroundColor: AppColors.appBg,
      appBar: AppBar(
        title: const Text('Commercial Claims & Disputes'),
        backgroundColor: AppColors.navy,
        foregroundColor: AppColors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Raise Dispute',
            onPressed: () => context.push('/new-dispute/ORD-2026-1048'),
          ),
        ],
      ),
      body: disputes.isEmpty
          ? Center(
              child: EmptyState(
                icon: Icons.shield_outlined,
                title: 'No disputes filed',
                subtitle: 'All orders and contracts are proceeding without active claims.',
                actionLabel: 'File a Claim',
                onAction: () => context.push('/new-dispute/ORD-2026-1048'),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 90),
              itemCount: disputes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (ctx, i) {
                final d = disputes[i];
                return _buildDisputeCard(context, d);
              },
            ),
    );
  }

  Widget _buildDisputeCard(BuildContext context, DisputeItem d) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radius2xl),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: AppColors.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(d.disputeId ?? d.id, style: AppTextStyles.mono),
              _disputeStatusChip(d.status),
            ],
          ),
          const SizedBox(height: 8),
          Text(d.title ?? (d.category is DisputeCategory ? (d.category as DisputeCategory).label : d.category?.toString() ?? 'Commercial Dispute'),
              style: AppTextStyles.heading(size: 15, weight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text('Order: ${d.orderId ?? d.orderNumber} • Claim: ${Formatters.formatINR(d.claimedAmountInr ?? 0)}', style: AppTextStyles.captionMuted),
          const SizedBox(height: 10),
          Text(
            d.description,
            style: AppTextStyles.body(size: 12.5, color: AppColors.navy.withValues(alpha: 0.8), height: 1.4),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          if (d.timeline.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.appBg,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Row(
                children: [
                  const Icon(Icons.comment_outlined, size: 14, color: AppColors.accentBlue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${d.timeline.last.author}: ${d.timeline.last.message}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.navy),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _disputeStatusChip(DisputeStatus st) {
    Color bg;
    Color fg;
    String label;

    switch (st) {
      case DisputeStatus.raised:
      case DisputeStatus.open:
      case DisputeStatus.underReview:
        bg = AppColors.auction.withValues(alpha: 0.12);
        fg = AppColors.auction;
        label = 'Under Review';
        break;
      case DisputeStatus.evidenceRequested:
      case DisputeStatus.awaitingResponse:
        bg = AppColors.purple.withValues(alpha: 0.12);
        fg = AppColors.purple;
        label = 'Evidence Requested';
        break;
      case DisputeStatus.resolvedRefund:
      case DisputeStatus.resolved:
        bg = AppColors.success.withValues(alpha: 0.12);
        fg = AppColors.success;
        label = 'Resolved (Refund Approved)';
        break;
      case DisputeStatus.rejected:
      case DisputeStatus.closed:
        bg = AppColors.destructive.withValues(alpha: 0.12);
        fg = AppColors.destructive;
        label = st.label;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(label, style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: fg)),
    );
  }
}
