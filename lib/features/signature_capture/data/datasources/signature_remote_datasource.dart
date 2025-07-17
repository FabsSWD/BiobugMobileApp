import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/error/exceptions.dart';
import '../models/signature_request_model.dart';

abstract class SignatureRemoteDataSource {
  Future<void> uploadSignature(SignatureRequestModel request);
}

@LazySingleton(as: SignatureRemoteDataSource)
class SignatureRemoteDataSourceImpl implements SignatureRemoteDataSource {
  final ApiClient _apiClient;

  SignatureRemoteDataSourceImpl(this._apiClient);

  @override
  Future<void> uploadSignature(SignatureRequestModel request) async {
    try {
      final formData = FormData.fromMap({
        'signatureFile': await request.toMultipartFile(),
      });

      final response = await _apiClient.post(
        '/signature',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      if (response.statusCode != 200) {
        throw ServerException(
          'Error al subir firma: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        final errorData = e.response?.data;
        if (errorData is Map<String, dynamic>) {
          final errors = errorData['errors'] as Map<String, dynamic>?;
          final signatureFileError = errors?['SignatureFile'] as List<dynamic>?;
          
          if (signatureFileError != null && signatureFileError.isNotEmpty) {
            throw ValidationException(
              signatureFileError.first.toString(),
              code: 'SIGNATURE_FILE_REQUIRED',
            );
          }
        }
        throw ValidationException(
          errorData['title'] ?? 'Error de validación en la firma',
          code: 'VALIDATION_ERROR',
        );
      }
      rethrow;
    } catch (e) {
      throw ServerException('Error inesperado al subir firma: $e');
    }
  }
}