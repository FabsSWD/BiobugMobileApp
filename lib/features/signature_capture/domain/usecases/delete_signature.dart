import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/signature_repository.dart';

class DeleteSignatureParams {
  final String id;
  
  DeleteSignatureParams({required this.id});
}

@LazySingleton()
class DeleteSignature implements UseCase<Unit, DeleteSignatureParams> {
  final SignatureRepository repository;

  DeleteSignature(this.repository);

  @override
  Future<Either<Failure, Unit>> call(DeleteSignatureParams params) async {
    return await repository.deleteSignature(params.id);
  }
}