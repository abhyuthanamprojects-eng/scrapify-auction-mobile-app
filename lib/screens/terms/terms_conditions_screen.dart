import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../providers/auction_provider.dart';
import '../../services/mock_bidplay_repository.dart';

class TermsConditionsScreen extends ConsumerStatefulWidget {
  final String auctionCode;
  const TermsConditionsScreen({super.key, required this.auctionCode});

  @override
  ConsumerState<TermsConditionsScreen> createState() => _TermsConditionsScreenState();
}

class _TermsConditionsScreenState extends ConsumerState<TermsConditionsScreen> {
  bool _agreed = false;
  bool _submitting = false;

  @override
  Widget build(BuildContext context) {
    final auctionAsync = ref.watch(auctionDetailProvider(widget.auctionCode));

    return Scaffold(
      backgroundColor: AppColors.appBg,
      appBar: AppBar(
        title: const Text('Terms & Conditions'),
        backgroundColor: AppColors.navy,
        foregroundColor: AppColors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Downloading Legal Terms PDF...')),
              );
            },
          ),
        ],
      ),
      body: auctionAsync.when(
        data: (auction) => Column(
          children: [
            // Version Header Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              color: AppColors.navy.withValues(alpha: 0.05),
              child: Row(
                children: [
                  const Icon(Icons.shield_outlined, size: 18, color: AppColors.accentBlue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Scrapify Standard Enterprise Terms (v${auction.termsVersion}.0)',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.navy),
                        ),
                        Text(
                          'Applicable for Event ${auction.code} • Last Updated 24 Aug 2026',
                          style: AppTextStyles.captionMuted,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Terms Content (Scrollable)
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _section('1. Bidding Eligibility & Authority',
                      'By participating in this event, you confirm that you are an authorized representative of your registered corporate entity with valid GSTIN and legal bidding authority. All bids placed are irrevocable, binding, and subject to acceptance rules.'),
                  _section('2. Commercial Rules & EMD Security',
                      'Earnest Money Deposit (EMD) must be locked prior to placing bids. In the event of successful award, the EMD is adjusted against final invoice payment. For non-winning bidders, 100% EMD is auto-refunded to the source wallet immediately upon closure.'),
                  _section('3. Inspection & As-Is Sale Policy',
                      'All materials and services are catalogued to the best of seller knowledge but sold strictly on "As-Is Where-Is" basis. Participants are encouraged to book physical gate pass inspection during the official inspection window.'),
                  _section('4. Sniping Protection & Timer Extensions',
                      'To ensure fair market realization, any valid bid received in the final 3 minutes will automatically extend the closing countdown timer by 2 minutes.'),
                  _section('5. Settlement & Lifting Deadlines',
                      'Winning bidders (H1 in Forward, L1 in Reverse) must accept award within 24 hours and clear net invoice balance within 48 hours. Material lifting must be scheduled within 15 calendar days.'),
                  _section('6. Dispute Resolution',
                      'All commercial disputes will be mediated under Scrapify Platform Dispute Resolution Guidelines and subject to designated municipal jurisdiction.'),
                ],
              ),
            ),
            // Agreement Checkbox & Footer
            Container(
              padding: EdgeInsets.fromLTRB(20, 14, 20, MediaQuery.of(context).padding.bottom + 14),
              decoration: BoxDecoration(
                color: AppColors.white,
                border: const Border(top: BorderSide(color: AppColors.cardBorder)),
                boxShadow: AppColors.shadowLg,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
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
                          child: const Text(
                            'I have read, understood and agree to the auction terms and lifting guidelines.',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.navy),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: (!_agreed || _submitting)
                          ? null
                          : () async {
                              setState(() => _submitting = true);
                              MockBidPlayRepository().acceptTerms(widget.auctionCode);
                              ref.invalidate(auctionDetailProvider(widget.auctionCode));
                              await Future.delayed(const Duration(milliseconds: 300));
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('✓ Terms Accepted Successfully')),
                                );
                                context.pop();
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.auction,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                        ),
                        elevation: 0,
                      ),
                      child: _submitting
                          ? const CircularProgressIndicator(color: AppColors.white)
                          : const Text(
                              'Accept & Continue',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _section(String heading, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(heading, style: AppTextStyles.labelLarge),
          const SizedBox(height: 4),
          Text(
            content,
            style: AppTextStyles.body(size: 13, color: AppColors.navy.withValues(alpha: 0.75), height: 1.5),
          ),
        ],
      ),
    );
  }
}
