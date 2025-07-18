import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/signature.dart';
import '../repositories/signature_repository.dart';

@LazySingleton()
class GetSavedSignatures implements UseCase<List<Signature>, NoParams> {
  final SignatureRepository repository;

  GetSavedSignatures(this.repository);

  @override
  Future<Either<Failure, List<Signature>>> call(NoParams params) async {
    return await repository.getSavedSignatures();
  }
}