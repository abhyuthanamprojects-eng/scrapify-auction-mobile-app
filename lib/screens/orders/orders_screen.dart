import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/formatters.dart';
import '../../models/fulfilment.dart';
import '../../providers/domain_providers.dart';
import '../../widgets/shared/empty_state.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fulfilments = ref.watch(fulfilmentsProvider);

    return Scaffold(
      backgroundColor: AppColors.appBg,
      appBar: AppBar(
        title: const Text('Fulfilment & Contracts'),
        backgroundColor: AppColors.navy,
        foregroundColor: AppColors.white,
        elevation: 0,
      ),
      body: fulfilments.when(
        data: (data) => data.isEmpty
            ? Center(
                child: EmptyState(
                  icon: Icons.local_shipping_outlined,
                  title: 'No active fulfilment orders',
                  subtitle: 'Won auctions and contracted services will be tracked here through gate pass and lifting.',
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 90),
                itemCount: data.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (ctx, i) {
                  final f = data[i];
                  return _buildFulfilmentCard(context, f);
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildFulfilmentCard(BuildContext context, FulfilmentRecord f) {
    final completedSteps = f.stages.where((s) => s.isCompleted).length;
    final totalSteps = f.stages.length;
    final progress = totalSteps > 0 ? completedSteps / totalSteps : 0.0;

    return GestureDetector(
      onTap: () => context.push('/order/${f.orderId}'),
      child: Container(
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
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.navy.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(_categoryIcon(f.category), color: AppColors.navy, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(f.orderId, style: AppTextStyles.mono),
                        Text(f.category, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
                      ],
                    ),
                  ],
                ),
                _statusBadge(f.status),
              ],
            ),
            const SizedBox(height: 12),
            Text(f.auctionTitle, style: AppTextStyles.heading(size: 15, weight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text('Seller: ${f.sellerCompany} • Net Total: ${Formatters.formatINR(f.totalAmountInr)}', style: AppTextStyles.captionMuted),
            const SizedBox(height: 14),

            // Progress Bar & Step Label
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Stage: ${f.currentStage.replaceAll('_', ' ').toUpperCase()}',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.navy),
                ),
                Text(
                  '$completedSteps/$totalSteps Complete',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: const Color(0xFFE2E8F0),
                valueColor: AlwaysStoppedAnimation(
                  progress >= 1.0 ? AppColors.success : AppColors.auction,
                ),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (f.gatePass != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.qr_code, size: 12, color: AppColors.success),
                        const SizedBox(width: 4),
                        Text('Pass: ${f.gatePass!.gatePassNumber}', style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.success)),
                      ],
                    ),
                  )
                else
                  const SizedBox.shrink(),
                Row(
                  children: [
                    Text('Track & Evidence', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.accentBlue)),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_forward, size: 14, color: AppColors.accentBlue),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _categoryIcon(String cat) {
    if (cat.contains('Metal') || cat.contains('Scrap')) return Icons.recycling;
    if (cat.contains('Logistics')) return Icons.local_shipping;
    if (cat.contains('IT')) return Icons.laptop_mac;
    if (cat.contains('Machinery')) return Icons.precision_manufacturing;
    return Icons.inventory_2_outlined;
  }

  Widget _statusBadge(String st) {
    Color bg = AppColors.auction.withValues(alpha: 0.12);
    Color fg = AppColors.auction;
    if (st.contains('COMPLETED')) {
      bg = AppColors.success.withValues(alpha: 0.12);
      fg = AppColors.success;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(st, style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: fg)),
    );
  }
}
