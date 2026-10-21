import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../providers/auction_provider.dart';
import '../../services/wallet_service.dart';
import 'emd_pay_sheet.dart';

class EmdLockScreen extends ConsumerStatefulWidget {
  final String auctionCode;

  const EmdLockScreen({super.key, required this.auctionCode});

  @override
  ConsumerState<EmdLockScreen> createState() => _EmdLockScreenState();
}

class _EmdLockScreenState extends ConsumerState<EmdLockScreen> {
  final _walletService = WalletService();
  bool _locking = false;

  Future<void> _lockEmd() async {
    setState(() => _locking = true);
    try {
      await _walletService.lockEmd(auctionId: widget.auctionCode);
      ref.invalidate(auctionDetailProvider(widget.auctionCode));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✓ EMD locked successfully')),
      );
      context.pop();
    } catch (error) {
      if (!mounted) return;
      setState(() => _locking = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to lock EMD: $error')),
      );
    }
  }

  void _openManualPayment(double amount, String title) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EmdPaySheet(
        auctionId: widget.auctionCode,
        auctionTitle: title,
        emdAmount: amount,
        emdPercent: 0,
        onPay: (_, _) {
          ref.invalidate(auctionDetailProvider(widget.auctionCode));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auction = ref.watch(auctionDetailProvider(widget.auctionCode));
    return Scaffold(
      backgroundColor: AppColors.appBg,
      appBar: AppBar(
        title: const Text('Lock EMD'),
        backgroundColor: AppColors.navy,
        foregroundColor: AppColors.white,
      ),
      body: auction.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Unable to load auction: $error')),
        data: (a) => ListView(
          padding: const EdgeInsets.all(AppSpacing.screenPaddingH),
          children: [
            Text(a.title, style: AppTextStyles.heading(size: 20, weight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(
              'Lock the required earnest money deposit to qualify for participation.',
              style: AppTextStyles.body(size: 13, color: AppColors.navyWithOpacity(0.7)),
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('EMD required'),
                    Text(
                      Formatters.formatINR(a.emdAmountInr),
                      style: AppTextStyles.heading(size: 18, weight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _locking ? null : _lockEmd,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.auction,
                  foregroundColor: AppColors.white,
                ),
                child: _locking
                    ? const CircularProgressIndicator(color: AppColors.white)
                    : const Text('Lock from wallet'),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: _locking ? null : () => _openManualPayment(a.emdAmountInr, a.title),
              child: const Text('Submit bank-transfer proof instead'),
            ),
          ],
        ),
      ),
    );
  }
}
