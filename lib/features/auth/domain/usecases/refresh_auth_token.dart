import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/auth_result.dart';
import '../repositories/auth_repository.dart';

@LazySingleton()
class RefreshAuthToken implements UseCase<AuthResult, NoParams> {
  final AuthRepository repository;

  RefreshAuthToken(this.repository);

  @override
  Future<Either<Failure, AuthResult>> call(NoParams params) async {
    return await repository.refreshToken();
  }
}