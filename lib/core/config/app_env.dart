import 'package:flutter/foundation.dart';

enum Flavor { dev, staging, prod }

/// Build-time overrides, e.g.
/// ```
/// flutter run -t lib/main_staging.dart \
///   --dart-define=API_BASE_URL=https://<staging-host> \
///   --dart-define=REVERB_HOST=<staging-host> --dart-define=REVERB_KEY=<key>
/// ```
const _apiBaseUrlOverride = String.fromEnvironment('API_BASE_URL');
const _reverbHostOverride = String.fromEnvironment('REVERB_HOST');
const _reverbPortOverride = int.fromEnvironment('REVERB_PORT');
const _reverbKeyOverride = String.fromEnvironment('REVERB_KEY');
const _productionHost = 'api.scrapifyauctions.com';

String _str(String override, String fallback) => override.isNotEmpty ? override : fallback;
int _int(int override, int fallback) => override > 0 ? override : fallback;

class AppEnv {
  static AppEnv _instance = AppEnv._(
    flavor: Flavor.dev,
    apiBaseUrl: 'https://api.scrapifyauctions.com',
    reverbHost: 'api.scrapifyauctions.com',
    reverbPort: 443,
    reverbKey: 'scrapify-local-key',
    appTitle: 'Scrapify DEV',
    enableLogging: true,
  );

  final Flavor flavor;
  final String apiBaseUrl;
  final String reverbHost;
  final int reverbPort;
  final String reverbKey;
  final String appTitle;
  final bool enableLogging;

  AppEnv._({
    required this.flavor,
    required this.apiBaseUrl,
    required this.reverbHost,
    required this.reverbPort,
    required this.reverbKey,
    required this.appTitle,
    required this.enableLogging,
  });

  static AppEnv get instance => _instance;
  static Flavor get currentFlavor => _instance.flavor;
  static bool get isDev => _instance.flavor == Flavor.dev;
  static bool get isStaging => _instance.flavor == Flavor.staging;
  static bool get isProd => _instance.flavor == Flavor.prod;

  factory AppEnv.dev() {
    _instance = AppEnv._(
      flavor: Flavor.dev,
      apiBaseUrl: _str(_apiBaseUrlOverride, 'https://api.scrapifyauctions.com'),
      reverbHost: _str(_reverbHostOverride, 'api.scrapifyauctions.com'),
      reverbPort: _int(_reverbPortOverride, 443),
      reverbKey: _str(_reverbKeyOverride, 'scrapify-local-key'),
      appTitle: 'Scrapify DEV',
      enableLogging: true,
    );
    _warnIfNonProdHitsProduction();
    return _instance;
  }

  factory AppEnv.staging() {
    _instance = AppEnv._(
      flavor: Flavor.staging,
      apiBaseUrl: _str(_apiBaseUrlOverride, 'https://api.scrapifyauctions.com'),
      reverbHost: _str(_reverbHostOverride, 'api.scrapifyauctions.com'),
      reverbPort: _int(_reverbPortOverride, 443),
      reverbKey: _str(_reverbKeyOverride, 'scrapify-staging-key'),
      appTitle: 'Scrapify STG',
      enableLogging: true,
    );
    _warnIfNonProdHitsProduction();
    return _instance;
  }

  factory AppEnv.prod() {
    _instance = AppEnv._(
      flavor: Flavor.prod,
      apiBaseUrl: _str(_apiBaseUrlOverride, 'https://api.scrapifyauctions.com'),
      reverbHost: _str(_reverbHostOverride, 'api.scrapifyauctions.com'),
      reverbPort: _int(_reverbPortOverride, 443),
      reverbKey: _str(_reverbKeyOverride, 'scrapify-prod-key'),
      appTitle: 'Scrapify Auction',
      enableLogging: false,
    );
    return _instance;
  }

  /// Non-prod builds that talk to production send real SMS/email and touch
  /// live data. Make that impossible to miss during development.
  static void _warnIfNonProdHitsProduction() {
    if (_instance.flavor == Flavor.prod) return;
    if (Uri.tryParse(_instance.apiBaseUrl)?.host != _productionHost) return;
    debugPrint(
      '⚠️  ${_instance.flavor.name.toUpperCase()} build is using the PRODUCTION API '
      '($_productionHost). Pass --dart-define=API_BASE_URL=<non-prod url> to change it.',
    );
  }
}
