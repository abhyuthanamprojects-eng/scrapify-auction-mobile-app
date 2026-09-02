import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../providers/auction_provider.dart';

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
                  if (auction.terms?.trim().isNotEmpty ?? false)
                    ...auction.terms!.split(RegExp(r'\r?\n')).asMap().entries.map((entry) =>
                        _section('${entry.key + 1}. Event Terms', entry.value.trim()))
                  else
                    _section('Event terms', 'No additional terms have been published for this event.'),
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
