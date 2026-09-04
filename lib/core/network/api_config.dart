import '../config/app_env.dart';

abstract final class ApiConfig {
  static String get baseUrl => AppEnv.instance.apiBaseUrl;

  static const apiPrefix = '/api/v1';

  static String get reverbHost => AppEnv.instance.reverbHost;
  static int get reverbPort => AppEnv.instance.reverbPort;
  static String get reverbKey => AppEnv.instance.reverbKey;

  static const connectTimeout = Duration(seconds: 60);
  static const receiveTimeout = Duration(seconds: 60);
}
