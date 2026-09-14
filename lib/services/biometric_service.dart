import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/network/token_storage.dart';

class BiometricService {
  static final _auth = LocalAuthentication();
  static const _prefKey = 'scrapify_biometric_enabled';
  static final _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static Future<bool> get isAvailable async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isSupported = await _auth.isDeviceSupported();
      return canCheck && isSupported;
    } on PlatformException {
      return false;
    }
  }

  static Future<bool> authenticate() async {
    try {
      return await _auth.authenticate(
        localizedReason: 'Sign in to Scrapify Auctions',
      );
    } on PlatformException {
      return false;
    }
  }

  static Future<bool> get hasSavedSession async {
    final token = await TokenStorage.read();
    return token != null;
  }

  static Future<bool> get isEnabled async {
    final value = await _storage.read(key: _prefKey);
    return value == 'true';
  }

  static Future<void> setEnabled(bool enabled) async {
    await _storage.write(key: _prefKey, value: enabled ? 'true' : 'false');
  }

  static Future<void> clear() async {
    await _storage.delete(key: _prefKey);
  }

  static Future<bool> get shouldShowLockScreen async {
    final enabled = await isEnabled;
    if (!enabled) return false;
    final hasSession = await hasSavedSession;
    if (!hasSession) return false;
    final available = await isAvailable;
    return available;
  }
}
