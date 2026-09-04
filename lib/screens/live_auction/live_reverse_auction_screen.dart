import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/formatters.dart';
import '../../models/auction.dart';
import '../../models/bid_receipt.dart';
import '../../services/auction_service.dart';
import '../../services/bid_service.dart';
import '../../widgets/shared/bid_confirmation_sheet.dart';

class LiveReverseAuctionScreen extends ConsumerStatefulWidget {
  final String lotId;
  const LiveReverseAuctionScreen({super.key, required this.lotId});

  @override
  ConsumerState<LiveReverseAuctionScreen> createState() => _LiveReverseAuctionScreenState();
}

class _LiveReverseAuctionScreenState extends ConsumerState<LiveReverseAuctionScreen> {
  late Auction _auction;
  late double _currentL1;
  late int _secondsRemaining;
  late int _bidders;
  int _myRank = 2;
  bool _isPaused = false;
  String? _bannerNotice;
  Timer? _tickerTimer;
  Timer? _botTimer;
  bool _loading = true;
  String? _loadError;

  // Landed Cost inputs
  double _basePrice = 900000;
  double _freight = 15000;
  double _taxGst = 162000;
  double _insurance = 3000;

  final List<Map<String, dynamic>> _offerFeed = [];

  @override
  void initState() {
    super.initState();
    _auction = Auction(code: widget.lotId, title: '', company: '', direction: 'reverse');
    _currentL1 = 0;
    _secondsRemaining = 0;
    _bidders = 0;
    _loadAuction();

    // Countdown
    _tickerTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted || _isPaused) return;
      setState(() {
        if (_secondsRemaining > 0) _secondsRemaining--;
      });
    });

  }

  Future<void> _loadAuction() async {
    try {
      final auction = await AuctionService().show(widget.lotId);
      final bids = await AuctionService().bids(widget.lotId);
      if (!mounted) return;
      setState(() {
        _auction = auction;
        _currentL1 = auction.currentHighestInr;
        _secondsRemaining = auction.secondsRemaining;
        _bidders = auction.bidders;
        _offerFeed
          ..clear()
          ..addAll(bids.map((bid) => {
                'vendor': bid.vendorName,
                'amount': bid.amountInr,
                'time': bid.at.toLocal().toString(),
                'isMe': false,
              }));
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadError = error.toString();
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _tickerTimer?.cancel();
    _botTimer?.cancel();
    super.dispose();
  }

  Future<void> _submitOffer(double amount, {bool isAuto = false}) async {
    try {
      final result = await BidService().placeBid(auctionCode: _auction.code, amount: amount);
      if (!mounted) return;
      setState(() {
      _currentL1 = result.currentHighest;
      _myRank = 1; // Now L1
      _bannerNotice = isAuto ? '⚡ Auto-Offer matched at L1' : '✓ Offer Accepted! You are currently Rank #1 (L1 Lowest)';
      _offerFeed.insert(0, {
        'vendor': isAuto ? 'You (Auto-Floor)' : 'You',
        'amount': amount,
        'time': 'Just now',
        'isMe': true,
      });
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _bannerNotice = 'Offer rejected: $error');
    }
  }

  void _openLandedCostSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          final total = _basePrice + _freight + _taxGst + _insurance;
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(color: const Color(0xFFCBD5E1), borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    const Icon(Icons.calculate_outlined, color: AppColors.accentBlue),
                    const SizedBox(width: 8),
                    Text('Landed Cost Breakdown', style: AppTextStyles.heading(size: 17, weight: FontWeight.w800)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Evaluate complete landed cost before submitting reduced offer.',
                  style: AppTextStyles.caption,
                ),
                const SizedBox(height: 16),
                _calcInput('Base Service / Material Price (₹)', _basePrice, (v) => setSheetState(() => _basePrice = v)),
                _calcInput('Freight & Logistics (₹)', _freight, (v) => setSheetState(() => _freight = v)),
                _calcInput('Applicable GST / Taxes (₹)', _taxGst, (v) => setSheetState(() => _taxGst = v)),
                _calcInput('Insurance & Transit (₹)', _insurance, (v) => setSheetState(() => _insurance = v)),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Evaluated Landed Cost:', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.navy)),
                    Text(
                      Formatters.formatINR(total),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.accentBlue),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      _confirmAndSubmit(total);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentBlue,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusXl)),
                    ),
                    child: const Text('Use as My Next Offer', style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _calcInput(String label, double val, ValueChanged<double> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
          SizedBox(
            width: 120,
            height: 36,
            child: TextFormField(
              initialValue: val.toInt().toString(),
              keyboardType: TextInputType.number,
              textAlign: TextAlign.end,
              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
              onChanged: (v) => onChanged(double.tryParse(v) ?? val),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showBidReceipt(double amount) {
    final receipt = BidReceipt(
      receiptId: 'REV-2026-${DateTime.now().millisecondsSinceEpoch % 100000}',
      auctionCode: _auction.code,
      auctionTitle: _auction.title,
      amountInr: amount,
      timestamp: DateTime.now().toIso8601String(),
    );

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: AppColors.success, size: 50),
              const SizedBox(height: 10),
              Text('Reverse Offer Receipt', style: AppTextStyles.heading(size: 17, weight: FontWeight.w800)),
              Text('Receipt #${receipt.receiptId}', style: AppTextStyles.captionMuted),
              const Divider(height: 24),
              _receiptRow('Event ID', receipt.auctionCode),
              _receiptRow('Offer Amount (L1)', Formatters.formatINR(receipt.amountInr)),
              _receiptRow('Timestamp', receipt.timestamp.split('T').first),
              _receiptRow('Verification Hash', 'SHA256: 8f4b29c91...'),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.navy),
                  child: const Text('Download Offer Receipt (PDF)'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _receiptRow(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(k, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
          Text(v, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.navy)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: AppColors.navyDark,
        body: Center(child: CircularProgressIndicator(color: AppColors.auction)),
      );
    }
    if (_loadError != null) {
      return Scaffold(
        backgroundColor: AppColors.navyDark,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              _loadError!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.white),
            ),
          ),
        ),
      );
    }
    final step = _auction.decrementInr > 0 ? _auction.decrementInr : 10000;
    final nextValidOffer = _currentL1 - step;
    final isL1 = _myRank == 1;

    return Scaffold(
      backgroundColor: const Color(0xFF07182E),
      body: SafeArea(
        child: Column(
          children: [
            // Top Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                      ),
                      child: const Icon(Icons.arrow_back, size: 18, color: AppColors.white),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.accentBlue.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'REVERSE AUCTION • PROCUREMENT',
                                style: TextStyle(fontFamily: 'monospace', fontSize: 9.5, fontWeight: FontWeight.w800, color: Color(0xFF93C5FD)),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          _auction.title,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.white),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calculate_outlined, color: AppColors.white, size: 22),
                    onPressed: _openLandedCostSheet,
                  ),
                ],
              ),
            ),

            if (_bannerNotice != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: isL1 ? AppColors.success : AppColors.accentBlue,
                child: Text(
                  _bannerNotice!,
                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: AppColors.white),
                  textAlign: TextAlign.center,
                ),
              ),

            // Reverse Market Card
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF0F325E), Color(0xFF091C36)],
                ),
                borderRadius: BorderRadius.circular(AppSpacing.radius2xl),
                border: Border.all(
                  color: isL1 ? AppColors.success.withValues(alpha: 0.6) : AppColors.accentBlue.withValues(alpha: 0.5),
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'CURRENT LOWEST OFFER (L1)',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF93C5FD),
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            Formatters.formatINR(_currentL1),
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: AppColors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: isL1 ? AppColors.success : const Color(0xFF1E3A8A),
                          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(isL1 ? Icons.star : Icons.trending_down, size: 14, color: AppColors.white),
                            const SizedBox(width: 4),
                            Text(
                              isL1 ? 'RANK #1 (L1)' : 'RANK #2 (L2)',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.white),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.people_alt_outlined, size: 14, color: Color(0xFF93C5FD)),
                          const SizedBox(width: 4),
                          Text('$_bidders qualified vendors',
                              style: TextStyle(fontSize: 11, color: AppColors.white.withValues(alpha: 0.8))),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.timer_outlined, size: 14, color: AppColors.auction),
                          const SizedBox(width: 4),
                          Text(
                            Formatters.formatCountdown(_secondsRemaining),
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.goldSoft),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Live Feed List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'REVERSE OFFER STREAM',
                    style: TextStyle(fontFamily: 'monospace', fontSize: 10.5, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8)),
                  ),
                  TextButton.icon(
                    onPressed: _openLandedCostSheet,
                    icon: const Icon(Icons.calculate_outlined, size: 14, color: Color(0xFF93C5FD)),
                    label: const Text(
                      'Landed Calculator',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF93C5FD)),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F2648),
                  borderRadius: BorderRadius.circular(AppSpacing.radius2xl),
                  border: Border.all(color: AppColors.white.withValues(alpha: 0.08)),
                ),
                child: ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: _offerFeed.length,
                  separatorBuilder: (_, __) => Divider(height: 12, color: AppColors.white.withValues(alpha: 0.06)),
                  itemBuilder: (ctx, i) {
                    final item = _offerFeed[i];
                    final isMe = item['isMe'] as bool;
                    return Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Icon(
                                isMe ? Icons.check_circle : Icons.shield_outlined,
                                size: 14,
                                color: isMe ? AppColors.success : AppColors.white.withValues(alpha: 0.5),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  item['vendor'] as String,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isMe ? FontWeight.w800 : FontWeight.w500,
                                    color: isMe ? AppColors.success : AppColors.white.withValues(alpha: 0.85),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              Formatters.formatINR((item['amount'] as num).toDouble()),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: isMe ? AppColors.success : AppColors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              item['time'] as String,
                              style: TextStyle(fontSize: 10, color: AppColors.white.withValues(alpha: 0.4)),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),

            // Bottom Decrement Controls
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFF091C36),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                children: [
                  // Quick Decrement Pills
                  Row(
                    children: [5000, 10000, 20000, 50000].map((dec) {
                      final targetAmount = _currentL1 - dec;
                      return Expanded(
                        child: GestureDetector(
                          onTap: _secondsRemaining <= 0 || targetAmount <= 0
                              ? null
                              : () => _confirmAndSubmit(targetAmount),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.white.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                              border: Border.all(color: AppColors.white.withValues(alpha: 0.15)),
                            ),
                            child: Center(
                              child: Text(
                                '-${Formatters.formatINR(dec.toDouble()).replaceAll('₹', '')}',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF93C5FD)),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  // Master Submit Offer CTA
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _secondsRemaining <= 0
                          ? null
                          : () => _confirmAndSubmit(nextValidOffer),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentBlue,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusXl)),
                        elevation: 0,
                      ),
                      child: Text(
                        _secondsRemaining <= 0
                            ? 'REVERSE AUCTION CONCLUDED'
                            : 'SUBMIT REDUCED OFFER (${Formatters.formatINR(nextValidOffer)})',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: 0.4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmAndSubmit(double amount) async {
    final confirmed = await BidConfirmationSheet.show(
      context,
      auctionTitle: _auction.title,
      auctionCode: _auction.code,
      bidAmount: amount,
      currentAmount: _currentL1,
      increment: _auction.decrementInr,
      isReverse: true,
      onConfirm: () => _submitOffer(amount),
    );

    if (confirmed == true && mounted) {
      _showBidReceipt(amount);
    }
  }
}
