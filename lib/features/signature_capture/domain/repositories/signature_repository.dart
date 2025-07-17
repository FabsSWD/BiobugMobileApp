import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/signature.dart';
import '../entities/signature_params.dart';

abstract class SignatureRepository {
  Future<Either<Failure, Signature>> captureSignature(SignatureParams params);
  Future<Either<Failure, Unit>> saveSignatureLocally(Signature signature);
  Future<Either<Failure, Unit>> uploadSignature(Signature signature);
  Future<Either<Failure, List<Signature>>> getSavedSignatures();
  Future<Either<Failure, Unit>> deleteSignature(String id);
  Future<Either<Failure, bool>> validateSignature(Signature signature);
  Future<Either<Failure, Signature>> compressSignature(Signature signature);
}