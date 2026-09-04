import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/formatters.dart';
import '../../models/bid_receipt.dart';
import '../../widgets/shared/empty_state.dart';

class MyBidsScreen extends ConsumerStatefulWidget {
  const MyBidsScreen({super.key});

  @override
  ConsumerState<MyBidsScreen> createState() => _MyBidsScreenState();
}

class _MyBidsScreenState extends ConsumerState<MyBidsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _myBids = [
    {
      'auctionCode': 'BP-FWD-2026-1048',
      'title': 'Industrial Copper Scrap & Armoured Cables (28 MT)',
      'seller': 'Tata Power Limited',
      'direction': 'forward',
      'myLastBidInr': 1680000.0,
      'currentHighestInr': 1680000.0,
      'myRank': 1,
      'totalBidders': 14,
      'status': 'LIVE',
      'bidTime': 'Today, 02:44:12 PM',
      'receiptId': 'RCPT-BP-FWD-2026-1048-001',
      'signature': 'SHA256:4f8a9b2c...d1e8',
    },
    {
      'auctionCode': 'BP-REV-2026-0512',
      'title': 'Pan-India Inbound Logistics & Fleet Freight Contract',
      'seller': 'Vedanta Heavy Logistics',
      'direction': 'reverse',
      'myLastBidInr': 4850000.0,
      'currentHighestInr': 4650000.0,
      'myRank': 2,
      'totalBidders': 8,
      'status': 'LIVE',
      'bidTime': 'Today, 02:38:05 PM',
      'receiptId': 'RCPT-BP-REV-2026-0512-004',
      'signature': 'SHA256:9a3f1c8e...b4d2',
    },
    {
      'auctionCode': 'BP-FWD-2026-0994',
      'title': 'Aluminium Extrusion Scrap Lot (6063 Alloy)',
      'seller': 'Hindalco Industries',
      'direction': 'forward',
      'myLastBidInr': 1840000.0,
      'currentHighestInr': 1840000.0,
      'myRank': 1,
      'totalBidders': 11,
      'status': 'AWARDED',
      'bidTime': '28 Aug 2026, 04:15 PM',
      'receiptId': 'RCPT-BP-FWD-2026-0994-012',
      'signature': 'SHA256:7b2c9d1a...f8e3',
    },
    {
      'auctionCode': 'BP-FWD-2026-0912',
      'title': 'Heavy Machinery Copper Windings & Transformers',
      'seller': 'BHEL Bhopal',
      'direction': 'forward',
      'myLastBidInr': 920000.0,
      'currentHighestInr': 980000.0,
      'myRank': 3,
      'totalBidders': 19,
      'status': 'CLOSED',
      'bidTime': '25 Aug 2026, 05:30 PM',
      'receiptId': 'RCPT-BP-FWD-2026-0912-009',
      'signature': 'SHA256:1e4d8a2f...c9b7',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _viewReceipt(Map<String, dynamic> b) {
    final receipt = BidReceipt(
      receiptId: b['receiptId'] as String,
      auctionCode: b['auctionCode'] as String,
      auctionTitle: b['title'] as String,
      amountInr: (b['myLastBidInr'] as num).toDouble(),
      rankAtSubmission: b['myRank'] as int,
      timestamp: b['bidTime'] as String,
      signatureHash: b['signature'] as String,
      clientIp: '49.37.142.88',
      deviceId: 'Apple iPhone 15 Pro',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(22),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFCBD5E1), borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('OFFICIAL DIGITAL BID RECEIPT', style: TextStyle(fontFamily: 'monospace', fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.auction)),
                    Text(receipt.receiptId, style: AppTextStyles.heading(size: 15, weight: FontWeight.w900)),
                  ],
                ),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(ctx).pop()),
              ],
            ),
            const Divider(height: 20),
            _receiptRow('Event Code', receipt.auctionCode),
            _receiptRow('Submitted Bid Price', Formatters.formatINR(receipt.bidAmountInr), isBold: true),
            _receiptRow('Rank at Submission', 'Rank #${receipt.rankAtSubmission}'),
            _receiptRow('Digital Timestamp', receipt.timestamp),
            _receiptRow('Verified Device ID', receipt.deviceId),
            _receiptRow('Audit IP Address', receipt.ipAddress),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: AppColors.appBg, borderRadius: BorderRadius.circular(8)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('SHA-256 TAMPER-PROOF SIGNATURE', style: TextStyle(fontFamily: 'monospace', fontSize: 9.5, fontWeight: FontWeight.w800, color: Color(0xFF64748B))),
                  const SizedBox(height: 2),
                  Text(receipt.cryptographicSignature, style: const TextStyle(fontFamily: 'monospace', fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.navy)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✓ Official Bid Receipt PDF downloaded')));
                },
                icon: const Icon(Icons.download, size: 18),
                label: const Text('Download Cryptographic PDF', style: TextStyle(fontWeight: FontWeight.w800)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.navy,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusXl)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _receiptRow(String k, String v, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(k, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
          Text(v, style: TextStyle(fontSize: 12.5, fontWeight: isBold ? FontWeight.w900 : FontWeight.w700, color: AppColors.navy)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBg,
      appBar: AppBar(
        title: const Text('My Bids & Live Submissions'),
        backgroundColor: AppColors.navy,
        foregroundColor: AppColors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppColors.auction,
          unselectedLabelColor: AppColors.white.withValues(alpha: 0.7),
          indicatorColor: AppColors.auction,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'All Bids (4)'),
            Tab(text: 'Leading Rank (2)'),
            Tab(text: 'Outbid (1)'),
            Tab(text: 'Won / Awarded (1)'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBidList(null),
          _buildBidList('leading'),
          _buildBidList('outbid'),
          _buildBidList('won'),
        ],
      ),
    );
  }

  Widget _buildBidList(String? filter) {
    List<Map<String, dynamic>> list;
    if (filter == 'leading') {
      list = _myBids.where((b) => b['myRank'] == 1 && b['status'] == 'LIVE').toList();
    } else if (filter == 'outbid') {
      list = _myBids.where((b) => (b['myRank'] as int) > 1 && b['status'] == 'LIVE').toList();
    } else if (filter == 'won') {
      list = _myBids.where((b) => b['status'] == 'AWARDED').toList();
    } else {
      list = _myBids;
    }

    if (list.isEmpty) {
      return const Center(
        child: EmptyState(
          icon: Icons.gavel_rounded,
          title: 'No bids found',
          subtitle: 'Participate in live forward or reverse auctions to track your active bids.',
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (ctx, i) {
        final b = list[i];
        final isReverse = b['direction'] == 'reverse';
        final isLeading = b['myRank'] == 1;
        final isLive = b['status'] == 'LIVE';

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radius2xl),
            border: Border.all(color: isLeading && isLive ? AppColors.success.withValues(alpha: 0.5) : AppColors.cardBorder),
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
                      color: isReverse ? AppColors.accentBlue.withValues(alpha: 0.12) : AppColors.auction.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      isReverse ? 'REVERSE (L1)' : 'FORWARD (H1)',
                      style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: isReverse ? AppColors.accentBlue : AppColors.auction),
                    ),
                  ),
                  _rankBadge(b['myRank'] as int, isReverse, isLive),
                ],
              ),
              const SizedBox(height: 10),
              Text(b['title'] as String, style: AppTextStyles.heading(size: 14.5, weight: FontWeight.w800)),
              const SizedBox(height: 2),
              Text('Seller: ${b['seller']} • ${b['totalBidders']} Bidders', style: AppTextStyles.captionMuted),
              const SizedBox(height: 12),

              // Price Summary Box
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.appBg,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('YOUR CONFIRMED BID', style: TextStyle(fontFamily: 'monospace', fontSize: 9.5, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
                        Text(Formatters.formatINR((b['myLastBidInr'] as num).toDouble()), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.navy)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(isReverse ? 'CURRENT L1 PRICE' : 'CURRENT HIGHEST (H1)', style: const TextStyle(fontFamily: 'monospace', fontSize: 9.5, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
                        Text(
                          Formatters.formatINR((b['currentHighestInr'] as num).toDouble()),
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: isLeading ? AppColors.success : AppColors.auction),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _viewReceipt(b),
                      icon: const Icon(Icons.receipt_long, size: 16),
                      label: const Text('Digital Receipt', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.navy,
                        side: const BorderSide(color: AppColors.cardBorder),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusLg)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (isLive) {
                          if (isReverse) {
                            context.push('/live-reverse/${b['auctionCode']}');
                          } else {
                            context.push('/live/${b['auctionCode']}');
                          }
                        } else {
                          context.push('/awards');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isLive ? (isLeading ? AppColors.success : AppColors.auction) : AppColors.navy,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusLg)),
                      ),
                      child: Text(
                        isLive ? (isLeading ? 'Leading • View' : 'Outbid • Bid Now') : 'View Award',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _rankBadge(int rank, bool isReverse, bool isLive) {
    final rankText = isReverse ? 'L$rank' : 'H$rank';
    final isTop = rank == 1;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isTop ? AppColors.success.withValues(alpha: 0.12) : AppColors.auction.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isTop ? Icons.star : Icons.trending_up, size: 14, color: isTop ? AppColors.success : AppColors.auction),
          const SizedBox(width: 4),
          Text('Rank: $rankText', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900, color: isTop ? AppColors.success : AppColors.auction)),
        ],
      ),
    );
  }
}
