import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'api_config.dart';
import 'api_exception.dart';
import 'token_storage.dart';

typedef LogoutCallback = void Function();

class ApiClient {
  late final Dio _dio;
  LogoutCallback? _onForceLogout;

  static final ApiClient _instance = ApiClient._();
  factory ApiClient() => _instance;

  ApiClient._() {
    _dio = Dio(BaseOptions(
      baseUrl: '${ApiConfig.baseUrl}${ApiConfig.apiPrefix}',
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: _onRequest,
      onError: _onError,
    ));

    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (o) => debugPrint('[API] $o'),
      ));
    }
  }

  void setLogoutCallback(LogoutCallback cb) => _onForceLogout = cb;

  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await TokenStorage.read();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  Future<void> _onError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    if (error.response?.statusCode == 401) {
      await TokenStorage.clear();
      _onForceLogout?.call();
    }
    handler.next(error);
  }

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool anonymous = false,
  }) =>
      _request(() => _dio.get(
            path,
            queryParameters: queryParameters,
            options: anonymous ? Options(headers: {'Authorization': null}) : null,
          ));

  Future<Map<String, dynamic>> post(
    String path, {
    dynamic data,
    bool anonymous = false,
  }) =>
      _request(() => _dio.post(
            path,
            data: data,
            options: anonymous ? Options(headers: {'Authorization': null}) : null,
          ));

  Future<Map<String, dynamic>> patch(
    String path, {
    dynamic data,
  }) =>
      _request(() => _dio.patch(path, data: data));

  Future<Map<String, dynamic>> put(
    String path, {
    dynamic data,
  }) =>
      _request(() => _dio.put(path, data: data));

  Future<Map<String, dynamic>> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) =>
      _request(() => _dio.delete(path, queryParameters: queryParameters));

  Future<Map<String, dynamic>> uploadFile(
    String path, {
    required FormData data,
  }) =>
      _request(() => _dio.post(
            path,
            data: data,
            options: Options(contentType: Headers.multipartFormDataContentType),
          ));

  Future<Map<String, dynamic>> _request(
    Future<Response> Function() call,
  ) async {
    try {
      final response = await call();
      if (response.statusCode == 204) return {};
      return response.data as Map<String, dynamic>? ?? {};
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw ApiException.timeout();
      }
      if (e.type == DioExceptionType.connectionError) {
        throw ApiException.network();
      }
      final status = e.response?.statusCode ?? 0;
      final body = e.response?.data;
      if (body is Map<String, dynamic>) {
        throw ApiException.fromDioResponse(body, status);
      }
      throw ApiException(statusCode: status, message: e.message ?? 'Request failed');
    }
  }
}
