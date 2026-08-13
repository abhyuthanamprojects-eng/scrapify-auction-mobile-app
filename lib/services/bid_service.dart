import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../models/bid.dart';
import '../models/my_bid.dart';

class BidService {
  final _api = ApiClient();

  Future<({Bid bid, double currentHighest, int bidders})> placeBid({
    required String auctionCode,
    required double amount,
    String? lot,
  }) async {
    final data = await _api.post(Endpoints.placeBid(auctionCode), data: {
      'amount': amount,
      if (lot != null) 'lot': lot,
    });

    final bid = Bid.fromJson(data['bid'] as Map<String, dynamic>);
    final auction = data['auction'] as Map<String, dynamic>? ?? {};
    return (
      bid: bid,
      currentHighest: (auction['current_highest_inr'] as num?)?.toDouble() ?? 0,
      bidders: auction['bidders'] as int? ?? 0,
    );
  }

  Future<void> setProxyBid({
    required String auctionCode,
    required double maxAmount,
    String? lot,
  }) async {
    await _api.post(Endpoints.proxyBid(auctionCode), data: {
      'max_amount': maxAmount,
      if (lot != null) 'lot': lot,
    });
  }

  Future<void> cancelProxyBid(String auctionCode, {String? lot}) async {
    await _api.delete(
      Endpoints.proxyBid(auctionCode),
      queryParameters: lot != null ? {'lot': lot} : null,
    );
  }

  Future<({List<MyBid> active, List<MyBid> won, List<MyBid> lost})>
      myBids() async {
    final data = await _api.get(Endpoints.myBids);

    List<MyBid> parse(String key) => (data[key] as List?)
            ?.map((e) => MyBid.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return (
      active: parse('active'),
      won: parse('won'),
      lost: parse('lost'),
    );
  }
}
