import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../models/order.dart';

class OrderService {
  final _api = ApiClient();

  Future<List<Order>> list({String? status}) async {
    final data = await _api.get(Endpoints.orders, queryParameters: {
      if (status != null) 'status': status,
    });
    return (data['data'] as List?)
            ?.map((e) => Order.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
  }

  Future<Order> show(String code) async {
    final data = await _api.get(Endpoints.order(code));
    return Order.fromJson(data['order'] as Map<String, dynamic>? ?? data);
  }

  Future<Order> pay(String code, {
    required String method,
    String? reference,
  }) async {
    final data = await _api.post(Endpoints.orderPay(code), data: {
      'method': method,
      if (reference != null) 'reference': reference,
    });
    return Order.fromJson(data['order'] as Map<String, dynamic>? ?? {});
  }

  Future<void> schedulePickup(String code, {
    required String windowStart,
    required String windowEnd,
    String? warehouse,
    String? note,
  }) async {
    await _api.post(Endpoints.orderPickup(code), data: {
      'window_start': windowStart,
      'window_end': windowEnd,
      if (warehouse != null) 'warehouse': warehouse,
      if (note != null) 'note': note,
    });
  }
}
