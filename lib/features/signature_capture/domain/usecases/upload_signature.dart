import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/signature.dart';
import '../repositories/signature_repository.dart';

@LazySingleton()
class UploadSignature implements UseCase<Unit, Signature> {
  final SignatureRepository repository;

  UploadSignature(this.repository);

  @override
  Future<Either<Failure, Unit>> call(Signature params) async {
    return await repository.uploadSignature(params);
  }
}