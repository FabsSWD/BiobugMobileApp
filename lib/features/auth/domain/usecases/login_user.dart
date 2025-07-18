import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/auth_result.dart';
import '../entities/login_params.dart';
import '../repositories/auth_repository.dart';

@LazySingleton()
class LoginUser implements UseCase<AuthResult, LoginParams> {
  final AuthRepository repository;

  LoginUser(this.repository);

  @override
  Future<Either<Failure, AuthResult>> call(LoginParams params) async {
    return await repository.login(params);
  }
}