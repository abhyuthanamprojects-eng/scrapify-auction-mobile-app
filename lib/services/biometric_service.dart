import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import '../core/network/token_storage.dart';

class BiometricService {
  static final _auth = LocalAuthentication();

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
}
