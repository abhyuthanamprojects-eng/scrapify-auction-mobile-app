import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/formatters.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auction_provider.dart';
import '../../providers/bid_provider.dart';
import '../../models/auction.dart';

class LiveAuctionScreen extends ConsumerStatefulWidget {
  final String lotId;
  const LiveAuctionScreen({super.key, required this.lotId});

  @override
  ConsumerState<LiveAuctionScreen> createState() => _LiveAuctionScreenState();
}

class _LiveAuctionScreenState extends ConsumerState<LiveAuctionScreen> {
  double _bidAmount = 0;
  bool _showSuccess = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() async {
    try {
      final auction = await ref.read(auctionDetailProvider(widget.lotId).future);
      if (mounted) {
        setState(() {
          _bidAmount = auction.currentHighestInr + auction.bidIncrementInr;
          _initialized = true;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _initialized = true);
    }
  }

  Future<void> _placeBid() async {
    final notifier = ref.read(liveBidProvider(widget.lotId).notifier);
    await notifier.placeBid(_bidAmount);
    final state = ref.read(liveBidProvider(widget.lotId));
    if (state.error == null) {
      setState(() {
        _showSuccess = true;
        _bidAmount = state.currentHighest + (ref.read(auctionDetailProvider(widget.lotId)).valueOrNull?.bidIncrementInr ?? 5000);
      });
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _showSuccess = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(liveBidProvider(widget.lotId));
    final auctionAsync = ref.watch(auctionDetailProvider(widget.lotId));

    if (!_initialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.auction)),
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.gradientNoir),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context, auctionAsync),
              _buildStatusBanner(state),
              _buildBidDisplay(state),
              const SizedBox(height: 12),
              _buildTimerRow(state),
              const Spacer(),
              _buildBidControls(state, auctionAsync.valueOrNull?.bidIncrementInr ?? 5000),
              _buildQuickIncrements(),
              const SizedBox(height: 12),
              _buildPlaceBidButton(state),
              if (state.error != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPaddingH, vertical: 4),
                  child: Text(state.error!, style: TextStyle(fontSize: 12, color: AppColors.destructive)),
                ),
              const SizedBox(height: 8),
              _buildBidFeed(state),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AsyncValue<Auction> auctionAsync) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.screenPaddingH, 8, AppSpacing.screenPaddingH, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.whiteWithOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              ),
              child: const Icon(Icons.arrow_back, size: 18, color: AppColors.white),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Live Auction',
                  style: AppTextStyles.titleSmall.copyWith(color: AppColors.white),
                ),
                auctionAsync.whenOrNull(
                      data: (auction) => Text(
                        auction.title,
                        style: AppTextStyles.caption.copyWith(color: AppColors.whiteWithOpacity(0.6)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ) ??
                    const SizedBox.shrink(),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle)),
                const SizedBox(width: 4),
                Text('LIVE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.success)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBanner(LiveBidState state) {
    if (_showSuccess) {
      return Container(
        margin: const EdgeInsets.fromLTRB(AppSpacing.screenPaddingH, 12, AppSpacing.screenPaddingH, 0),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle, size: 16, color: AppColors.success),
            const SizedBox(width: 8),
            Text('Bid placed successfully!', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.success)),
          ],
        ),
      );
    }

    if (state.autoBidActive) {
      return Container(
        margin: const EdgeInsets.fromLTRB(AppSpacing.screenPaddingH, 12, AppSpacing.screenPaddingH, 0),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.accentBlue.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        child: Row(
          children: [
            const Icon(Icons.autorenew, size: 16, color: AppColors.accentBlue),
            const SizedBox(width: 8),
            Text('Auto-bid active up to ${Formatters.formatINR(state.proxyMaxAmount ?? 0)}',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.accentBlue)),
          ],
        ),
      );
    }

    return const SizedBox(height: 12);
  }

  Widget _buildBidDisplay(LiveBidState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.screenPaddingH, 24, AppSpacing.screenPaddingH, 0),
      child: Column(
        children: [
          Text('CURRENT BID', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.whiteWithOpacity(0.5), letterSpacing: 1)),
          const SizedBox(height: 4),
          Text(
            Formatters.formatINR(state.currentHighest),
            style: AppTextStyles.heading(size: 36, weight: FontWeight.w900, color: AppColors.white),
          ),
          const SizedBox(height: 4),
          Text('${state.bidders} bidders', style: TextStyle(fontSize: 12, color: AppColors.whiteWithOpacity(0.5))),
        ],
      ),
    );
  }

  Widget _buildTimerRow(LiveBidState state) {
    final isUrgent = state.secondsRemaining < 60;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPaddingH),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.whiteWithOpacity(0.05),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.access_time, size: 16, color: isUrgent ? AppColors.destructive : AppColors.auction),
          const SizedBox(width: 6),
          Text(
            Formatters.formatCountdown(state.secondsRemaining),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: isUrgent ? AppColors.destructive : AppColors.auction,
            ),
          ),
          if (isUrgent) ...[
            const SizedBox(width: 8),
            Text('Auto-extends at 15s', style: TextStyle(fontSize: 10, color: AppColors.whiteWithOpacity(0.5))),
          ],
        ],
      ),
    );
  }

  Widget _buildBidControls(LiveBidState state, double increment) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPaddingH),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.whiteWithOpacity(0.05),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
      ),
      child: Row(
        children: [
          _stepButton(Icons.remove, () {
            setState(() => _bidAmount = (_bidAmount - increment).clamp(state.currentHighest + increment, double.infinity));
          }),
          Expanded(
            child: Column(
              children: [
                Text('YOUR BID', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.whiteWithOpacity(0.5))),
                Text(
                  Formatters.formatINR(_bidAmount),
                  style: AppTextStyles.heading(size: 24, weight: FontWeight.w800, color: AppColors.white),
                ),
              ],
            ),
          ),
          _stepButton(Icons.add, () {
            setState(() => _bidAmount += increment);
          }),
        ],
      ),
    );
  }

  Widget _stepButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.whiteWithOpacity(0.1),
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        child: Icon(icon, color: AppColors.white, size: 20),
      ),
    );
  }

  Widget _buildQuickIncrements() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.screenPaddingH, 8, AppSpacing.screenPaddingH, 0),
      child: Row(
        children: AppConstants.quickIncrements.map((inc) {
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _bidAmount += inc),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.whiteWithOpacity(0.05),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(color: AppColors.whiteWithOpacity(0.1)),
                ),
                child: Center(
                  child: Text(
                    '+₹${(inc / 1000).toStringAsFixed(0)}K',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.whiteWithOpacity(0.7)),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPlaceBidButton(LiveBidState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPaddingH),
      child: SizedBox(
        width: double.infinity,
        height: AppSpacing.buttonXl,
        child: ElevatedButton(
          onPressed: state.isPlacingBid || state.secondsRemaining <= 0 ? null : _placeBid,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.auction,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            ),
          ),
          child: state.isPlacingBid
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white))
              : Text('Place Bid ${Formatters.formatINR(_bidAmount)}'),
        ),
      ),
    );
  }

  Widget _buildBidFeed(LiveBidState state) {
    if (state.recentBids.isEmpty) return const SizedBox.shrink();
    return Container(
      height: 80,
      margin: const EdgeInsets.fromLTRB(AppSpacing.screenPaddingH, 8, AppSpacing.screenPaddingH, 0),
      child: ListView.builder(
        reverse: true,
        itemCount: state.recentBids.length.clamp(0, 5),
        itemBuilder: (_, i) {
          final bid = state.recentBids[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.whiteWithOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      bid.vendorName.isNotEmpty ? bid.vendorName[0] : '?',
                      style: TextStyle(fontSize: 10, color: AppColors.white, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(bid.vendorName, style: TextStyle(fontSize: 12, color: AppColors.whiteWithOpacity(0.7))),
                const Spacer(),
                Text(
                  Formatters.formatINR(bid.amountInr),
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.whiteWithOpacity(0.7)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
