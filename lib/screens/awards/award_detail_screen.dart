import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/formatters.dart';
import '../../models/award.dart';
import '../../providers/domain_providers.dart';

class AwardDetailScreen extends ConsumerStatefulWidget {
  final String awardId;
  const AwardDetailScreen({super.key, required this.awardId});

  @override
  ConsumerState<AwardDetailScreen> createState() => _AwardDetailScreenState();
}

class _AwardDetailScreenState extends ConsumerState<AwardDetailScreen> {
  bool _termsAgreed = false;
  bool _submitting = false;

  void _declineDialog(BuildContext context) {
    final reasonCtl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Decline Award Offer', style: TextStyle(fontWeight: FontWeight.w800)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Please provide a reason for declining. Note: Unjustified refusal may affect your Scrapify tier score and EMD security.',
              style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonCtl,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'e.g., Specification discrepancy, inability to meet lifting window...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              try {
                await ref.read(awardsProvider.notifier).decline(widget.awardId, reasonCtl.text.trim());
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Award Offer Declined')),
                );
                context.pop();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: ${e.toString()}')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.destructive),
            child: const Text('Confirm Decline', style: TextStyle(color: AppColors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final award = ref.watch(awardDetailProvider(widget.awardId));

    if (award == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Award Details')),
        body: const Center(child: Text('Award not found')),
      );
    }

    final isPending = award.status == AwardStatus.offered;

    return Scaffold(
      backgroundColor: AppColors.appBg,
      appBar: AppBar(
        title: const Text('Contract & Award Acceptance'),
        backgroundColor: AppColors.navy,
        foregroundColor: AppColors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Downloading Official Award Notice PDF...')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Status Hero
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: AppColors.gradientNoir,
                borderRadius: BorderRadius.circular(AppSpacing.radius2xl),
                boxShadow: AppColors.shadowSm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.goldSoft.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          award.id,
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.goldSoft),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: award.status == AwardStatus.accepted
                              ? AppColors.success.withValues(alpha: 0.2)
                              : AppColors.auction.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          award.status == AwardStatus.accepted ? 'ACCEPTED & ACTIVE' : 'PENDING SIGN-OFF',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: award.status == AwardStatus.accepted ? AppColors.success : AppColors.goldSoft,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(award.auctionTitle, style: AppTextStyles.heading(size: 17, weight: FontWeight.w800, color: AppColors.white)),
                  const SizedBox(height: 4),
                  Text('Issued by: ${award.sellerCompany}', style: TextStyle(fontSize: 12, color: AppColors.white.withValues(alpha: 0.7))),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.timer_outlined, size: 14, color: AppColors.goldSoft),
                      const SizedBox(width: 5),
                      Text('Acceptance Deadline: ${award.acceptanceDeadline}',
                          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.goldSoft)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Commercial Ledger Breakdown
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
                  const Text('COMMERCIAL BILLING BREAKDOWN',
                      style: TextStyle(fontFamily: 'monospace', fontSize: 10.5, fontWeight: FontWeight.w800, color: Color(0xFF64748B))),
                  const SizedBox(height: 14),
                  _row('Winning H1 Bid / Contract Total', Formatters.formatINR(award.amountInr)),
                  _row('Applicable GST (18%)', Formatters.formatINR(award.gstAmountInr)),
                  _row('Adjusted EMD Security Deposit', '- ${Formatters.formatINR(award.adjustedEmdInr)}', isDeduction: true),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Net Balance Payable:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.navy)),
                      Text(
                        Formatters.formatINR(award.balanceDueInr),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.destructive),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Terms & Conditions Acknowledgement
            if (isPending)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppSpacing.radius2xl),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Checkbox.adaptive(
                          value: _termsAgreed,
                          activeColor: AppColors.auction,
                          onChanged: (v) => setState(() => _termsAgreed = v ?? false),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _termsAgreed = !_termsAgreed),
                            child: Text(
                              'I legally accept the contract terms, agree to settle the balance of ${Formatters.formatINR(award.balanceDueInr)} within 48 hours, and authorize the EMD adjustment.',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.navy, height: 1.4),
                            ),
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
      bottomNavigationBar: isPending
          ? Container(
              padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).padding.bottom + 12),
              decoration: BoxDecoration(
                color: AppColors.white,
                border: const Border(top: BorderSide(color: AppColors.cardBorder)),
                boxShadow: AppColors.shadowLg,
              ),
              child: Row(
                children: [
                  OutlinedButton(
                    onPressed: () => _declineDialog(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.destructive,
                      side: const BorderSide(color: AppColors.destructive),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusXl)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    child: const Text('Decline', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: (!_termsAgreed || _submitting)
                            ? null
                            : () async {
                                setState(() => _submitting = true);
                                try {
                                  await ref.read(awardsProvider.notifier).accept(widget.awardId);
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('✓ Award Accepted Successfully! Proceeding to Payment...')),
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
                          backgroundColor: AppColors.auction,
                          foregroundColor: AppColors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusXl)),
                          elevation: 0,
                        ),
                        child: _submitting
                            ? const CircularProgressIndicator(color: AppColors.white)
                            : const Text('Accept & Proceed to Pay', style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800)),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }

  Widget _row(String k, String v, {bool isDeduction = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(k, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
          Text(
            v,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: isDeduction ? AppColors.success : AppColors.navy,
            ),
          ),
        ],
      ),
    );
  }
}
