class ApiException implements Exception {
  final int statusCode;
  final String message;
  final Map<String, List<String>> fieldErrors;
  final String? errorType; // For distinguishing between timeout, network, etc.

  const ApiException({
    required this.statusCode,
    required this.message,
    this.fieldErrors = const {},
    this.errorType,
  });

  String? firstFieldError(String field) {
    final errors = fieldErrors[field];
    return errors != null && errors.isNotEmpty ? errors.first : null;
  }

  String get firstError {
    if (fieldErrors.isNotEmpty) {
      return fieldErrors.values.first.first;
    }
    return message;
  }

  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isValidation => statusCode == 422;
  bool get isNotFound => statusCode == 404;
  bool get isRateLimited => statusCode == 429;
  bool get isServer => statusCode >= 500;
  bool get isNetwork => errorType == 'network' && statusCode == 0;
  bool get isTimeout => errorType == 'timeout' && statusCode == 0;
  bool get hasFieldErrors => fieldErrors.isNotEmpty;

  @override
  String toString() => 'ApiException($statusCode): $message';

  String get userMessage {
    if (isNetwork) return 'No internet connection. Please check your network.';
    if (isTimeout || statusCode == 522 || statusCode == 524 || statusCode == 504) {
      return 'Server is taking too long to respond (Connection timed out). Please try again in a few moments.';
    }
    if (statusCode == 502 || statusCode == 503) {
      return 'Server is temporarily unavailable. Please try again shortly.';
    }
    if (isUnauthorized) return 'Your session has expired. Please log in again.';
    if (isForbidden) return 'You do not have permission to perform this action.';
    if (isNotFound) return 'The requested resource was not found.';
    if (isRateLimited) return 'Too many requests. Please wait before trying again.';
    if (isServer) return 'Something went wrong on our end. Please try again later.';
    if (isValidation) return message;
    return message;
  }

  factory ApiException.fromDioResponse(Map<String, dynamic>? data, int status) {
    final message = data?['message'] as String? ??
        data?['detail'] as String? ??
        data?['title'] as String? ??
        'Something went wrong';
    final rawErrors = data?['errors'] as Map<String, dynamic>? ?? {};
    final fieldErrors = rawErrors.map(
      (key, value) => MapEntry(key, (value as List).cast<String>()),
    );
    return ApiException(
      statusCode: status,
      message: message,
      fieldErrors: fieldErrors,
      errorType: (status == 522 || status == 524 || status == 504) ? 'timeout' : null,
    );
  }

  factory ApiException.network() => const ApiException(
        statusCode: 0,
        message: 'No internet connection. Please check your network.',
        errorType: 'network',
      );

  factory ApiException.timeout() => const ApiException(
        statusCode: 0,
        message: 'Request timed out. Please try again.',
        errorType: 'timeout',
      );

  factory ApiException.connectionRefused() => const ApiException(
        statusCode: 0,
        message: 'Could not connect to the server. Please check your internet connection.',
        errorType: 'connection_refused',
      );
}
