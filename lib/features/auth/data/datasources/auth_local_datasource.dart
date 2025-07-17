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
      // Save tokens - UPDATED to handle single token
      await _secureStorage.saveTokens(
        accessToken: authResult.accessToken,
        refreshToken: authResult.accessToken, // Use same token
        expirationTime: authResult.expirationTime,
      );

      // Save user data
      final userJson = jsonEncode(authResult.userModel.toJson());
      await _secureStorage.saveUserData(userJson);
    } catch (e) {
      throw CacheException('Error al guardar datos de autenticación: $e');
    }
  }

  @override
  Future<UserModel?> getCachedUser() async {
    try {
      final userJson = await _secureStorage.getUserData();
      if (userJson != null) {
        final userMap = jsonDecode(userJson) as Map<String, dynamic>;
        return UserModel.fromJson(userMap);
      }
      return null;
    } catch (e) {
      throw CacheException('Error al obtener usuario guardado: $e');
    }
  }

  @override
  Future<String?> getAccessToken() async {
    try {
      return await _secureStorage.getAccessToken();
    } catch (e) {
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
      return await _secureStorage.isTokenValid();
    } catch (e) {
      // Si hay error al verificar, asumimos que no está logueado
      return false;
    }
  }

  @override
  Future<void> clearAuthData() async {
    try {
      await _secureStorage.clearAll();
    } catch (e) {
      throw CacheException('Error al limpiar datos de autenticación: $e');
    }
  }
}