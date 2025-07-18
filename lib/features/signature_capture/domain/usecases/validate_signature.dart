import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/signature.dart';
import '../repositories/signature_repository.dart';

@LazySingleton()
class ValidateSignature implements UseCase<bool, Signature> {
  final SignatureRepository repository;

  ValidateSignature(this.repository);

  @override
  Future<Either<Failure, bool>> call(Signature params) async {
    return await repository.validateSignature(params);
  }
}