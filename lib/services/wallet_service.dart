import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../models/wallet.dart';
import '../models/transaction.dart';
import 'package:dio/dio.dart';

class WalletService {
  final _api = ApiClient();

  Future<WalletBalance> balance() async {
    final data = await _api.get(Endpoints.wallet);
    return WalletBalance.fromJson(data);
  }

  Future<({List<Transaction> transactions, int total})> transactions({
    String? type,
    int perPage = 30,
    int page = 1,
  }) async {
    final data =
        await _api.get(Endpoints.walletTransactions, queryParameters: {
      'type': ?type,
      'per_page': perPage,
      'page': page,
    });

    final list = (data['data'] as List?)
            ?.map((e) => Transaction.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    final total = (data['meta'] as Map?)?['total'] as int? ?? list.length;
    return (transactions: list, total: total);
  }

  Future<List<Map<String, dynamic>>> emdList({
    String? status,
    String? auction,
  }) async {
    final data = await _api.get(Endpoints.emd, queryParameters: {
      'status': ?status,
      'auction': ?auction,
    });
    return (data['data'] as List?)?.cast<Map<String, dynamic>>() ?? [];
  }

  Future<Map<String, dynamic>> lockEmd({
    required String auctionId,
    String? lot,
  }) async {
    return await _api.post(Endpoints.emdLock, data: {
      'auction_id': auctionId,
      'lot': ?lot,
    });
  }

  Future<void> releaseEmd(int id, {String? reason}) async {
    await _api.post(Endpoints.emdRelease(id), data: {
      'reason': ?reason,
    });
  }

  Future<Map<String, dynamic>> submitManualPayment({
    required double amount,
    required String proofPath,
    String? transactionId,
    String purpose = 'wallet_topup',
    String? targetCode,
  }) async {
    final form = FormData.fromMap({
      'purpose': purpose,
      'amount': amount,
      'proof': await MultipartFile.fromFile(proofPath),
      if (transactionId != null && transactionId.trim().isNotEmpty) 'transaction_id': transactionId.trim(),
      if (targetCode != null && targetCode.trim().isNotEmpty) 'target_code': targetCode.trim(),
    });
    return _api.uploadFile(Endpoints.manualPayment, data: form);
  }
}
