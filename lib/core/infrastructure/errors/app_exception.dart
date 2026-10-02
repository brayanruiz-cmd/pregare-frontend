sealed class AppException implements Exception {
  const AppException(this.message, [this.stackTrace]);

  final String message;
  final StackTrace? stackTrace;

  @override
  String toString() => '$runtimeType: $message';
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'No internet connection']);
}

class ServerException extends AppException {
  final int? statusCode;
  const ServerException([super.message = 'Server error', this.statusCode]);
}

class AuthException extends AppException {
  const AuthException([super.message = 'Authentication failed']);
}

class CacheException extends AppException {
  const CacheException([super.message = 'Cache operation failed']);
}

class BadRequestException extends AppException {
  const BadRequestException([super.message = 'Bad request']);
}

class NotFoundException extends AppException {
  const NotFoundException([super.message = 'Resource not found']);
}

class UnauthorizedException extends AppException {
  const UnauthorizedException([super.message = 'Unauthorized']);
}
