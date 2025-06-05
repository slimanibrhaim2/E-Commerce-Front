class ApiException implements Exception {
  final String message;
  final String? code;
  final bool isConnectionError;

  ApiException({
    required this.message,
    this.code,
    this.isConnectionError = false,
  });

  @override
  String toString() => message;

  factory ApiException.connectionError() {
    return ApiException(
      message: 'لا يمكن الاتصال بالخادم. يرجى التحقق من اتصال الإنترنت الخاص بك والمحاولة مرة أخرى.',
      isConnectionError: true,
    );
  }

  factory ApiException.timeout() {
    return ApiException(
      message: 'انتهت مهلة الاتصال. يرجى التحقق من اتصال الإنترنت الخاص بك والمحاولة مرة أخرى.',
      isConnectionError: true,
    );
  }

  factory ApiException.serverError(String message, [String? code]) {
    return ApiException(
      message: message,
      code: code,
      isConnectionError: false,
    );
  }
} 