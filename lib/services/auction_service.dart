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

  // Pre-Auction Inspections & Gate Passes
  Future<Map<String, dynamic>> getInspections(String code) async {
    return await _api.get(Endpoints.auctionInspections(code));
  }

  Future<Map<String, dynamic>> bookInspection(String code, Map<String, dynamic> body) async {
    return await _api.post(Endpoints.auctionInspections(code), data: body);
  }

  Future<Map<String, dynamic>> verifyGatePass(String qrToken) async {
    return await _api.get(Endpoints.verifyGatePass(qrToken), anonymous: true);
  }

  Future<Map<String, dynamic>> scanGatePass(String qrToken) async {
    return await _api.post(Endpoints.scanGatePass(qrToken));
  }

  // RFx & Technical Qualification
  Future<Map<String, dynamic>> getRfx(String code) async {
    return await _api.get(Endpoints.auctionRfx(code));
  }

  Future<Map<String, dynamic>> submitRfx(String code, int packageId, Map<String, dynamic> answers) async {
    return await _api.post(Endpoints.submitRfx(code, packageId), data: {'answers': answers});
  }

  // Clarifications & Addenda
  Future<Map<String, dynamic>> getClarifications(String code) async {
    return await _api.get(Endpoints.auctionClarifications(code));
  }

  Future<Map<String, dynamic>> askClarification(String code, String question, {String? section, bool isPublic = true}) async {
    return await _api.post(Endpoints.auctionClarifications(code), data: {
      'question': question,
      'section': section ?? 'Commercial Terms',
      'is_public': isPublic,
    });
  }

  Future<Map<String, dynamic>> acknowledgeAddendum(String code, int addendumId) async {
    return await _api.post(Endpoints.acknowledgeAddendum(code, addendumId));
  }

  // Awards & Fallback
  Future<Map<String, dynamic>> getAwards(String code) async {
    return await _api.get(Endpoints.auctionAwards(code));
  }

  Future<Map<String, dynamic>> acceptAward(int awardId) async {
    return await _api.post(Endpoints.acceptAward(awardId));
  }

  Future<Map<String, dynamic>> declineAward(int awardId, String reason) async {
    return await _api.post(Endpoints.acceptAward(awardId), data: {'status': 'declined', 'reason': reason});
  }

  // Disputes & Arbitration
  Future<Map<String, dynamic>> raiseDispute(Map<String, dynamic> body) async {
    return await _api.post(Endpoints.disputes, data: body);
  }

  Future<Map<String, dynamic>> addDisputeMessage(String code, String message) async {
    return await _api.post(Endpoints.disputeMessage(code), data: {'message': message});
  }

  Future<Map<String, dynamic>> uploadDisputeEvidence(String code, Map<String, dynamic> body) async {
    return await _api.post(Endpoints.disputeEvidence(code), data: body);
  }

  // Team Members
  Future<List<Map<String, dynamic>>> getTeamMembers() async {
    final data = await _api.get(Endpoints.teamMembers);
    return List<Map<String, dynamic>>.from(data['data'] as List? ?? []);
  }

  Future<Map<String, dynamic>> addTeamMember(Map<String, dynamic> body) async {
    return await _api.post(Endpoints.teamMembers, data: body);
  }

  Future<Map<String, dynamic>> updateTeamMember(int id, Map<String, dynamic> body) async {
    return await _api.patch(Endpoints.teamMember(id), data: body);
  }

  // Auction Terms
  Future<void> acceptAuctionTerms(String code) async {
    await _api.post(Endpoints.acceptTerms(code));
  }
}
