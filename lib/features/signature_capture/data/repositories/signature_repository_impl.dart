import 'dart:io';
import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import 'package:image/image.dart' as img;
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/file_utils.dart';
import '../../domain/entities/signature.dart';
import '../../domain/entities/signature_params.dart';
import '../../domain/repositories/signature_repository.dart';
import '../datasources/signature_local_datasource.dart';
import '../datasources/signature_remote_datasource.dart';
import '../models/signature_model.dart';
import '../models/signature_request_model.dart';

@LazySingleton(as: SignatureRepository)
class SignatureRepositoryImpl implements SignatureRepository {
  final SignatureLocalDataSource _localDataSource;
  final SignatureRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;
  final _uuid = const Uuid();

  SignatureRepositoryImpl(
    this._localDataSource,
    this._remoteDataSource,
    this._networkInfo,
  );

  @override
  Future<Either<Failure, Signature>> captureSignature(SignatureParams params) async {
    try {
      // Validaciones más flexibles
      if (params.width < AppConstants.signatureMinResolutionWidth ||
          params.height < AppConstants.signatureMinResolutionHeight) {
        return Left(ValidationFailure(
          'La resolución mínima debe ser ${AppConstants.signatureMinResolutionWidth}x${AppConstants.signatureMinResolutionHeight} píxeles',
          code: 'INVALID_RESOLUTION',
        ));
      }

      if (params.pointsCount < AppConstants.signatureMinPoints) {
        return Left(ValidationFailure(
          'La firma debe tener al menos ${AppConstants.signatureMinPoints} puntos',
          code: 'INSUFFICIENT_POINTS',
        ));
      }

      // Procesar imagen - comprimir solo si es muy grande
      Uint8List processedBytes = params.imageBytes;
      if (params.imageBytes.length > AppConstants.signatureMaxFileSize) {
        // Intentar comprimir
        try {
          processedBytes = await _compressImage(params.imageBytes, params.compressionLevel);
        } catch (e) {
          // Si falla la compresión, usar imagen original si no es extremadamente grande
          if (params.imageBytes.length > AppConstants.signatureMaxFileSize * 2) {
            return Left(ValidationFailure(
              'El archivo de firma es muy grande (${(params.imageBytes.length / 1024 / 1024).toStringAsFixed(2)}MB). Máximo permitido: ${(AppConstants.signatureMaxFileSize / 1024 / 1024).toStringAsFixed(1)}MB',
              code: 'FILE_TOO_LARGE',
            ));
          }
          processedBytes = params.imageBytes;
        }
      }

      // Create signature entity
      final signature = Signature(
        id: _uuid.v4(),
        imageBytes: processedBytes,
        createdAt: DateTime.now(),
        width: params.width,
        height: params.height,
        quality: params.quality,
        isUploaded: false,
        pointsCount: params.pointsCount,
        strokeWidth: params.strokeWidth,
      );

      return Right(signature);
    } on ValidationException catch (e) {
      return Left(e.toFailure());
    } catch (e) {
      return Left(ServerFailure('Error al capturar firma: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> saveSignatureLocally(Signature signature) async {
    try {
      // Save file to storage (sin cifrado para simplificar)
      final fileName = '${signature.id}.png';
      final filePath = await _localDataSource.saveSignatureFile(
        signature.imageBytes,
        fileName,
      );

      // Create model with file path
      final signatureModel = SignatureModel.fromEntity(
        signature.copyWith(filePath: filePath),
      );

      // Save metadata to local storage
      await _localDataSource.saveSignature(signatureModel);

      return const Right(unit);
    } on CacheException catch (e) {
      return Left(e.toFailure());
    } catch (e) {
      return Left(CacheFailure('Error al guardar firma localmente: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> uploadSignature(Signature signature) async {
    try {
      // Check network connectivity
      final isConnected = await _networkInfo.isConnected;
      if (!isConnected) {
        return const Left(NetworkFailure(
          'No hay conexión a internet para subir la firma',
        ));
      }

      // Create temporary file for upload
      final tempDir = await FileUtils.getAppDocumentsPath();
      final tempFile = File('$tempDir/temp_${signature.id}.png');
      await tempFile.writeAsBytes(signature.imageBytes);

      try {
        // Create request model
        final requestModel = SignatureRequestModel(
          signatureFile: tempFile,
          fileName: '${signature.id}.png',
        );

        // Upload to server
        await _remoteDataSource.uploadSignature(requestModel);

        // Update local signature as uploaded
        final updatedSignature = signature.copyWith(isUploaded: true);
        final signatureModel = SignatureModel.fromEntity(updatedSignature);
        await _localDataSource.saveSignature(signatureModel);

        return const Right(unit);
      } finally {
        // Clean up temporary file
        if (await tempFile.exists()) {
          await tempFile.delete();
        }
      }
    } on NetworkException catch (e) {
      return Left(e.toFailure());
    } on ServerException catch (e) {
      return Left(e.toFailure());
    } on ValidationException catch (e) {
      return Left(e.toFailure());
    } catch (e) {
      return Left(ServerFailure('Error al subir firma: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Signature>>> getSavedSignatures() async {
    try {
      final signatureModels = await _localDataSource.getSavedSignatures();
      final signatures = signatureModels.map((model) => model.toEntity()).toList();
      
      // Sort by creation date (most recent first)
      signatures.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      return Right(signatures);
    } on CacheException catch (e) {
      return Left(e.toFailure());
    } catch (e) {
      return Left(CacheFailure('Error al obtener firmas guardadas: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteSignature(String id) async {
    try {
      await _localDataSource.deleteSignature(id);
      return const Right(unit);
    } on CacheException catch (e) {
      return Left(e.toFailure());
    } catch (e) {
      return Left(CacheFailure('Error al eliminar firma: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> validateSignature(Signature signature) async {
    try {
      // Validación más flexible
      final isValid = signature.width >= AppConstants.signatureMinResolutionWidth &&
                     signature.height >= AppConstants.signatureMinResolutionHeight &&
                     signature.pointsCount >= AppConstants.signatureMinPoints &&
                     signature.imageBytes.isNotEmpty;
      
      return Right(isValid);
    } catch (e) {
      return Left(ValidationFailure('Error al validar firma: $e'));
    }
  }

  @override
  Future<Either<Failure, Signature>> compressSignature(Signature signature) async {
    try {
      final compressedBytes = await _compressImage(signature.imageBytes, 80);
      final compressedSignature = signature.copyWith(imageBytes: compressedBytes);
      return Right(compressedSignature);
    } catch (e) {
      return Left(ServerFailure('Error al comprimir firma: $e'));
    }
  }

  Future<Uint8List> _compressImage(Uint8List imageBytes, int quality) async {
    try {
      final image = img.decodeImage(imageBytes);
      if (image == null) {
        throw Exception('Error al decodificar imagen');
      }

      // Compress with specified quality (0-100)
      final compressedBytes = img.encodePng(image, level: quality);
      return Uint8List.fromList(compressedBytes);
    } catch (e) {
      throw Exception('Error al comprimir imagen: $e');
    }
  }
}