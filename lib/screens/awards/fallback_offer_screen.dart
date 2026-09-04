import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/formatters.dart';
import '../../providers/domain_providers.dart';

class FallbackOfferScreen extends ConsumerStatefulWidget {
  final String offerId;
  const FallbackOfferScreen({super.key, required this.offerId});

  @override
  ConsumerState<FallbackOfferScreen> createState() => _FallbackOfferScreenState();
}

class _FallbackOfferScreenState extends ConsumerState<FallbackOfferScreen> {
  bool _agreed = false;
  bool _submitting = false;

  @override
  Widget build(BuildContext context) {
    final award = ref.watch(awardDetailProvider(widget.offerId));

    if (award == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Fallback Offer')),
        body: const Center(child: Text('Offer not found')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.appBg,
      appBar: AppBar(
        title: const Text('H2 Fallback Opportunity'),
        backgroundColor: AppColors.navy,
        foregroundColor: AppColors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Opportunity Explanation Banner
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF581C87), Color(0xFF3B0764)],
                ),
                borderRadius: BorderRadius.circular(AppSpacing.radius2xl),
                boxShadow: AppColors.shadowSm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text('H2 FALLBACK OFFER',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.white)),
                      ),
                      const Spacer(),
                      const Icon(Icons.volunteer_activism, color: AppColors.white, size: 20),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(award.auctionTitle, style: AppTextStyles.heading(size: 17, weight: FontWeight.w800, color: AppColors.white)),
                  const SizedBox(height: 8),
                  Text(
                    'The H1 winning bidder did not complete settlement within the statutory 24-hour window. As the qualified H2 bidder, this lot is now exclusively offered to your enterprise at your bid price.',
                    style: TextStyle(fontSize: 12, color: AppColors.white.withValues(alpha: 0.85), height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Commercial breakdown
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppSpacing.radius2xl),
                border: Border.all(color: AppColors.cardBorder),
                boxShadow: AppColors.shadowSm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('FALLBACK CONTRACT TERMS',
                      style: TextStyle(fontFamily: 'monospace', fontSize: 10.5, fontWeight: FontWeight.w800, color: Color(0xFF64748B))),
                  const SizedBox(height: 12),
                  _row('Your Offered Bid Price', Formatters.formatINR(award.amountInr)),
                  _row('Applicable GST (18%)', Formatters.formatINR(award.gstAmountInr)),
                  _row('EMD Security Adjustment', '- ${Formatters.formatINR(award.adjustedEmdInr)}'),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Net Payable:', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: AppColors.navy)),
                      Text(
                        Formatters.formatINR(award.balanceDueInr),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.purple),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Checkbox
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppSpacing.radius2xl),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox.adaptive(
                    value: _agreed,
                    activeColor: AppColors.purple,
                    onChanged: (v) => setState(() => _agreed = v ?? false),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _agreed = !_agreed),
                      child: Text(
                        'I accept the fallback award at my original offered bid of ${Formatters.formatINR(award.amountInr)} and agree to lifting terms.',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.navy, height: 1.4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).padding.bottom + 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: const Border(top: BorderSide(color: AppColors.cardBorder)),
          boxShadow: AppColors.shadowLg,
        ),
        child: Row(
          children: [
            OutlinedButton(
              onPressed: () => context.pop(),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.navy,
                side: const BorderSide(color: AppColors.cardBorder),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusXl)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              child: const Text('Pass Offer'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: (!_agreed || _submitting)
                      ? null
                      : () async {
                          setState(() => _submitting = true);
                          try {
                            await ref.read(awardsProvider.notifier).accept(widget.offerId);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('✓ Fallback Offer Accepted! Contract Generated.')),
                              );
                              context.push('/payments');
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: ${e.toString()}')),
                              );
                              setState(() => _submitting = false);
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.purple,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusXl)),
                    elevation: 0,
                  ),
                  child: _submitting
                      ? const CircularProgressIndicator(color: AppColors.white)
                      : const Text('Accept Fallback Award', style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(k, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
          Text(v, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.navy)),
        ],
      ),
    );
  }
}
