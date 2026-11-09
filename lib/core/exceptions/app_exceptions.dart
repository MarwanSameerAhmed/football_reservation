/// Low-level exceptions thrown by Data Sources.
class AppException implements Exception {
  final String message;
  final String? code;

  const AppException(this.message, [this.code]);

  @override
  String toString() => 'AppException: $message (code: $code)';
}

class ServerException extends AppException {
  const ServerException([super.message = 'Server error occurred', super.code]);
}

class NetworkException extends AppException {
  const NetworkException([
    super.message = 'Network connection failed',
    super.code,
  ]);
}

class AuthException extends AppException {
  const AuthException([super.message = 'Authentication failed', super.code]);
}

class NotFoundException extends AppException {
  const NotFoundException([super.message = 'Resource not found', super.code]);
}

class ValidationException extends AppException {
  const ValidationException([super.message = 'Validation error', super.code]);
}
