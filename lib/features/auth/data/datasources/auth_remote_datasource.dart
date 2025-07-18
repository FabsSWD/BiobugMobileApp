import 'package:injectable/injectable.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/auth_result_model.dart';
import '../models/login_request_model.dart';
import '../models/register_request_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResultModel> login(LoginRequestModel request);
  Future<AuthResultModel> register(RegisterRequestModel request);
  Future<AuthResultModel> refreshToken(String refreshToken);
}

@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _apiClient;

  AuthRemoteDataSourceImpl(this._apiClient);

  @override
  Future<AuthResultModel> login(LoginRequestModel request) async {
    final response = await _apiClient.post(
      ApiConstants.loginEndpoint,
      data: request.toJson(), // ✅ Esto debería funcionar
    );

    if (response.statusCode == 200) {
      return AuthResultModel.fromJson(response.data);
    } else {
      throw Exception('Error en el login: ${response.statusCode}');
    }
  }

  @override
  Future<AuthResultModel> register(RegisterRequestModel request) async {
    // ✅ ASEGÚRATE DE QUE ESTO USE .toJson()
    final response = await _apiClient.post(
      ApiConstants.registerEndpoint,
      data: request.toJson(), // ← Esto es crucial
    );

    if (response.statusCode == 200) {
      return AuthResultModel.fromJson(response.data);
    } else {
      throw Exception('Error en el registro: ${response.statusCode}');
    }
  }

  @override
  Future<AuthResultModel> refreshToken(String refreshToken) async {
    final response = await _apiClient.post(
      '/auth/refresh',
      data: {'refreshToken': refreshToken},
    );

    if (response.statusCode == 200) {
      return AuthResultModel.fromJson(response.data);
    } else {
      throw Exception('Error al refrescar token: ${response.statusCode}');
    }
  }
}