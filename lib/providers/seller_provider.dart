import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/auction.dart';
import '../services/auction_service.dart';

final _auctionService = AuctionService();

final sellerAuctionsProvider = FutureProvider<List<Auction>>((ref) async {
  final result = await _auctionService.list();
  return result.auctions;
});

final sellerFilterProvider = StateProvider<AuctionStatus?>((ref) => null);

final filteredSellerAuctionsProvider =
    FutureProvider<List<Auction>>((ref) async {
  final auctions = await ref.watch(sellerAuctionsProvider.future);
  final filter = ref.watch(sellerFilterProvider);
  if (filter == null) return auctions;
  return auctions.where((a) => a.status == filter).toList();
});
