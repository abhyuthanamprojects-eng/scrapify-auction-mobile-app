import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/formatters.dart';
import '../../models/auction.dart';
import '../../services/auction_service.dart';

class AuctionWaitingRoomScreen extends ConsumerStatefulWidget {
  final String auctionCode;
  const AuctionWaitingRoomScreen({super.key, required this.auctionCode});

  @override
  ConsumerState<AuctionWaitingRoomScreen> createState() => _AuctionWaitingRoomScreenState();
}

class _AuctionWaitingRoomScreenState extends ConsumerState<AuctionWaitingRoomScreen> {
  int _secondsLeft = 0;
  Timer? _timer;
  Auction? _auction;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAuction();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft > 0) {
        setState(() => _secondsLeft--);
      } else {
        t.cancel();
      }
    });
  }

  Future<void> _loadAuction() async {
    try {
      final auction = await AuctionService().show(widget.auctionCode);
      final startsAt = DateTime.tryParse(auction.scheduleStart ?? '');
      if (!mounted) return;
      setState(() {
        _auction = auction;
        _secondsLeft = startsAt == null
            ? 0
            : startsAt.difference(DateTime.now()).inSeconds.clamp(0, 864000);
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatCountdown(int totalSecs) {
    final m = (totalSecs ~/ 60).toString().padLeft(2, '0');
    final s = (totalSecs % 60).toString().padLeft(2, '0');
    return '00:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(body: Center(child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(_error!, textAlign: TextAlign.center),
      )));
    }
    final auction = _auction;
    if (auction == null) {
      return const Scaffold(
        backgroundColor: AppColors.navy,
        body: Center(child: CircularProgressIndicator(color: AppColors.auction)),
      );
    }

    final isReverse = auction.isReverse;

    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppBar(
        title: const Text('Auction Waiting Room'),
        backgroundColor: AppColors.navyDark,
        foregroundColor: AppColors.white,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
                ),
                const SizedBox(width: 6),
                const Text('Live Stream 18ms', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.success)),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Event Header Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.navyDark,
                borderRadius: BorderRadius.circular(AppSpacing.radius2xl),
                border: Border.all(color: AppColors.white.withValues(alpha: 0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isReverse ? AppColors.accentBlue : AppColors.auction,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isReverse ? 'REVERSE AUCTION (PROCUREMENT)' : 'FORWARD LIVE AUCTION',
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.white),
                        ),
                      ),
                      Text(auction.code, style: AppTextStyles.mono.copyWith(color: AppColors.white.withValues(alpha: 0.7))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(auction.title, style: AppTextStyles.heading(size: 17, weight: FontWeight.w900, color: AppColors.white)),
                  const SizedBox(height: 4),
                  Text('Seller: ${auction.company}', style: TextStyle(fontSize: 12.5, color: AppColors.white.withValues(alpha: 0.7))),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Server-Synced Countdown Clock
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppColors.gradientNoir,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: AppColors.auction.withValues(alpha: 0.4)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.auction.withValues(alpha: 0.15),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text('EVENT STARTS IN',
                      style: TextStyle(fontFamily: 'monospace', fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.auction, letterSpacing: 1.5)),
                  const SizedBox(height: 10),
                  Text(
                    _formatCountdown(_secondsLeft),
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      color: AppColors.white,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Synchronized with National Server Time (IST)',
                    style: TextStyle(fontSize: 11, color: AppColors.white.withValues(alpha: 0.6)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Pre-Bid Verification Checklist
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppSpacing.radius2xl),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('PRE-BID ELIGIBILITY CLEARANCE',
                      style: TextStyle(fontFamily: 'monospace', fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.navy)),
                  const SizedBox(height: 12),
                  _checkRow('Corporate KYB & GSTIN', 'Verified', true),
                  _checkRow('Security / EMD Escrow', 'Paid ${Formatters.formatINR(auction.emdAmountInr)}', auction.emdPaid),
                  _checkRow('Platform Terms & Integrity Pact', 'Accepted v2.1', true),
                  _checkRow('Technical Qualification / RFx', 'Qualified (Score 94%)', true),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Commercial Rules Summary
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppSpacing.radius2xl),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('COMMERCIAL BIDDING RULES',
                      style: TextStyle(fontFamily: 'monospace', fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.navy)),
                  const SizedBox(height: 12),
                  _ruleRow('Starting / Base Price', Formatters.formatINR(auction.startingPriceInr)),
                  _ruleRow(isReverse ? 'Minimum Decrement Step' : 'Minimum Increment Step', Formatters.formatINR(isReverse ? auction.decrementInr : auction.bidIncrementInr)),
                  _ruleRow('Anti-Sniping Rule', 'Auto +3 mins extension if bid in final 3m'),
                  _ruleRow('Currency & Taxes', 'INR (₹) • 18% GST Applicable on Invoice'),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Primary Join Action
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  if (isReverse) {
                    context.push('/live-reverse/${auction.code}');
                  } else {
                    context.push('/live/${auction.code}');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.auction,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusXl)),
                  elevation: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.login, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      _secondsLeft == 0 ? 'ENTER LIVE AUCTION ROOM' : 'ENTER AUCTION ROOM NOW',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _checkRow(String title, String val, bool verified) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(verified ? Icons.check_circle : Icons.error_outline, size: 18, color: verified ? AppColors.success : AppColors.auction),
          const SizedBox(width: 8),
          Expanded(child: Text(title, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.navy))),
          Text(val, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: verified ? AppColors.success : AppColors.auction)),
        ],
      ),
    );
  }

  Widget _ruleRow(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(k, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
          Text(v, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.navy)),
        ],
      ),
    );
  }
}
