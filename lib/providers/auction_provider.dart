import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/auction.dart';
import '../services/auction_service.dart';
import '../services/watchlist_service.dart';
import '../services/mock_bidplay_repository.dart';

final _auctionService = AuctionService();
final _watchlistService = WatchlistService();
final _mockRepo = MockBidPlayRepository();

final auctionsProvider = FutureProvider.family<List<Auction>, AuctionFilter>(
  (ref, filter) async {
    try {
      final result = await _auctionService.list(
        segment: filter.segment,
        category: filter.category,
        search: filter.search,
        direction: filter.direction,
        status: filter.status,
      );
      if (result.auctions.isNotEmpty) return result.auctions;
    } catch (_) {}
    return _mockRepo.getAuctions(
      direction: filter.direction,
      category: filter.category,
      status: filter.status ?? filter.segment,
      search: filter.search,
    );
  },
);

final liveAuctionsProvider = FutureProvider<List<Auction>>((ref) async {
  try {
    final result = await _auctionService.list(segment: 'live');
    if (result.auctions.isNotEmpty) return result.auctions;
  } catch (_) {}
  return _mockRepo.getAuctions(status: 'live');
});

final upcomingAuctionsProvider = FutureProvider<List<Auction>>((ref) async {
  try {
    final result = await _auctionService.list(segment: 'upcoming');
    if (result.auctions.isNotEmpty) return result.auctions;
  } catch (_) {}
  return _mockRepo.getAuctions(status: 'upcoming');
});

final allAuctionsProvider = FutureProvider<List<Auction>>((ref) async {
  try {
    final result = await _auctionService.list();
    if (result.auctions.isNotEmpty) return result.auctions;
  } catch (_) {}
  return _mockRepo.getAuctions();
});

final auctionDetailProvider =
    FutureProvider.family<Auction, String>((ref, code) async {
  try {
    final auc = await _auctionService.show(code);
    return auc;
  } catch (_) {}
  final fallback = _mockRepo.getAuction(code);
  if (fallback != null) return fallback;
  throw Exception('Auction not found');
});

final selectedCategoryProvider = StateProvider<String?>((ref) => null);

final watchlistProvider =
    StateNotifierProvider<WatchlistNotifier, Set<String>>(
  (ref) => WatchlistNotifier(),
);

class WatchlistNotifier extends StateNotifier<Set<String>> {
  WatchlistNotifier() : super({'BP-FWD-2026-1048', 'BP-REV-2026-0872'});

  Future<void> load() async {
    try {
      final auctions = await _watchlistService.list();
      state = auctions.map((a) => a.code).toSet();
    } catch (_) {}
  }

  Future<void> toggle(String code) async {
    if (state.contains(code)) {
      try {
        await _watchlistService.remove(code);
      } catch (_) {}
      state = {...state}..remove(code);
    } else {
      try {
        await _watchlistService.add(code);
      } catch (_) {}
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

