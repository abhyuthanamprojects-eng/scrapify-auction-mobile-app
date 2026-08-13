import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _tokenKey = 'scrapify_auth_token';
  static final _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static String? _cachedToken;

  static Future<void> save(String token) async {
    _cachedToken = token;
    await _storage.write(key: _tokenKey, value: token);
  }

  static Future<String?> read() async {
    _cachedToken ??= await _storage.read(key: _tokenKey);
    return _cachedToken;
  }

  static Future<void> clear() async {
    _cachedToken = null;
    await _storage.delete(key: _tokenKey);
  }

  static bool get hasCachedToken => _cachedToken != null;
}
