import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/auth_result.dart';
import '../entities/login_params.dart';
import '../entities/register_params.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthResult>> login(LoginParams params);
  Future<Either<Failure, AuthResult>> register(RegisterParams params);
  Future<Either<Failure, Unit>> logout();
  Future<Either<Failure, User?>> getCurrentUser();
  Future<Either<Failure, bool>> isLoggedIn();
  Future<Either<Failure, AuthResult>> refreshToken();
}