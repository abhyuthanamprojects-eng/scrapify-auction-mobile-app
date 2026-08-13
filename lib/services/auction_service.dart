import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../models/auction.dart';
import '../models/bid.dart';
import '../models/lot.dart';

class AuctionService {
  final _api = ApiClient();

  Future<({List<Auction> auctions, int total})> list({
    String? status,
    String? category,
    String? segment,
    String? search,
    String? direction,
    int perPage = 25,
    int page = 1,
  }) async {
    final data = await _api.get(Endpoints.auctions, queryParameters: {
      if (status != null) 'status': status,
      if (category != null) 'category': category,
      if (segment != null) 'segment': segment,
      if (search != null) 'search': search,
      if (direction != null) 'direction': direction,
      'per_page': perPage,
      'page': page,
    });

    final list = (data['data'] as List?)
            ?.map((e) => Auction.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    final total = (data['meta'] as Map?)?['total'] as int? ?? list.length;
    return (auctions: list, total: total);
  }

  Future<Auction> show(String code) async {
    final data = await _api.get(Endpoints.auction(code));
    final inner = data['data'] as Map<String, dynamic>? ?? data;
    return Auction.fromJson(inner);
  }

  Future<Map<String, dynamic>> liveState(String code) async {
    return await _api.get(Endpoints.auctionLiveState(code));
  }

  Future<Auction> create(Map<String, dynamic> body) async {
    final data = await _api.post(Endpoints.auctions, data: body);
    final inner = data['data'] as Map<String, dynamic>? ?? data;
    return Auction.fromJson(inner);
  }

  Future<Auction> update(String code, Map<String, dynamic> body) async {
    final data = await _api.patch(Endpoints.auction(code), data: body);
    final inner = data['data'] as Map<String, dynamic>? ?? data;
    return Auction.fromJson(inner);
  }

  Future<void> submit(String code) async {
    await _api.post(Endpoints.auctionSubmit(code));
  }

  Future<({bool interested, int count})> markInterested(
    String code, {
    String? anonKey,
  }) async {
    final data = await _api.post(
      Endpoints.auctionInterested(code),
      data: anonKey != null ? {'anon_key': anonKey} : null,
      anonymous: true,
    );
    return (
      interested: data['interested'] as bool? ?? true,
      count: data['interested_count'] as int? ?? 0,
    );
  }

  Future<({bool interested, int count})> unmarkInterested(
    String code, {
    String? anonKey,
  }) async {
    final data = await _api.delete(
      Endpoints.auctionInterested(code),
      queryParameters: anonKey != null ? {'anon_key': anonKey} : null,
    );
    return (
      interested: data['interested'] as bool? ?? false,
      count: data['interested_count'] as int? ?? 0,
    );
  }

  // Lots
  Future<List<Lot>> lots(String code) async {
    final data = await _api.get(Endpoints.auctionLots(code));
    return (data['data'] as List?)
            ?.map((e) => Lot.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
  }

  Future<Lot> lotDetail(String code, String lotId) async {
    final data = await _api.get(Endpoints.auctionLot(code, lotId));
    final inner = data['data'] as Map<String, dynamic>? ?? data;
    return Lot.fromJson(inner);
  }

  Future<Lot> createLot(String code, Map<String, dynamic> body) async {
    final data = await _api.post(Endpoints.auctionLots(code), data: body);
    final inner = data['data'] as Map<String, dynamic>? ?? data;
    return Lot.fromJson(inner);
  }

  // Bids for an auction
  Future<List<Bid>> bids(String code, {String? lot, int perPage = 50}) async {
    final data = await _api.get(Endpoints.auctionBids(code), queryParameters: {
      if (lot != null) 'lot': lot,
      'per_page': perPage,
    });
    return (data['data'] as List?)
            ?.map((e) => Bid.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
  }
}
