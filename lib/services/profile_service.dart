import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../models/user.dart';

class ProfileService {
  final _api = ApiClient();

  Future<AppUser> update({
    String? name,
    String? email,
    String? phone,
  }) async {
    final data = await _api.patch(Endpoints.profile, data: {
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
    });
    return AppUser.fromJson(data['user'] as Map<String, dynamic>);
  }

  Future<List<Map<String, dynamic>>> addresses() async {
    final data = await _api.get(Endpoints.addresses);
    return (data['data'] as List?)?.cast<Map<String, dynamic>>() ?? [];
  }

  Future<Map<String, dynamic>> storeAddress(
      Map<String, dynamic> body) async {
    final data = await _api.post(Endpoints.addresses, data: body);
    return data['address'] as Map<String, dynamic>? ?? {};
  }

  Future<void> deleteAddress(int id) async {
    await _api.delete(Endpoints.address(id));
  }

  Future<List<Map<String, dynamic>>> paymentMethods() async {
    final data = await _api.get(Endpoints.paymentMethods);
    return (data['data'] as List?)?.cast<Map<String, dynamic>>() ?? [];
  }

  Future<void> storePaymentMethod(Map<String, dynamic> body) async {
    await _api.post(Endpoints.paymentMethods, data: body);
  }

  Future<void> deletePaymentMethod(int id) async {
    await _api.delete(Endpoints.paymentMethod(id));
  }
}
