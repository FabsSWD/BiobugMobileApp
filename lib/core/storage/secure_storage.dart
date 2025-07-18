import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import '../constants/storage_constants.dart';
import '../error/exceptions.dart';

@LazySingleton()
class SecureStorage {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // Token Management - UPDATED for single token system
  Future<void> saveTokens({
    required String accessToken,
    String? refreshToken, // Made optional since backend doesn't provide it
    required int expirationTime,
  }) async {
    try {
      // Calculate actual expiration timestamp
      final currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final expirationTimestamp = currentTime + expirationTime;
      
      await Future.wait([
        _storage.write(key: StorageConstants.accessToken, value: accessToken),
        _storage.write(
          key: StorageConstants.refreshToken, 
          value: refreshToken ?? accessToken, // Use same token if no refresh token
        ),
        _storage.write(
          key: StorageConstants.tokenExpiration,
          value: expirationTimestamp.toString(),
        ),
      ]);
    } catch (e) {
      throw CacheException('Error al guardar tokens: $e');
    }
  }

  Future<String?> getAccessToken() async {
    try {
      return await _storage.read(key: StorageConstants.accessToken);
    } catch (e) {
      throw CacheException('Error al obtener token de acceso: $e');
    }
  }

  Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: StorageConstants.refreshToken);
    } catch (e) {
      throw CacheException('Error al obtener token de actualización: $e');
    }
  }

  Future<int?> getTokenExpiration() async {
    try {
      final expirationString = await _storage.read(
        key: StorageConstants.tokenExpiration,
      );
      return expirationString != null ? int.tryParse(expirationString) : null;
    } catch (e) {
      throw CacheException('Error al obtener expiración del token: $e');
    }
  }

  Future<bool> isTokenValid() async {
    try {
      final accessToken = await getAccessToken();
      final expiration = await getTokenExpiration();
      
      if (accessToken == null || expiration == null) return false;
      
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      return now < expiration;
    } catch (e) {
      return false;
    }
  }

  // User Data Management
  Future<void> saveUserData(String userData) async {
    try {
      await _storage.write(key: StorageConstants.userData, value: userData);
    } catch (e) {
      throw CacheException('Error al guardar datos del usuario: $e');
    }
  }

  Future<String?> getUserData() async {
    try {
      return await _storage.read(key: StorageConstants.userData);
    } catch (e) {
      throw CacheException('Error al obtener datos del usuario: $e');
    }
  }

  // Clear All Data
  Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      throw CacheException('Error al limpiar almacenamiento seguro: $e');
    }
  }

  Future<void> clearTokens() async {
    try {
      await Future.wait([
        _storage.delete(key: StorageConstants.accessToken),
        _storage.delete(key: StorageConstants.refreshToken),
        _storage.delete(key: StorageConstants.tokenExpiration),
      ]);
    } catch (e) {
      throw CacheException('Error al limpiar tokens: $e');
    }
  }

  Future<void> clearUserData() async {
    try {
      await _storage.delete(key: StorageConstants.userData);
    } catch (e) {
      throw CacheException('Error al limpiar datos del usuario: $e');
    }
  }
}