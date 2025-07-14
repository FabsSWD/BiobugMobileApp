abstract class AppException implements Exception {
  final String message;
  final String? code;
  
  const AppException(this.message, [this.code]);
  
  @override
  String toString() => 'AppException: $message${code != null ? ' (Code: $code)' : ''}';
}

class ServerException extends AppException {
  final int? statusCode;
  final Map<String, dynamic>? errors;
  
  const ServerException(
    String message, {
    this.statusCode,
    this.errors,
    String? code,
  }) : super(message, code);
  
  @override
  String toString() => 'ServerException: $message (Status: $statusCode)';
}

class NetworkException extends AppException {
  const NetworkException(super.message, [super.code]);
}

class CacheException extends AppException {
  const CacheException(super.message, [super.code]);
}

class ValidationException extends AppException {
  final Map<String, List<String>>? fieldErrors;
  
  const ValidationException(
    String message, {
    this.fieldErrors,
    String? code,
  }) : super(message, code);
}

class AuthenticationException extends AppException {
  const AuthenticationException(super.message, [super.code]);
}

class UnauthorizedException extends AppException {
  const UnauthorizedException(super.message, [super.code]);
}