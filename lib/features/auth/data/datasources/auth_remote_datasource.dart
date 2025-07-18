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
    print('AuthRemoteDataSource.login - Start');
    print('Request data: ${request.toJson()}');
    
    final response = await _apiClient.post(
      ApiConstants.loginEndpoint,
      data: request.toJson(),
    );

    print('Login response status: ${response.statusCode}');
    print('Login response data: ${response.data}');

    if (response.statusCode == 200) {
      try {
        final authResult = AuthResultModel.fromJson(response.data);
        print('AuthResult parsed successfully');
        print('Has user data: ${authResult.userModel != null}');
        return authResult;
      } catch (e) {
        print('Error parsing login response: $e');
        print('Raw response data: ${response.data}');
        rethrow;
      }
    } else {
      throw Exception('Error en el login: ${response.statusCode}');
    }
  }

  @override
  Future<AuthResultModel> register(RegisterRequestModel request) async {
    print('AuthRemoteDataSource.register - Start');
    print('Request data: ${request.toJson()}');
    
    final response = await _apiClient.post(
      ApiConstants.registerEndpoint,
      data: request.toJson(),
    );

    print('Register response status: ${response.statusCode}');
    print('Register response data: ${response.data}');

    if (response.statusCode == 200) {
      try {
        final authResult = AuthResultModel.fromJson(response.data);
        print('AuthResult parsed successfully');
        print('Has user data: ${authResult.userModel != null}');
        return authResult;
      } catch (e) {
        print('Error parsing register response: $e');
        print('Raw response data: ${response.data}');
        rethrow;
      }
    } else {
      throw Exception('Error en el registro: ${response.statusCode}');
    }
  }

  @override
  Future<AuthResultModel> refreshToken(String refreshToken) async {
    print('AuthRemoteDataSource.refreshToken - Start');
    
    final response = await _apiClient.post(
      '/auth/refresh',
      data: {'refreshToken': refreshToken},
    );

    print('Refresh token response status: ${response.statusCode}');
    print('Refresh token response data: ${response.data}');

    if (response.statusCode == 200) {
      try {
        final authResult = AuthResultModel.fromJson(response.data);
        print('AuthResult parsed successfully');
        return authResult;
      } catch (e) {
        print('Error parsing refresh token response: $e');
        print('Raw response data: ${response.data}');
        rethrow;
      }
    } else {
      throw Exception('Error al refrescar token: ${response.statusCode}');
    }
  }
}