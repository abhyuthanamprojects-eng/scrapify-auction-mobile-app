import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../core/network/token_storage.dart';
import '../models/user.dart';

class AuthService {
  final _api = ApiClient();

  Future<({AppUser user, String token})> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    String role = 'buyer',
    String? companyName,
  }) async {
    final data = await _api.post(Endpoints.register, data: {
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
      'role': role,
      if (companyName != null) 'company_name': companyName,
    }, anonymous: true);

    final user = AppUser.fromJson(data['user'] as Map<String, dynamic>);
    final token = data['token'] as String;
    await TokenStorage.save(token);
    return (user: user, token: token);
  }

  Future<({AppUser user, String token})> login({
    required String identifier,
    required String password,
  }) async {
    final data = await _api.post(Endpoints.login, data: {
      'identifier': identifier,
      'password': password,
    }, anonymous: true);

    final user = AppUser.fromJson(data['user'] as Map<String, dynamic>);
    final token = data['token'] as String;
    await TokenStorage.save(token);
    return (user: user, token: token);
  }

  Future<({String? debugCode, String expiresAt})> requestOtp({
    required String identifier,
    String purpose = 'login',
  }) async {
    final data = await _api.post(Endpoints.requestOtp, data: {
      'identifier': identifier,
      'purpose': purpose,
    }, anonymous: true);

    return (
      debugCode: data['debug_code'] as String?,
      expiresAt: data['expires_at'] as String? ?? '',
    );
  }

  Future<({AppUser? user, String? token, bool verified})> verifyOtp({
    required String identifier,
    required String code,
  }) async {
    final data = await _api.post(Endpoints.verifyOtp, data: {
      'identifier': identifier,
      'code': code,
    }, anonymous: true);

    final verified = data['verified'] as bool? ?? false;
    AppUser? user;
    String? token;
    if (data['user'] != null) {
      user = AppUser.fromJson(data['user'] as Map<String, dynamic>);
      token = data['token'] as String?;
      if (token != null) await TokenStorage.save(token);
    }
    return (user: user, token: token, verified: verified);
  }

  Future<AppUser> me() async {
    final data = await _api.get(Endpoints.me);
    return AppUser.fromJson(data['user'] as Map<String, dynamic>);
  }

  Future<void> logout() async {
    try {
      await _api.post(Endpoints.logout);
    } finally {
      await TokenStorage.clear();
    }
  }
}
