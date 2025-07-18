import 'package:equatable/equatable.dart';
import 'exceptions.dart';

abstract class Failure extends Equatable {
  final String message;
  final String? code;
  
  const Failure(this.message, [this.code]);
  
  @override
  List<Object?> get props => [message, code];
}

class ServerFailure extends Failure {
  final int? statusCode;
  final Map<String, dynamic>? errors;
  
  const ServerFailure(
    String message, {
    this.statusCode,
    this.errors,
    String? code,
  }) : super(message, code);
  
  @override
  List<Object?> get props => [message, code, statusCode, errors];
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message, [super.code]);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message, [super.code]);
}

class ValidationFailure extends Failure {
  final Map<String, List<String>>? fieldErrors;
  
  const ValidationFailure(
    String message, {
    this.fieldErrors,
    String? code,
  }) : super(message, code);
  
  @override
  List<Object?> get props => [message, code, fieldErrors];
}

class AuthenticationFailure extends Failure {
  const AuthenticationFailure(super.message, [super.code]);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure(super.message, [super.code]);
}

// Utility methods for converting exceptions to failures
extension ExceptionToFailure on Exception {
  Failure toFailure() {
    if (this is ServerException) {
      final exception = this as ServerException;
      return ServerFailure(
        exception.message,
        statusCode: exception.statusCode,
        errors: exception.errors,
        code: exception.code,
      );
    } else if (this is NetworkException) {
      final exception = this as NetworkException;
      return NetworkFailure(exception.message, exception.code);
    } else if (this is CacheException) {
      final exception = this as CacheException;
      return CacheFailure(exception.message, exception.code);
    } else if (this is ValidationException) {
      final exception = this as ValidationException;
      return ValidationFailure(
        exception.message,
        fieldErrors: exception.fieldErrors,
        code: exception.code,
      );
    } else if (this is AuthenticationException) {
      final exception = this as AuthenticationException;
      return AuthenticationFailure(exception.message, exception.code);
    } else if (this is UnauthorizedException) {
      final exception = this as UnauthorizedException;
      return UnauthorizedFailure(exception.message, exception.code);
    } else {
      return ServerFailure('Error inesperado: $toString()');
    }
  }
}