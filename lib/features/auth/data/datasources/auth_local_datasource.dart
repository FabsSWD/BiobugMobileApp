import 'dart:convert';
import 'package:injectable/injectable.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../core/error/exceptions.dart';
import '../models/auth_result_model.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheAuthResult(AuthResultModel authResult);
  Future<UserModel?> getCachedUser();
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<int?> getTokenExpiration();
  Future<bool> isLoggedIn();
  Future<void> clearAuthData();
}

@LazySingleton(as: AuthLocalDataSource)
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SecureStorage _secureStorage;

  AuthLocalDataSourceImpl(this._secureStorage);

  @override
  Future<void> cacheAuthResult(AuthResultModel authResult) async {
    try {
      print('AuthLocalDataSource.cacheAuthResult - Start');
      print('Token: ${authResult.accessToken.substring(0, 20)}...');
      print('User: ${authResult.userModel?.fullName ?? 'null'}');
      
      // Save tokens
      await _secureStorage.saveTokens(
        accessToken: authResult.accessToken,
        refreshToken: authResult.accessToken,
        expirationTime: authResult.expirationTime,
      );
      print('Tokens saved successfully');

      // Save user data if available
      if (authResult.userModel != null) {
        final userJson = jsonEncode(authResult.userModel!.toJson());
        await _secureStorage.saveUserData(userJson);
        print('User data saved successfully');
      } else {
        print('No user data to save');
      }
      
    } catch (e) {
      print('Error in cacheAuthResult: $e');
      throw CacheException('Error al guardar datos de autenticación: $e');
    }
  }

  @override
  Future<UserModel?> getCachedUser() async {
    try {
      print('AuthLocalDataSource.getCachedUser - Start');
      
      final userJson = await _secureStorage.getUserData();
      if (userJson != null) {
        print('Found cached user data');
        final userMap = jsonDecode(userJson) as Map<String, dynamic>;
        final userModel = UserModel.fromJson(userMap);
        print('User: ${userModel.fullName}');
        return userModel;
      }
      
      print('No cached user data found');
      return null;
    } catch (e) {
      print('Error in getCachedUser: $e');
      throw CacheException('Error al obtener usuario guardado: $e');
    }
  }

  @override
  Future<String?> getAccessToken() async {
    try {
      final token = await _secureStorage.getAccessToken();
      if (token != null) {
        print('Access token found');
      } else {
        print('No access token found');
      }
      return token;
    } catch (e) {
      print('Error getting access token: $e');
      throw CacheException('Error al obtener token de acceso: $e');
    }
  }

  @override
  Future<String?> getRefreshToken() async {
    try {
      return await _secureStorage.getRefreshToken();
    } catch (e) {
      throw CacheException('Error al obtener token de actualización: $e');
    }
  }

  @override
  Future<int?> getTokenExpiration() async {
    try {
      return await _secureStorage.getTokenExpiration();
    } catch (e) {
      throw CacheException('Error al obtener expiración del token: $e');
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    try {
      final isValid = await _secureStorage.isTokenValid();
      print('AuthLocalDataSource.isLoggedIn - Result: $isValid');
      return isValid;
    } catch (e) {
      print('Error checking login status: $e');
      return false;
    }
  }

  @override
  Future<void> clearAuthData() async {
    try {
      print('AuthLocalDataSource.clearAuthData - Start');
      await _secureStorage.clearAll();
      print('All auth data cleared');
    } catch (e) {
      print('Error clearing auth data: $e');
      throw CacheException('Error al limpiar datos de autenticación: $e');
    }
  }
}