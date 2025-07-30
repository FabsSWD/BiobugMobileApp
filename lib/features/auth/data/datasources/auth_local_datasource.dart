import 'dart:convert';
import 'package:flutter/foundation.dart';
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

  // Cache en memoria para evitar llamadas repetitivas a SecureStorage
  UserModel? _cachedUser;
  String? _cachedAccessToken;
  String? _cachedRefreshToken;
  int? _cachedTokenExpiration;
  DateTime? _lastCacheUpdate;
  
  // Timeout para cache - 5 minutos
  static const Duration _cacheTimeout = Duration(minutes: 5);

  AuthLocalDataSourceImpl(this._secureStorage);

  @override
  Future<void> cacheAuthResult(AuthResultModel authResult) async {
    try {
      _debugPrint('AuthLocalDataSource.cacheAuthResult - Start');
      
      // Realizar operaciones en paralelo
      final futures = <Future<void>>[];
      
      // Save tokens
      futures.add(
        _secureStorage.saveTokens(
          accessToken: authResult.accessToken,
          refreshToken: authResult.refreshToken, // Corregido - era accessToken
          expirationTime: authResult.expirationTime,
        ),
      );

      // Save user data if available
      if (authResult.userModel != null) {
        // Mover JSON encoding a isolate para objetos grandes
        if (_isLargeObject(authResult.userModel!)) {
          final userJson = await _encodeJsonInIsolate(authResult.userModel!.toJson());
          futures.add(_secureStorage.saveUserData(userJson));
        } else {
          final userJson = jsonEncode(authResult.userModel!.toJson());
          futures.add(_secureStorage.saveUserData(userJson));
        }
        
        // Actualizar cache en memoria
        _cachedUser = authResult.userModel;
      }

      // Esperar todas las operaciones en paralelo
      await Future.wait(futures);
      
      // Actualizar cache de tokens
      _cachedAccessToken = authResult.accessToken;
      _cachedRefreshToken = authResult.refreshToken;
      _cachedTokenExpiration = authResult.expirationTime;
      _lastCacheUpdate = DateTime.now();
      
      _debugPrint('Auth data cached successfully');
      
    } catch (e) {
      _debugPrint('Error in cacheAuthResult: $e');
      _invalidateCache();
      throw CacheException('Error al guardar datos de autenticación: $e');
    }
  }

  @override
  Future<UserModel?> getCachedUser() async {
    try {
      _debugPrint('AuthLocalDataSource.getCachedUser - Start');
      
      // Usar cache en memoria si es válido
      if (_isCacheValid() && _cachedUser != null) {
        _debugPrint('Returning cached user: ${_cachedUser!.fullName}');
        return _cachedUser;
      }
      
      final userJson = await _secureStorage.getUserData();
      if (userJson != null) {
        _debugPrint('Found stored user data');
        
        // Mover JSON decoding a isolate para objetos grandes
        UserModel userModel;
        if (userJson.length > 1000) { // Aprox 1KB
          final userMap = await _decodeJsonInIsolate(userJson);
          userModel = UserModel.fromJson(userMap);
        } else {
          final userMap = jsonDecode(userJson) as Map<String, dynamic>;
          userModel = UserModel.fromJson(userMap);
        }
        
        // Actualizar cache
        _cachedUser = userModel;
        _lastCacheUpdate = DateTime.now();
        
        _debugPrint('User loaded: ${userModel.fullName}');
        return userModel;
      }
      
      _debugPrint('No cached user data found');
      return null;
    } catch (e) {
      _debugPrint('Error in getCachedUser: $e');
      _cachedUser = null;
      throw CacheException('Error al obtener usuario guardado: $e');
    }
  }

  @override
  Future<String?> getAccessToken() async {
    try {
      // Usar cache en memoria si es válido
      if (_isCacheValid() && _cachedAccessToken != null) {
        return _cachedAccessToken;
      }
      
      final token = await _secureStorage.getAccessToken();
      
      // Actualizar cache
      if (token != null) {
        _cachedAccessToken = token;
        _lastCacheUpdate = DateTime.now();
        _debugPrint('Access token found');
      } else {
        _debugPrint('No access token found');
      }
      
      return token;
    } catch (e) {
      _debugPrint('Error getting access token: $e');
      _cachedAccessToken = null;
      throw CacheException('Error al obtener token de acceso: $e');
    }
  }

  @override
  Future<String?> getRefreshToken() async {
    try {
      // Usar cache en memoria si es válido
      if (_isCacheValid() && _cachedRefreshToken != null) {
        return _cachedRefreshToken;
      }
      
      final token = await _secureStorage.getRefreshToken();
      
      // Actualizar cache
      if (token != null) {
        _cachedRefreshToken = token;
        _lastCacheUpdate = DateTime.now();
      }
      
      return token;
    } catch (e) {
      _debugPrint('Error getting refresh token: $e');
      _cachedRefreshToken = null;
      throw CacheException('Error al obtener token de actualización: $e');
    }
  }

  @override
  Future<int?> getTokenExpiration() async {
    try {
      // Usar cache en memoria si es válido
      if (_isCacheValid() && _cachedTokenExpiration != null) {
        return _cachedTokenExpiration;
      }
      
      final expiration = await _secureStorage.getTokenExpiration();
      
      // Actualizar cache
      if (expiration != null) {
        _cachedTokenExpiration = expiration;
        _lastCacheUpdate = DateTime.now();
      }
      
      return expiration;
    } catch (e) {
      _debugPrint('Error getting token expiration: $e');
      _cachedTokenExpiration = null;
      throw CacheException('Error al obtener expiración del token: $e');
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    try {
      // Optimizar verificación usando cache
      if (_isCacheValid()) {
        // Si tenemos tokens en cache, verificar localmente
        if (_cachedAccessToken != null && _cachedTokenExpiration != null) {
          final now = DateTime.now().millisecondsSinceEpoch;
          final isValid = _cachedTokenExpiration! > now;
          _debugPrint('AuthLocalDataSource.isLoggedIn (cached) - Result: $isValid');
          return isValid;
        }
      }
      
      final isValid = await _secureStorage.isTokenValid();
      _debugPrint('AuthLocalDataSource.isLoggedIn - Result: $isValid');
      return isValid;
    } catch (e) {
      _debugPrint('Error checking login status: $e');
      return false;
    }
  }

  @override
  Future<void> clearAuthData() async {
    try {
      _debugPrint('AuthLocalDataSource.clearAuthData - Start');
      
      // Limpiar cache en memoria inmediatamente
      _invalidateCache();
      
      // Limpiar almacenamiento seguro
      await _secureStorage.clearAll();
      
      _debugPrint('All auth data cleared');
    } catch (e) {
      _debugPrint('Error clearing auth data: $e');
      throw CacheException('Error al limpiar datos de autenticación: $e');
    }
  }

  // Métodos auxiliares optimizados

  bool _isCacheValid() {
    if (_lastCacheUpdate == null) return false;
    
    final now = DateTime.now();
    final difference = now.difference(_lastCacheUpdate!);
    return difference < _cacheTimeout;
  }

  void _invalidateCache() {
    _cachedUser = null;
    _cachedAccessToken = null;
    _cachedRefreshToken = null;
    _cachedTokenExpiration = null;
    _lastCacheUpdate = null;
  }

  bool _isLargeObject(UserModel user) {
    // Estimar si el objeto será grande en JSON
    // Esto es una heurística simple
    final nameLength = (user.fullName.length ?? 0);
    final emailLength = (user.email.length ?? 0);
    // Agregar otros campos según tu modelo UserModel
    
    return (nameLength + emailLength) > 100; // Threshold arbitrario
  }

  // JSON encoding en isolate para objetos grandes
  static Future<String> _encodeJsonInIsolate(Map<String, dynamic> data) async {
    return await compute(_encodeJson, data);
  }

  static String _encodeJson(Map<String, dynamic> data) {
    return jsonEncode(data);
  }

  // JSON decoding en isolate para objetos grandes
  static Future<Map<String, dynamic>> _decodeJsonInIsolate(String jsonString) async {
    return await compute(_decodeJson, jsonString);
  }

  static Map<String, dynamic> _decodeJson(String jsonString) {
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }

  // Logging optimizado - solo en debug mode
  void _debugPrint(String message) {
    if (kDebugMode) {
      print(message);
    }
  }
}