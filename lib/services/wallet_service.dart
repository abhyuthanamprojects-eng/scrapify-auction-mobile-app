import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../models/wallet.dart';
import '../models/transaction.dart';

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

  Future<({Transaction transaction, double balance})> topUp({
    required double amount,
    required String method,
    String? note,
  }) async {
    final data = await _api.post(Endpoints.walletTopUp, data: {
      'amount': amount,
      'method': method,
      'note': ?note,
    });

    final txn = Transaction.fromJson(
        data['transaction'] as Map<String, dynamic>? ?? {});
    final balance = (data['balance_inr'] as num?)?.toDouble() ?? 0;
    return (transaction: txn, balance: balance);
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

  Future<Map<String, dynamic>> createRazorpayOrder({
    required double amount,
    required String purpose,
    String? orderCode,
  }) async {
    final data = await _api.post(Endpoints.razorpayCreateOrder, data: {
      'amount': amount,
      'purpose': purpose,
      'order_code': ?orderCode,
    });
    return (data['data'] as Map<String, dynamic>?) ?? data;
  }

  Future<Map<String, dynamic>> verifyRazorpayPayment({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
    required String purpose,
    String? orderCode,
  }) async {
    final data = await _api.post(Endpoints.razorpayVerify, data: {
      'razorpay_order_id': razorpayOrderId,
      'razorpay_payment_id': razorpayPaymentId,
      'razorpay_signature': razorpaySignature,
      'purpose': purpose,
      'order_code': ?orderCode,
    });
    return (data['data'] as Map<String, dynamic>?) ?? data;
  }
}
