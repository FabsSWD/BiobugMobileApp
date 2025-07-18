import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/auth_result.dart';
import '../entities/register_params.dart';
import '../repositories/auth_repository.dart';

@LazySingleton()
class RegisterUser implements UseCase<AuthResult, RegisterParams> {
  final AuthRepository repository;

  RegisterUser(this.repository);

  @override
  Future<Either<Failure, AuthResult>> call(RegisterParams params) async {
    return await repository.register(params);
  }
}