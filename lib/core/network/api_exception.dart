class ApiException implements Exception {
  final int statusCode;
  final String message;
  final Map<String, List<String>> fieldErrors;

  const ApiException({
    required this.statusCode,
    required this.message,
    this.fieldErrors = const {},
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
  bool get isValidation => statusCode == 422;
  bool get isNotFound => statusCode == 404;
  bool get isServer => statusCode >= 500;

  @override
  String toString() => 'ApiException($statusCode): $message';

  factory ApiException.fromDioResponse(Map<String, dynamic>? data, int status) {
    final message = data?['message'] as String? ?? 'Something went wrong';
    final rawErrors = data?['errors'] as Map<String, dynamic>? ?? {};
    final fieldErrors = rawErrors.map(
      (key, value) => MapEntry(key, (value as List).cast<String>()),
    );
    return ApiException(
      statusCode: status,
      message: message,
      fieldErrors: fieldErrors,
    );
  }

  factory ApiException.network() => const ApiException(
        statusCode: 0,
        message: 'Cannot reach the server. Check your internet connection.',
      );

  factory ApiException.timeout() => const ApiException(
        statusCode: 0,
        message: 'Request timed out. Please try again.',
      );
}
