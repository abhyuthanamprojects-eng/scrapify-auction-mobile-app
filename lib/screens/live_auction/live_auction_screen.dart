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
import '../../providers/auction_provider.dart';
import '../../services/mock_bidplay_repository.dart';
import '../../widgets/shared/bid_confirmation_sheet.dart';

class LiveAuctionScreen extends ConsumerStatefulWidget {
  final String lotId;
  const LiveAuctionScreen({super.key, required this.lotId});

  @override
  ConsumerState<LiveAuctionScreen> createState() => _LiveAuctionScreenState();
}

class _LiveAuctionScreenState extends ConsumerState<LiveAuctionScreen> {
  late Auction _auction;
  late double _currentHighest;
  late int _secondsRemaining;
  late int _bidders;
  double? _myLastBid;
  int _myRank = 2;
  bool _isAutoBidEnabled = false;
  double _autoBidCeiling = 3000000;
  bool _isExtended = false;
  bool _isPaused = false;
  String? _bannerNotice;
  Timer? _tickerTimer;
  Timer? _botTimer;

  final List<Map<String, dynamic>> _bidFeed = [];

  @override
  void initState() {
    super.initState();
    final repo = MockBidPlayRepository();
    final initial = repo.getAuction(widget.lotId) ??
        Auction(
          code: widget.lotId,
          title: 'Industrial Copper Scrap & Cables',
          company: 'Tata Power Heavy Logistics',
          currentHighestInr: 2480000,
          bidIncrementInr: 20000,
          scheduleEnd: DateTime.now().add(const Duration(minutes: 6, seconds: 30)).toIso8601String(),
        );

    _auction = initial;
    _currentHighest = initial.currentHighestInr > 0 ? initial.currentHighestInr : 2480000;
    _secondsRemaining = initial.secondsRemaining > 0 ? initial.secondsRemaining : 390;
    _bidders = initial.bidders > 0 ? initial.bidders : 14;
    _myLastBid = initial.myLastBidInr ?? 2460000;

    _bidFeed.addAll([
      {'bidder': 'Bidder #14', 'amount': _currentHighest, 'time': 'Just now', 'isMe': false},
      {'bidder': 'You', 'amount': _currentHighest - 20000, 'time': '18s ago', 'isMe': true},
      {'bidder': 'Bidder #07', 'amount': _currentHighest - 40000, 'time': '45s ago', 'isMe': false},
    ]);

    // Main Countdown Timer
    _tickerTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted || _isPaused) return;
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
          if (_secondsRemaining == 30 && !_isExtended) {
            _isExtended = true;
            _secondsRemaining += 120;
            _bannerNotice = '⚡ +2:00 mins extended due to active bid activity';
          }
        }
      });
    });

    // Simulated Opponent Bids
    _botTimer = Timer.periodic(const Duration(seconds: 14), (t) {
      if (!mounted || _isPaused || _secondsRemaining <= 0) return;
      final step = _auction.bidIncrementInr > 0 ? _auction.bidIncrementInr : 20000;
      final nextPrice = _currentHighest + step;
      final botName = 'Bidder #${(10 + (t.tick % 8))}';

      setState(() {
        _currentHighest = nextPrice;
        _bidders++;
        _myRank = 2; // Outbid
        _bidFeed.insert(0, {
          'bidder': botName,
          'amount': nextPrice,
          'time': 'Just now',
          'isMe': false,
        });
        _bannerNotice = '⚠️ You have been outbid by $botName';
      });

      // Auto-Bid Response
      if (_isAutoBidEnabled && nextPrice + step <= _autoBidCeiling) {
        Future.delayed(const Duration(seconds: 2), () {
          if (!mounted) return;
          _submitBid(nextPrice + step, isAuto: true);
        });
      }
    });
  }

  @override
  void dispose() {
    _tickerTimer?.cancel();
    _botTimer?.cancel();
    super.dispose();
  }

  void _submitBid(double amount, {bool isAuto = false}) {
    setState(() {
      _currentHighest = amount;
      _myLastBid = amount;
      _myRank = 1; // Leading
      _bannerNotice = isAuto ? '⚡ Auto-Bid placed successfully' : '✓ Bid Accepted! You are currently Rank #1 (Leading)';
      _bidFeed.insert(0, {
        'bidder': isAuto ? 'You (Auto-Proxy)' : 'You',
        'amount': amount,
        'time': 'Just now',
        'isMe': true,
      });
    });
    MockBidPlayRepository().placeBid(_auction.code, amount);
  }

  void _openAutoBidSheet() {
    final step = _auction.bidIncrementInr > 0 ? _auction.bidIncrementInr : 20000;
    double ceiling = _autoBidCeiling;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
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
                  const Icon(Icons.smart_toy_outlined, color: AppColors.auction),
                  const SizedBox(width: 8),
                  Text('Set Auto-Bid Proxy Ceiling', style: AppTextStyles.heading(size: 17, weight: FontWeight.w800)),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Scrapify system will automatically increment bids by ${Formatters.formatINR(step)} on your behalf up to your maximum limit.',
                style: AppTextStyles.caption,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.appBg, borderRadius: BorderRadius.circular(AppSpacing.radiusLg)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Max Bid Ceiling:', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.navy)),
                    Text(Formatters.formatINR(ceiling), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.navy)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Slider.adaptive(
                min: _currentHighest + step,
                max: _currentHighest + (step * 25),
                divisions: 24,
                value: ceiling.clamp(_currentHighest + step, _currentHighest + (step * 25)),
                activeColor: AppColors.auction,
                onChanged: (v) => setSheetState(() => ceiling = v),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _autoBidCeiling = ceiling;
                      _isAutoBidEnabled = true;
                      _bannerNotice = '⚡ Auto-Bid active up to ${Formatters.formatINR(ceiling)}';
                    });
                    Navigator.of(ctx).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.auction,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusXl)),
                  ),
                  child: const Text('Enable Auto-Proxy Bidding', style: TextStyle(fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBidReceipt(double amount) {
    final receipt = BidReceipt(
      receiptId: 'REC-2026-${DateTime.now().millisecondsSinceEpoch % 100000}',
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
              Text('Official Bid Receipt', style: AppTextStyles.heading(size: 17, weight: FontWeight.w800)),
              Text('Receipt #${receipt.receiptId}', style: AppTextStyles.captionMuted),
              const Divider(height: 24),
              _receiptRow('Event ID', receipt.auctionCode),
              _receiptRow('Bid Amount', Formatters.formatINR(receipt.amountInr)),
              _receiptRow('Timestamp', receipt.timestamp.split('T').first),
              _receiptRow('IP Signature', '103.21.244.10 (Verified)'),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.navy),
                  child: const Text('Download Receipt (PDF)'),
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
    final step = _auction.bidIncrementInr > 0 ? _auction.bidIncrementInr : 20000;
    final nextValidBid = _currentHighest + step;
    final isLeading = _myRank == 1;

    return Scaffold(
      backgroundColor: AppColors.navyDark,
      body: SafeArea(
        child: Column(
          children: [
            // Top Live Header
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
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(color: AppColors.destructive, shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'FORWARD LIVE AUCTION ROOM',
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.goldSoft,
                                letterSpacing: 1.2,
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
                  // Emergency Pause Simulation Toggle (Admin testing)
                  IconButton(
                    icon: Icon(
                      _isPaused ? Icons.play_arrow : Icons.pause,
                      color: AppColors.white.withValues(alpha: 0.7),
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPaused = !_isPaused;
                        _bannerNotice = _isPaused ? '⏸ Auction paused by administrator' : null;
                      });
                    },
                  ),
                ],
              ),
            ),

            // Notice Alert Banner
            if (_bannerNotice != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: isLeading ? AppColors.success : AppColors.auction,
                child: Text(
                  _bannerNotice!,
                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: AppColors.white),
                  textAlign: TextAlign.center,
                ),
              ),

            // Main Market Bidding Box
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: AppColors.gradientNoir,
                borderRadius: BorderRadius.circular(AppSpacing.radius2xl),
                border: Border.all(
                  color: isLeading ? AppColors.success.withValues(alpha: 0.5) : AppColors.auction.withValues(alpha: 0.4),
                  width: 1.5,
                ),
                boxShadow: isLeading ? AppColors.shadowSm : AppColors.shadowGold,
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
                            'CURRENT HIGHEST BID',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: AppColors.goldSoft,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            Formatters.formatINR(_currentHighest),
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: AppColors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                      // Rank Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: isLeading ? AppColors.success : AppColors.destructive,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(isLeading ? Icons.emoji_events : Icons.trending_down, size: 14, color: AppColors.white),
                            const SizedBox(width: 4),
                            Text(
                              isLeading ? 'RANK #1 LEADING' : 'RANK #2 OUTBID',
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
                          const Icon(Icons.people_alt_outlined, size: 14, color: AppColors.goldSoft),
                          const SizedBox(width: 4),
                          Text('$_bidders active bidders',
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
                    'LIVE BID STREAM (MASKED)',
                    style: TextStyle(fontFamily: 'monospace', fontSize: 10.5, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8)),
                  ),
                  TextButton.icon(
                    onPressed: _openAutoBidSheet,
                    icon: Icon(Icons.smart_toy_outlined, size: 14, color: _isAutoBidEnabled ? AppColors.success : AppColors.goldSoft),
                    label: Text(
                      _isAutoBidEnabled ? 'Auto-Bid Active' : 'Set Auto-Bid',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _isAutoBidEnabled ? AppColors.success : AppColors.goldSoft,
                      ),
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
                  itemCount: _bidFeed.length,
                  separatorBuilder: (_, __) => Divider(height: 12, color: AppColors.white.withValues(alpha: 0.06)),
                  itemBuilder: (ctx, i) {
                    final item = _bidFeed[i];
                    final isMe = item['isMe'] as bool;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              isMe ? Icons.person_pin : Icons.shield_outlined,
                              size: 14,
                              color: isMe ? AppColors.success : AppColors.white.withValues(alpha: 0.5),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              item['bidder'] as String,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isMe ? FontWeight.w800 : FontWeight.w500,
                                color: isMe ? AppColors.success : AppColors.white.withValues(alpha: 0.85),
                              ),
                            ),
                          ],
                        ),
                        Row(
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

            // Bottom Bid Control Area
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFF0B1F3A),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                children: [
                  // Quick Increment Pills
                  Row(
                    children: [5000, 10000, 25000, 50000].map((inc) {
                      final targetAmount = _currentHighest + inc;
                      return Expanded(
                        child: GestureDetector(
                          onTap: _isPaused || _secondsRemaining <= 0
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
                                '+${Formatters.formatINR(inc.toDouble()).replaceAll('₹', '')}',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.goldSoft),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  // Master Bid CTA Button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isPaused || _secondsRemaining <= 0
                          ? null
                          : () => _confirmAndSubmit(nextValidBid),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.auction,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusXl)),
                        elevation: 0,
                      ),
                      child: Text(
                        _secondsRemaining <= 0
                            ? 'AUCTION CONCLUDED'
                            : _isPaused
                                ? 'AUCTION PAUSED'
                                : 'BID ${Formatters.formatINR(nextValidBid)}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 0.5),
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
      currentAmount: _currentHighest,
      increment: _auction.bidIncrementInr,
      isReverse: false,
      onConfirm: () => _submitBid(amount),
    );

    if (confirmed == true && mounted) {
      _showBidReceipt(amount);
    }
  }
}
