enum Flavor { dev, staging, prod }

class AppEnv {
  static late final AppEnv _instance;

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
      apiBaseUrl: 'http://localhost:8000',
      reverbHost: 'localhost',
      reverbPort: 8090,
      reverbKey: 'scrapify-local-key',
      appTitle: 'Scrapify DEV',
      enableLogging: true,
    );
    return _instance;
  }

  factory AppEnv.staging() {
    _instance = AppEnv._(
      flavor: Flavor.staging,
      apiBaseUrl: 'https://staging-api.scrapify.in',
      reverbHost: 'staging-ws.scrapify.in',
      reverbPort: 443,
      reverbKey: 'scrapify-staging-key',
      appTitle: 'Scrapify STG',
      enableLogging: true,
    );
    return _instance;
  }

  factory AppEnv.prod() {
    _instance = AppEnv._(
      flavor: Flavor.prod,
      apiBaseUrl: 'https://api.scrapify.in',
      reverbHost: 'ws.scrapify.in',
      reverbPort: 443,
      reverbKey: 'scrapify-prod-key',
      appTitle: 'Scrapify Auction',
      enableLogging: false,
    );
    return _instance;
  }
}
