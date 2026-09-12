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
  final DateTime? slotEndsAt;
  final int serverOffsetMs;
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
    this.slotEndsAt,
    this.serverOffsetMs = 0,
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
    DateTime? slotEndsAt,
    int? serverOffsetMs,
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
        slotEndsAt: slotEndsAt ?? this.slotEndsAt,
        serverOffsetMs: serverOffsetMs ?? this.serverOffsetMs,
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
      _applyLiveState(liveState);
    } catch (_) {}

    // Fetch recent bids
    try {
      final bids = await _auctionService.bids(state.auctionCode);
      state = state.copyWith(recentBids: bids.take(20).toList());
    } catch (_) {}

    // Connect WebSocket
    await _channel.connect(state.auctionCode, pollRequest: _pollLiveState);
    _bidSub = _channel.onBid.listen(_onBid);
    _stateSub = _channel.onStateChange.listen(_onState);

    // Start countdown
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final endsAt = state.slotEndsAt;
      if (endsAt == null) return;
      final remaining = endsAt
          .difference(DateTime.now().add(Duration(milliseconds: state.serverOffsetMs)))
          .inSeconds
          .clamp(0, 999999);
      state = state.copyWith(secondsRemaining: remaining);
    });
  }

  void _onBid(Bid bid) {
    final bids = [
      bid,
      ...state.recentBids.where((item) => item.id != bid.id),
    ].take(20).toList();
    state = state.copyWith(recentBids: bids);
    _pollLiveState();
  }

  void _onState(Map<String, dynamic> data) async {
    // Broadcast payloads are hints only. Refresh the complete authoritative
    // snapshot so reverse ranking, slot cutoff, and server time stay correct.
    await _pollLiveState();
  }

  Future<Map<String, dynamic>> _pollLiveState() async {
    final liveState = await _auctionService.liveState(state.auctionCode);
    _applyLiveState(liveState);
    return liveState;
  }

  void _applyLiveState(Map<String, dynamic> liveState) {
    final direction = liveState['direction'] as String?;
    final value = direction == 'reverse'
        ? liveState['current_lowest_inr'] ?? liveState['current_price_inr']
        : liveState['current_highest_inr'] ?? liveState['current_price_inr'];
    final serverTime = DateTime.tryParse(liveState['server_time'] as String? ?? '');
    final endsAt = (liveState['active_slot'] as Map<String, dynamic>?)?['ends_at'] ??
        liveState['schedule_end'];
    final slotEndsAt = DateTime.tryParse(endsAt as String? ?? '');
    final offset = serverTime == null
        ? state.serverOffsetMs
        : serverTime.difference(DateTime.now()).inMilliseconds;
    final remaining = slotEndsAt == null
        ? (liveState['seconds_remaining'] as num?)?.toInt() ?? 0
        : slotEndsAt
            .difference(DateTime.now().add(Duration(milliseconds: offset)))
            .inSeconds
            .clamp(0, 999999);
    state = state.copyWith(
      currentHighest: (value as num?)?.toDouble() ?? state.currentHighest,
      bidders: (liveState['bidders'] as num?)?.toInt() ?? state.bidders,
      secondsRemaining: remaining,
      slotEndsAt: slotEndsAt,
      serverOffsetMs: offset,
    );
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
