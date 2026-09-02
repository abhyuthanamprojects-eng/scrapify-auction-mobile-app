import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/auction.dart';
import '../services/auction_service.dart';
import '../services/watchlist_service.dart';

final _auctionService = AuctionService();
final _watchlistService = WatchlistService();

final auctionsProvider = FutureProvider.family<List<Auction>, AuctionFilter>(
  (ref, filter) async {
    final result = await _auctionService.list(
      segment: filter.segment,
      category: filter.category,
      search: filter.search,
      direction: filter.direction,
      status: filter.status,
    );
    return result.auctions;
  },
);

final liveAuctionsProvider = FutureProvider<List<Auction>>((ref) async {
  final result = await _auctionService.list(segment: 'live');
  return result.auctions;
});

final upcomingAuctionsProvider = FutureProvider<List<Auction>>((ref) async {
  final result = await _auctionService.list(segment: 'upcoming');
  return result.auctions;
});

final allAuctionsProvider = FutureProvider<List<Auction>>((ref) async {
  final result = await _auctionService.list();
  return result.auctions;
});

final auctionDetailProvider =
    FutureProvider.family<Auction, String>((ref, code) async {
  return _auctionService.show(code);
});

final selectedCategoryProvider = StateProvider<String?>((ref) => null);

final watchlistProvider =
    StateNotifierProvider<WatchlistNotifier, Set<String>>(
  (ref) => WatchlistNotifier(),
);

class WatchlistNotifier extends StateNotifier<Set<String>> {
  WatchlistNotifier() : super(<String>{});

  Future<void> load() async {
    try {
      final auctions = await _watchlistService.list();
      state = auctions.map((a) => a.code).toSet();
    } catch (_) {
      rethrow;
    }
  }

  Future<void> toggle(String code) async {
    if (state.contains(code)) {
      await _watchlistService.remove(code);
      state = {...state}..remove(code);
    } else {
      await _watchlistService.add(code);
      state = {...state, code};
    }
  }

  bool isWatchlisted(String code) => state.contains(code);
}

class AuctionFilter {
  final String? segment;
  final String? category;
  final String? search;
  final String? direction;
  final String? status;
  final bool emdOnly;

  const AuctionFilter({
    this.segment,
    this.category,
    this.search,
    this.direction,
    this.status,
    this.emdOnly = false,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuctionFilter &&
          segment == other.segment &&
          category == other.category &&
          search == other.search &&
          direction == other.direction &&
          status == other.status &&
          emdOnly == other.emdOnly;

  @override
  int get hashCode => Object.hash(segment, category, search, direction, status, emdOnly);
}
