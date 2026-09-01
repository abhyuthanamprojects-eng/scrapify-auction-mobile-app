import 'dart:convert';
import 'dart:io';
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
      onResponse: _onResponse,
    ));
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

    if (kDebugMode) {
      _logRequest(options);
    }

    handler.next(options);
  }

  void _logRequest(RequestOptions options) {
    final headers = Map<String, dynamic>.from(options.headers);
    // Mask the authorization token for security
    if (headers.containsKey('Authorization')) {
      final authHeader = headers['Authorization'] as String;
      if (authHeader.startsWith('Bearer ')) {
        final token = authHeader.substring(7);
        final maskedToken = token.length > 4 ? '***${token.substring(token.length - 4)}' : '***';
        headers['Authorization'] = 'Bearer $maskedToken';
      }
    }

    final logData = {
      'timestamp': DateTime.now().toIso8601String(),
      'method': options.method,
      'url': '${options.baseUrl}${options.path}',
      'headers': headers,
      if (options.queryParameters.isNotEmpty) 'queryParams': options.queryParameters,
      if (options.data != null) 'body': options.data,
    };

    debugPrint('[API_REQUEST] ${jsonEncode(logData)}');
  }

  Future<void> _onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) async {
    if (kDebugMode) {
      _logResponse(response);
    }
    handler.next(response);
  }

  void _logResponse(Response response) {
    final logData = {
      'timestamp': DateTime.now().toIso8601String(),
      'statusCode': response.statusCode,
      'url': response.requestOptions.path,
      'body': response.data,
    };

    debugPrint('[API_RESPONSE] ${jsonEncode(logData)}');
  }

  Future<void> _onError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    if (kDebugMode) {
      _logError(error);
    }

    if (error.response?.statusCode == 401) {
      await TokenStorage.clear();
      _onForceLogout?.call();
    }
    handler.next(error);
  }

  void _logError(DioException error) {
    final logData = {
      'timestamp': DateTime.now().toIso8601String(),
      'type': error.type.toString(),
      'statusCode': error.response?.statusCode,
      'url': error.requestOptions.path,
      'message': error.message,
      if (error.response?.data != null) 'responseBody': error.response?.data,
    };

    debugPrint('[API_ERROR] ${jsonEncode(logData)}');
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
      // Handle different timeout types
      if (e.type == DioExceptionType.connectionTimeout) {
        throw ApiException.timeout();
      }
      if (e.type == DioExceptionType.sendTimeout) {
        throw ApiException.timeout();
      }
      if (e.type == DioExceptionType.receiveTimeout) {
        throw ApiException.timeout();
      }

      // Handle connection errors
      if (e.type == DioExceptionType.connectionError) {
        // Check if it's a connection refused vs general network error
        if (e.error is SocketException) {
          throw ApiException.connectionRefused();
        }
        throw ApiException.network();
      }

      // Handle response errors
      final status = e.response?.statusCode ?? 0;
      final body = e.response?.data;

      if (body is Map<String, dynamic>) {
        throw ApiException.fromDioResponse(body, status);
      }

      // If we get an unexpected response format, create exception with status
      throw ApiException(
        statusCode: status,
        message: e.message ?? 'Request failed',
      );
    } catch (e) {
      // Catch any other exception and wrap it
      throw ApiException(
        statusCode: 0,
        message: 'An unexpected error occurred: ${e.toString()}',
      );
    }
  }
}
