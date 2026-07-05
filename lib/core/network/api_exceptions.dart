class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? errorType;

  const ApiException({
    required this.message,
    this.statusCode,
    this.errorType,
  });

  @override
  String toString() => 'ApiException(statusCode: $statusCode, errorType: $errorType, message: $message)';
}

class NetworkException extends ApiException {
  const NetworkException({super.message = 'No Internet connection or server timeout.'})
      : super(errorType: 'NETWORK_ERROR');
}

class ServerException extends ApiException {
  const ServerException({required super.message, super.statusCode})
      : super(errorType: 'SERVER_ERROR');
}

class UnauthorizedException extends ApiException {
  const UnauthorizedException({super.message = 'Unauthorized request.'})
      : super(statusCode: 401, errorType: 'UNAUTHORIZED');
}

class NotFoundException extends ApiException {
  const NotFoundException({super.message = 'Resource not found.'})
      : super(statusCode: 404, errorType: 'NOT_FOUND');
}

class UnknownException extends ApiException {
  const UnknownException({super.message = 'An unexpected error occurred.'})
      : super(errorType: 'UNKNOWN_ERROR');
}
