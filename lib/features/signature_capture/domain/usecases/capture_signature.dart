import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/signature.dart';
import '../entities/signature_params.dart';
import '../repositories/signature_repository.dart';

@LazySingleton()
class CaptureSignature implements UseCase<Signature, SignatureParams> {
  final SignatureRepository repository;

  CaptureSignature(this.repository);

  @override
  Future<Either<Failure, Signature>> call(SignatureParams params) async {
    return await repository.captureSignature(params);
  }
}