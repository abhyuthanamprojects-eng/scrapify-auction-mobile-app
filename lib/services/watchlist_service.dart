import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../models/auction.dart';

class WatchlistService {
  final _api = ApiClient();

  Future<List<Auction>> list() async {
    final data = await _api.get(Endpoints.watchlist);
    return (data['data'] as List?)
            ?.map((e) => Auction.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
  }

  Future<void> add(String auctionCode, {String? lot}) async {
    await _api.post(Endpoints.watchlist, data: {
      'auction_id': auctionCode,
      if (lot != null) 'lot': lot,
    });
  }

  Future<void> remove(String auctionCode) async {
    await _api.delete(Endpoints.watchlistRemove(auctionCode));
  }
}
