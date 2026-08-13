import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/bid.dart';
import '../models/my_bid.dart';
import '../services/auction_service.dart';
import '../services/bid_service.dart';
import '../services/live_auction_channel.dart';

final _bidService = BidService();
final _auctionService = AuctionService();

final bidHistoryProvider =
    FutureProvider.family<List<Bid>, String>((ref, auctionCode) async {
  return _auctionService.bids(auctionCode);
});

final myBidsProvider = FutureProvider<({List<MyBid> active, List<MyBid> won, List<MyBid> lost})>(
  (ref) async => _bidService.myBids(),
);

final liveBidProvider =
    StateNotifierProvider.family<LiveBidNotifier, LiveBidState, String>(
  (ref, auctionCode) => LiveBidNotifier(auctionCode),
);

class LiveBidState {
  final String auctionCode;
  final double currentHighest;
  final int bidders;
  final int secondsRemaining;
  final List<Bid> recentBids;
  final bool autoBidActive;
  final double? proxyMaxAmount;
  final bool isPlacingBid;
  final String? error;

  const LiveBidState({
    required this.auctionCode,
    this.currentHighest = 0,
    this.bidders = 0,
    this.secondsRemaining = 0,
    this.recentBids = const [],
    this.autoBidActive = false,
    this.proxyMaxAmount,
    this.isPlacingBid = false,
    this.error,
  });

  LiveBidState copyWith({
    double? currentHighest,
    int? bidders,
    int? secondsRemaining,
    List<Bid>? recentBids,
    bool? autoBidActive,
    double? proxyMaxAmount,
    bool? isPlacingBid,
    String? error,
  }) =>
      LiveBidState(
        auctionCode: auctionCode,
        currentHighest: currentHighest ?? this.currentHighest,
        bidders: bidders ?? this.bidders,
        secondsRemaining: secondsRemaining ?? this.secondsRemaining,
        recentBids: recentBids ?? this.recentBids,
        autoBidActive: autoBidActive ?? this.autoBidActive,
        proxyMaxAmount: proxyMaxAmount ?? this.proxyMaxAmount,
        isPlacingBid: isPlacingBid ?? this.isPlacingBid,
        error: error,
      );
}

class LiveBidNotifier extends StateNotifier<LiveBidState> {
  final LiveAuctionChannel _channel = LiveAuctionChannel();
  Timer? _countdownTimer;
  StreamSubscription? _bidSub;
  StreamSubscription? _stateSub;

  LiveBidNotifier(String auctionCode)
      : super(LiveBidState(auctionCode: auctionCode)) {
    _init();
  }

  Future<void> _init() async {
    // Fetch initial state
    try {
      final liveState = await _auctionService.liveState(state.auctionCode);
      state = state.copyWith(
        currentHighest: (liveState['current_highest_inr'] as num?)?.toDouble() ?? 0,
        bidders: liveState['bidders'] as int? ?? 0,
        secondsRemaining: liveState['seconds_remaining'] as int? ?? 0,
      );
    } catch (_) {}

    // Fetch recent bids
    try {
      final bids = await _auctionService.bids(state.auctionCode);
      state = state.copyWith(recentBids: bids.take(20).toList());
    } catch (_) {}

    // Connect WebSocket
    await _channel.connect(state.auctionCode);
    _bidSub = _channel.onBid.listen(_onBid);
    _stateSub = _channel.onStateChange.listen(_onState);

    // Start countdown
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.secondsRemaining > 0) {
        state = state.copyWith(secondsRemaining: state.secondsRemaining - 1);
      }
    });
  }

  void _onBid(Bid bid) {
    state = state.copyWith(
      currentHighest: bid.amountInr,
      recentBids: [bid, ...state.recentBids].take(20).toList(),
    );
  }

  void _onState(Map<String, dynamic> data) async {
    if (data.containsKey('poll')) {
      // Polling fallback — re-fetch live state
      try {
        final liveState = await _auctionService.liveState(state.auctionCode);
        state = state.copyWith(
          currentHighest: (liveState['current_highest_inr'] as num?)?.toDouble(),
          bidders: liveState['bidders'] as int?,
          secondsRemaining: liveState['seconds_remaining'] as int?,
        );
      } catch (_) {}
      return;
    }

    state = state.copyWith(
      currentHighest: (data['current_highest'] as num?)?.toDouble(),
      bidders: data['bidders_count'] as int?,
    );

    // Update schedule_end if extended
    if (data['schedule_end'] != null) {
      final end = DateTime.tryParse(data['schedule_end'] as String);
      if (end != null) {
        state = state.copyWith(
          secondsRemaining: end.difference(DateTime.now()).inSeconds.clamp(0, 999999),
        );
      }
    }
  }

  Future<void> placeBid(double amount, {String? lot}) async {
    state = state.copyWith(isPlacingBid: true, error: null);
    try {
      final result = await _bidService.placeBid(
        auctionCode: state.auctionCode,
        amount: amount,
        lot: lot,
      );
      state = state.copyWith(
        isPlacingBid: false,
        currentHighest: result.currentHighest,
        bidders: result.bidders,
        recentBids: [result.bid, ...state.recentBids].take(20).toList(),
      );
    } catch (e) {
      state = state.copyWith(
        isPlacingBid: false,
        error: e.toString(),
      );
    }
  }

  Future<void> toggleAutoBid(double maxAmount, {String? lot}) async {
    if (state.autoBidActive) {
      try {
        await _bidService.cancelProxyBid(state.auctionCode, lot: lot);
        state = state.copyWith(autoBidActive: false, proxyMaxAmount: null);
      } catch (_) {}
    } else {
      try {
        await _bidService.setProxyBid(
          auctionCode: state.auctionCode,
          maxAmount: maxAmount,
          lot: lot,
        );
        state = state.copyWith(autoBidActive: true, proxyMaxAmount: maxAmount);
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _bidSub?.cancel();
    _stateSub?.cancel();
    _channel.dispose();
    super.dispose();
  }
}
